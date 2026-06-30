#!/bin/bash
# Transcription vocale via whisper.cpp → injection dans le terminal actif.
# Usage : whisper-dictate.sh [durée_secondes]  (défaut : 5)

set -e

WHISPER_DIR=/space/Work/whisper.cpp
WHISPER_BIN="$WHISPER_DIR/main"
WHISPER_MODEL="$WHISPER_DIR/models/ggml-medium.bin"
WHISPER_PROMPT="Epiconcept, Ansible, INFRADESK, ADR, Architecture Decision Record, mnementh6, mnementh7, infra-deploy, Claude Code, logrotate, MariaDB, Docker, satcom1, profntd1"
DURATION="${1:-5}"
TMP="$(mktemp /tmp/whisper-XXXXXX.wav)"

cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

rec -q -r 16000 -c 1 "$TMP" trim 0 "$DURATION" 2>/dev/null

TEXT=$("$WHISPER_BIN" \
  -m "$WHISPER_MODEL" \
  -l fr \
  --prompt "$WHISPER_PROMPT" \
  -nt \
  -np \
  -f "$TMP" 2>/dev/null \
  | sed 's/^[[:space:]]*//' | sed '/^$/d' | tr '\n' ' ' | sed 's/[[:space:]]*$//')

if [ -n "$TEXT" ]; then
  xdotool type --clearmodifiers --delay 30 -- "$TEXT"
fi
