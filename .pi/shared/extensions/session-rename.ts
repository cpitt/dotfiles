import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";

type ModelRoute = {
	model: string;
	thinkingLevel: ThinkingLevel;
};

type RenameConfig = {
	primary: ModelRoute;
	backups: ModelRoute[];
	maxContextChars: number;
	maxOutputTokens: number;
	maxNameWords: number;
	maxNameChars: number;
};

const EXTENSION_ID = "session-rename";
const AGENT_DIR = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
const CONFIG_PATH = join(AGENT_DIR, "config", EXTENSION_ID, "config.json");

const DEFAULT_CONFIG: RenameConfig = {
	primary: { model: "github-copilot/gpt-5.6-luna", thinkingLevel: "low" },
	backups: [{ model: "claude-bridge/claude-haiku-4-5", thinkingLevel: "low" }],
	maxContextChars: 6000,
	maxOutputTokens: 64,
	maxNameWords: 6,
	maxNameChars: 60,
};

const THINKING_LEVELS = new Set<ThinkingLevel>([
	"off",
	"minimal",
	"low",
	"medium",
	"high",
	"xhigh",
	"max",
]);

function isPositiveInteger(value: unknown): value is number {
	return Number.isInteger(value) && typeof value === "number" && value > 0;
}

function parseRoute(value: unknown, field: string): ModelRoute {
	if (!value || typeof value !== "object" || Array.isArray(value)) {
		throw new Error(`${field} must be an object.`);
	}
	const route = value as Record<string, unknown>;
	if (typeof route.model !== "string" || !route.model.includes("/") || /\s/.test(route.model)) {
		throw new Error(`${field}.model must be a provider/model reference.`);
	}
	if (typeof route.thinkingLevel !== "string" || !THINKING_LEVELS.has(route.thinkingLevel as ThinkingLevel)) {
		throw new Error(`${field}.thinkingLevel is invalid.`);
	}
	return { model: route.model, thinkingLevel: route.thinkingLevel as ThinkingLevel };
}

function loadConfig(): RenameConfig {
	let parsed: unknown;
	try {
		parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
	} catch (error) {
		if ((error as NodeJS.ErrnoException).code === "ENOENT") return DEFAULT_CONFIG;
		throw new Error(`Cannot read ${CONFIG_PATH}: ${error instanceof Error ? error.message : String(error)}`);
	}
	if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
		throw new Error(`Configuration in ${CONFIG_PATH} must be an object.`);
	}
	const config = parsed as Record<string, unknown>;
	const allowed = new Set([
		"primary",
		"backups",
		"maxContextChars",
		"maxOutputTokens",
		"maxNameWords",
		"maxNameChars",
	]);
	const unknown = Object.keys(config).filter((key) => !allowed.has(key));
	if (unknown.length) throw new Error(`Unknown configuration field(s): ${unknown.join(", ")}.`);
	if (config.backups !== undefined && !Array.isArray(config.backups)) {
		throw new Error("backups must be an array.");
	}

	const result: RenameConfig = {
		primary: parseRoute(config.primary ?? DEFAULT_CONFIG.primary, "primary"),
		backups: (config.backups ?? DEFAULT_CONFIG.backups).map((route, index) => parseRoute(route, `backups[${index}]`)),
		maxContextChars: config.maxContextChars ?? DEFAULT_CONFIG.maxContextChars,
		maxOutputTokens: config.maxOutputTokens ?? DEFAULT_CONFIG.maxOutputTokens,
		maxNameWords: config.maxNameWords ?? DEFAULT_CONFIG.maxNameWords,
		maxNameChars: config.maxNameChars ?? DEFAULT_CONFIG.maxNameChars,
	};

	for (const field of ["maxContextChars", "maxOutputTokens", "maxNameWords", "maxNameChars"] as const) {
		if (!isPositiveInteger(result[field])) throw new Error(`${field} must be a positive integer.`);
	}
	return result;
}

function messageText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.flatMap((part) =>
			part && typeof part === "object" && "type" in part && part.type === "text" && "text" in part && typeof part.text === "string"
				? [part.text]
				: [],
		)
		.join("\n");
}

function conversationText(ctx: ExtensionContext, maxChars: number): string {
	const messages: string[] = [];
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message") continue;
		if (entry.message.role !== "user" && entry.message.role !== "assistant") continue;
		const text = messageText(entry.message.content).trim();
		if (text) messages.push(`${entry.message.role}: ${text}`);
	}

	const selected: string[] = [];
	let remaining = maxChars;
	for (let index = messages.length - 1; index >= 0 && remaining > 0; index--) {
		const separatorLength = selected.length ? 2 : 0;
		const available = remaining - separatorLength;
		if (available <= 0) break;
		const text = messages[index].slice(-available);
		selected.push(text);
		remaining -= text.length + separatorLength;
	}
	return selected.reverse().join("\n\n");
}

