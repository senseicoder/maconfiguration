#!/bin/bash
# Transcription vocale via whisper.cpp server → injection dans le terminal actif.
# Usage : whisper-dictate.sh [durée_secondes]  (défaut : 5)

set -e

# Un seul enregistrement à la fois — sortie silencieuse si déjà actif
exec 9>/tmp/whisper-dictate.lock
flock -n 9 || exit 0

WHISPER_SERVER="http://127.0.0.1:8765"
DURATION="${1:-5}"
TMP="$(mktemp /tmp/whisper-XXXXXX.wav)"

cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

rec -q -r 16000 -c 1 "$TMP" trim 0 "$DURATION" 2>/dev/null

TEXT=$(curl -sf "$WHISPER_SERVER/inference" \
  -F "file=@$TMP" \
  -F "temperature=0" \
  -F "response_format=json" \
  -F "language=fr" \
  | jq -r '.text // empty' \
  | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

if [ -n "$TEXT" ]; then
  xdotool type --clearmodifiers --delay 30 -- "$TEXT"
fi
