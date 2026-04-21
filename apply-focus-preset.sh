#!/bin/sh
set -eu

CONFIG_DIR="${HOME}/.config/tmux"
PRESET="${1:-balanced}"
PRESET_FILE="${CONFIG_DIR}/focus-${PRESET}.conf"

if [ ! -f "${PRESET_FILE}" ]; then
  tmux display-message "Unknown focus preset: ${PRESET}"
  exit 1
fi

# Load the preset into tmux globals first.
tmux source-file "${PRESET_FILE}"

# Reapply window-scoped options to all existing windows so live sessions
# don't keep stale local values from a previous preset.
WINDOW_OPTIONS="
pane-border-status
pane-border-lines
pane-border-indicators
pane-active-border-style
pane-border-style
pane-border-format
window-style
window-active-style
"

tmux list-windows -a -F '#{window_id}' | while IFS= read -r target; do
  [ -n "${target}" ] || continue
  for option in ${WINDOW_OPTIONS}; do
    value="$(tmux show-window-options -gv "${option}")"
    tmux set-window-option -t "${target}" "${option}" "${value}"
  done
done
