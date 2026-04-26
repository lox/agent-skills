#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ampcode_dir="${HOME}/.config/agents/skills"
codex_dir="${HOME}/.agents/skills"

is_non_amp_only_skill() {
  case "$1" in
    consulting-librarian) return 0 ;;
    *) return 1 ;;
  esac
}

mkdir -p "$ampcode_dir" "$codex_dir"

cd "$repo_root"

for skill in */SKILL.md; do
  name="$(dirname "$skill")"

  rm -rf "${ampcode_dir}/${name}" "${codex_dir}/${name}"
  ln -s "${repo_root}/${name}" "${codex_dir}/${name}"

  if is_non_amp_only_skill "$name"; then
    echo "✓ ${name} (non-Amp only)"
    continue
  fi

  ln -s "${repo_root}/${name}" "${ampcode_dir}/${name}"
  echo "✓ ${name}"
done
