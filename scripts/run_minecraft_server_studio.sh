#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${ROOT_DIR}/apps/minecraft-server-studio"
PROJECT_NAME="MinecraftServerStudio"
SCHEME="MinecraftServerStudio"
PROJECT_PATH="${APP_DIR}/${PROJECT_NAME}.xcodeproj"
DERIVED_DATA="${APP_DIR}/.build-debug"
APP_PATH="${DERIVED_DATA}/Build/Products/Debug/${PROJECT_NAME}.app"

ensure_xcodegen() {
  if ! command -v xcodegen >/dev/null 2>&1; then
    echo "xcodegen is required. Install it with: brew install xcodegen" >&2
    exit 1
  fi
}

generate_project() {
  ensure_xcodegen
  (cd "${APP_DIR}" && xcodegen generate)
}

ensure_project() {
  generate_project
}

case "${1:-doctor}" in
  doctor)
    echo "Repo: ${ROOT_DIR}"
    echo "App dir: ${APP_DIR}"
    if command -v xcodegen >/dev/null 2>&1; then
      echo "xcodegen: $(command -v xcodegen)"
    else
      echo "xcodegen: missing"
    fi
    if command -v xcodebuild >/dev/null 2>&1; then
      echo "xcodebuild: $(command -v xcodebuild)"
    else
      echo "xcodebuild: missing"
    fi
    ;;
  generate)
    generate_project
    ;;
  open)
    ensure_project
    open "${PROJECT_PATH}"
    ;;
  build)
    ensure_project
    xcodebuild \
      -project "${PROJECT_PATH}" \
      -scheme "${SCHEME}" \
      -derivedDataPath "${DERIVED_DATA}" \
      build
    ;;
  run)
    ensure_project
    xcodebuild \
      -project "${PROJECT_PATH}" \
      -scheme "${SCHEME}" \
      -derivedDataPath "${DERIVED_DATA}" \
      build
    open "${APP_PATH}"
    ;;
  inspect)
    find "${APP_DIR}" -maxdepth 3 -type f | sort
    ;;
  *)
    echo "Usage: $0 {doctor|generate|open|build|run|inspect}" >&2
    exit 1
    ;;
esac
