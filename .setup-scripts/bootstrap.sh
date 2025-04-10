#!/bin/bash

source ./brew.sh

system_type=$(uname -s)
if [[ "$system_type" = "Darwin" ]]; then
	setup_brew
fi
