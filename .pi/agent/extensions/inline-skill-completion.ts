/**
 * Complete skill names and filesystem paths after an inline slash.
 *
 * Examples (press Tab after the partial name):
 *   Let's use /grill-me to ask about turtles
 *   Inspect /Users/cpi/src
 *
 * Pi's built-in slash menu is intentionally left unchanged at the beginning
 * of a prompt. Inline `/...` completion is offered through Tab because Pi's
 * editor reserves automatic slash-menu triggering for the start of a prompt.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem, AutocompleteProvider } from "@earendil-works/pi-tui";

type SkillCommand = ReturnType<ExtensionAPI["getCommands"]>[number];

export interface InlineSkillToken {
	query: string;
}

/** Return the unfinished skill token at the cursor, but only when it is inline. */
export function extractInlineSkillToken(textBeforeCursor: string): InlineSkillToken | undefined {
	const match = textBeforeCursor.match(/(?:^|[\s([{])\/([a-zA-Z0-9._-]*)$/);
	if (!match) return undefined;

	const slashIndex = textBeforeCursor.lastIndexOf("/");
	if (slashIndex < 0 || textBeforeCursor.slice(0, slashIndex).trim().length === 0) return undefined;

	return {
		query: match[1] ?? "",
	};
}

function skillName(command: SkillCommand): string {
	return command.name.startsWith("skill:") ? command.name.slice("skill:".length) : command.name;
}

export function skillItems(commands: SkillCommand[], token: InlineSkillToken): AutocompleteItem[] {
	const query = token.query.toLowerCase();

	return commands
		.filter((command) => command.source === "skill")
		.map((command) => ({ command, name: skillName(command) }))
		.filter(({ name }) => !query || name.toLowerCase().includes(query))
		.sort((a, b) => {
			const aPrefix = a.name.toLowerCase().startsWith(query) ? 0 : 1;
			const bPrefix = b.name.toLowerCase().startsWith(query) ? 0 : 1;
			return aPrefix - bPrefix || a.name.localeCompare(b.name);
		})
		.map(({ command, name }) => ({
			// Replace only the partial name. This preserves the slash (and optional
			// `skill:`) while preventing Enter from treating this as a top-level
			// slash command and immediately submitting the whole prompt.
			value: name,
			label: `[skill] /${name}`,
			description: command.description ? `Skill · ${command.description}` : "Skill",
		}));
}

function normalizePathItems(items: AutocompleteItem[]): AutocompleteItem[] {
	return items.map((item) => ({
		...item,
		// The common completion prefix excludes the leading slash. Keep that
		// slash in the editor and remove it from absolute path completion values.
		value: item.value.startsWith("/") ? item.value.slice(1) : item.value,
		label: `[path] ${item.label}`,
	}));
}

function createProvider(pi: ExtensionAPI, current: AutocompleteProvider): AutocompleteProvider {
	return {
		async getSuggestions(lines, cursorLine, cursorCol, options) {
			const line = lines[cursorLine] ?? "";
			const token = extractInlineSkillToken(line.slice(0, cursorCol));
			if (!token) return current.getSuggestions(lines, cursorLine, cursorCol, options);

			const native = await current.getSuggestions(lines, cursorLine, cursorCol, options);
			if (options.signal.aborted) return null;

			const skills = skillItems(pi.getCommands(), token);
			const paths = native ? normalizePathItems(native.items) : [];
			const items = [...skills, ...paths];
			if (items.length === 0) return null;

			// Search skills by their bare name, not by Pi's `skill:` command prefix.
			// Using only the text after `/` as the shared prefix also lets Enter
			// insert a selection without submitting the prompt as a slash command.
			return { prefix: token.query, items };
		},

		applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
			return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
		},

		shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
			return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
		},
	};
}

export default function inlineSkillCompletion(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.addAutocompleteProvider((current) => createProvider(pi, current));
	});
}
