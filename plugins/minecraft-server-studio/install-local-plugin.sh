#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="minecraft-server-studio"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SOURCE="${SCRIPT_DIR}"
REGISTRY_ROOT="${HOME}/.agents/plugins"
PLUGIN_LINK_ROOT="${REGISTRY_ROOT}/plugins"
PLUGIN_LINK_PATH="${PLUGIN_LINK_ROOT}/${PLUGIN_NAME}"
MARKETPLACE_PATH="${REGISTRY_ROOT}/marketplace.json"

mkdir -p "${PLUGIN_LINK_ROOT}"

if [ -L "${PLUGIN_LINK_PATH}" ] || [ -e "${PLUGIN_LINK_PATH}" ]; then
  rm -rf "${PLUGIN_LINK_PATH}"
fi

ln -s "${PLUGIN_SOURCE}" "${PLUGIN_LINK_PATH}"

export PLUGIN_SOURCE
python3 - <<'PY'
import json
import os
from pathlib import Path

plugin_name = "minecraft-server-studio"
marketplace_path = Path.home() / ".agents" / "plugins" / "marketplace.json"

default_root = {
    "name": "local-codex-plugins",
    "interface": {"displayName": "Local Codex Plugins"},
    "plugins": [],
}

if marketplace_path.exists():
    data = json.loads(marketplace_path.read_text())
else:
    data = default_root

data.setdefault("name", "local-codex-plugins")
data.setdefault("interface", {})
data["interface"].setdefault("displayName", "Local Codex Plugins")
plugins = data.setdefault("plugins", [])

entry = {
    "name": plugin_name,
    "source": {
        "source": "local",
        "path": f"./plugins/{plugin_name}",
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Developer Tools",
}

plugins = [item for item in plugins if item.get("name") != plugin_name]
plugins.append(entry)
data["plugins"] = plugins

marketplace_path.write_text(json.dumps(data, indent=2) + "\n")
PY

echo "Installed ${PLUGIN_NAME} into ${PLUGIN_LINK_PATH}"
echo "Updated marketplace at ${MARKETPLACE_PATH}"
echo "Restart Codex desktop to see the plugin in the Plugins tab."