function cleanName(raw: string, config: RenameConfig): string | undefined {
	let name = raw
		.split("\n")
		.map((line) => line.trim())
		.find(Boolean)
		?.replace(/^title\s*:\s*/i, "")
		.replace(/^["'`]+|["'`]+$/g, "")
		.replace(/[\u0000-\u001f\u007f]/g, " ")
		.replace(/\s+/g, " ")
		.trim();
	if (!name) return undefined;
	name = name.split(/\s+/).slice(0, config.maxNameWords).join(" ");
	if (name.length > config.maxNameChars) {
		name = name.slice(0, config.maxNameChars).replace(/\s+\S*$/, "").trim();
	}
	return name || undefined;
}

async function generateWithRoute(
	route: ModelRoute,
	config: RenameConfig,
	conversation: string,
	ctx: ExtensionContext,
): Promise<string> {
	const slash = route.model.indexOf("/");
	const providerId = route.model.slice(0, slash);
	const modelId = route.model.slice(slash + 1);
	const registeredModel = ctx.modelRegistry.find(providerId, modelId);
	if (!registeredModel) throw new Error("model is unavailable");

	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(registeredModel);
	if (!auth.ok) throw new Error(auth.error || "authentication is unavailable");
	const provider = ctx.modelRegistry.getProvider(registeredModel.provider);
	if (!provider) throw new Error("provider is unavailable");
	const model = auth.baseUrl ? { ...registeredModel, baseUrl: auth.baseUrl } : registeredModel;

	const response = await provider.streamSimple(
		model,
		{
			systemPrompt: `Generate a concise session title describing the current task. Return only the title, with at most ${config.maxNameWords} words and ${config.maxNameChars} characters. Do not add quotes, labels, explanations, or punctuation at the end.`,
			messages: [{ role: "user", content: conversation, timestamp: Date.now() }],
		},
		{
			apiKey: auth.apiKey,
			headers: auth.headers,
			env: auth.env,
			maxTokens: config.maxOutputTokens,
			maxRetries: 0,
			...(route.thinkingLevel === "off" ? {} : { reasoning: route.thinkingLevel }),
		},
	).result();

	if (response.stopReason === "error") throw new Error(response.errorMessage || "model returned an error");
	const raw = response.content
		.filter((part) => part.type === "text")
		.map((part) => part.text)
		.join(" ");
	const name = cleanName(raw, config);
	if (!name) throw new Error("model returned no valid title");
	return name;
}

async function generateConfiguredName(
	config: RenameConfig,
	conversation: string,
	ctx: ExtensionContext,
): Promise<string> {
	const failures: string[] = [];
	for (const route of [config.primary, ...config.backups]) {
		try {
			return await generateWithRoute(route, config, conversation, ctx);
		} catch (error) {
			failures.push(`${route.model}: ${error instanceof Error ? error.message : String(error)}`);
		}
	}
	throw new Error(failures.join("; "));
}

export default function sessionRename(pi: ExtensionAPI): void {
	let automaticAttempted = false;
	let generationSequence = 0;

	const resetSessionState = () => {
		automaticAttempted = false;
		generationSequence++;
	};

	pi.on("session_start", resetSessionState);
	pi.on("session_switch", resetSessionState);
	pi.on("session_fork", resetSessionState);

	pi.on("before_agent_start", (event, ctx) => {
		if (automaticAttempted || pi.getSessionName()) return;
		const prompt = event.prompt.trim();
		if (!prompt) return;
		automaticAttempted = true;

		let config: RenameConfig;
		try {
			config = loadConfig();
		} catch (error) {
			ctx.ui.notify(error instanceof Error ? error.message : "Invalid session rename configuration.", "error");
			return;
		}

		const request = ++generationSequence;
		void generateConfiguredName(config, prompt.slice(0, config.maxContextChars), ctx)
			.then((name) => {
				if (request !== generationSequence || pi.getSessionName()) return;
				pi.setSessionName(name);
				ctx.ui.notify(`Session renamed: ${name}`, "info");
			})
			.catch((error) => {
				if (request !== generationSequence) return;
				ctx.ui.notify(`Session rename failed. ${error instanceof Error ? error.message : String(error)}`, "error");
			});
	});

	pi.registerCommand("rename", {
		description: "Set a session name, or generate one with the configured small models",
		handler: async (args, ctx) => {
			automaticAttempted = true;
			const request = ++generationSequence;
			const suppliedName = args.trim();
			if (suppliedName) {
				pi.setSessionName(suppliedName);
				ctx.ui.notify(`Session renamed: ${suppliedName}`, "info");
				return;
			}

			let config: RenameConfig;
			try {
				config = loadConfig();
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : "Invalid session rename configuration.", "error");
				return;
			}

			const conversation = conversationText(ctx, config.maxContextChars);
			if (!conversation) {
				ctx.ui.notify("No conversation is available to name.", "warning");
				return;
			}

			try {
				const name = await generateConfiguredName(config, conversation, ctx);
				if (request !== generationSequence) return;
				pi.setSessionName(name);
				ctx.ui.notify(`Session renamed: ${name}`, "info");
			} catch (error) {
				if (request !== generationSequence) return;
				ctx.ui.notify(`Session rename failed. ${error instanceof Error ? error.message : String(error)}`, "error");
			}
		},
	});
}
