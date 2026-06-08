#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ampcode_dir="${HOME}/.config/agents/skills"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
codex_dir="${codex_home}/skills"
legacy_agents_dir="${HOME}/.agents/skills"

is_codex_only_skill() {
  case "$1" in
    consulting-librarian) return 0 ;;
    *) return 1 ;;
  esac
}

replace_with_symlink() {
  local source="$1"
  local target_dir="$2"
  local name="$3"
  local target="${target_dir}/${name}"
  local backup_root
  local backup

  mkdir -p "$target_dir"

  if [[ -L "$target" ]]; then
    rm -f "$target"
  elif [[ -e "$target" ]]; then
    backup_root="$(dirname "$target_dir")/skill-backups"
    mkdir -p "$backup_root"
    backup="${backup_root}/${name}-$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "  backed up existing ${target} to ${backup}"
  fi

  ln -s "$source" "$target"
}

remove_repo_symlink() {
  local target="$1"
  local link_target

  if [[ ! -L "$target" ]]; then
    return
  fi

  link_target="$(readlink "$target")"
  case "$link_target" in
    "$repo_root"/*)
      rm -f "$target"
      ;;
  esac
}

remove_retired_skill_links() {
  local name

  for name in autofixing-codex-reviews; do
    remove_repo_symlink "${ampcode_dir}/${name}"
    remove_repo_symlink "${codex_dir}/${name}"
    remove_repo_symlink "${legacy_agents_dir}/${name}"
  done
}

warn_if_old_codex_cli() {
  local codex_path

  if ! command -v codex >/dev/null 2>&1; then
    return
  fi

  codex_path="$(command -v codex)"
  if ! codex app --help >/dev/null 2>&1; then
    echo "! ${codex_path} does not support 'codex app'; update PATH to a newer Codex CLI for Desktop integration" >&2
  fi
}

cd "$repo_root"

remove_retired_skill_links

for skill in */SKILL.md; do
  name="$(dirname "$skill")"
  source="${repo_root}/${name}"

  remove_repo_symlink "${legacy_agents_dir}/${name}"
  replace_with_symlink "$source" "$codex_dir" "$name"

  if is_codex_only_skill "$name"; then
    echo "✓ ${name} (Codex only)"
    continue
  fi

  replace_with_symlink "$source" "$ampcode_dir" "$name"
  echo "✓ ${name}"
done

warn_if_old_codex_cli
