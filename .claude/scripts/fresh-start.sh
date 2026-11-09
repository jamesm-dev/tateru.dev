#!/usr/bin/env bash
# Make a fresh clone of tateru the person's own project: a new git history
# instead of tateru's, and a folder named after their project.
#
#   bash .claude/scripts/fresh-start.sh --check          exit 0 if already fresh, 1 if not (says why)
#   bash .claude/scripts/fresh-start.sh                  start fresh: new git history, nothing else touched
#   bash .claude/scripts/fresh-start.sh --keep-own-commits-lost
#                                                        the same, when the copy already holds commits
#                                                        of the person's own (their files stay; that
#                                                        history goes) - only after they said yes
#   bash .claude/scripts/fresh-start.sh --rename <name>  rename the project folder; run it last, then
#                                                        reopen Claude Code in the new folder
#
# Every file stays exactly where it is. Only .git is replaced. Never runs for
# tateru's maintainer (git config tateru.maintainer true), whose copy IS tateru.
#
# Exit 0 done or already fresh, 1 not fresh (--check) or refused, 2 could not run.
set -u

# tateru's first commit. A history that contains it is still tateru's.
TATERU_ROOT="${TATERU_ROOT:-276b2bd07d70eb7ffe865bf51feca289bd1f1114}"

# The project is where this script lives (.claude/scripts/), whatever folder it
# was started from - so --rename run from outside still renames the right one.
root=$(cd "$(dirname "$0")/../.." && pwd) || exit 2
cd "$root" || exit 2

is_maintainer() { [ "$(git config --get tateru.maintainer 2>/dev/null)" = "true" ]; }

# Why this is still tateru's copy, one reason per line; empty when fresh.
reasons() {
  [ -d .git ] || { echo "it has no git history of its own yet"; return 0; }
  git cat-file -e "$TATERU_ROOT^{commit}" 2>/dev/null &&
    git merge-base --is-ancestor "$TATERU_ROOT" HEAD 2>/dev/null &&
    echo "its git history is tateru's own"
  # Only the clone's own link counts: /upgrade deliberately adds one named "tateru".
  git remote get-url origin 2>/dev/null | grep -q 'jamesm-dev/tateru\.dev' &&
    echo "it is still linked to tateru on GitHub"
  case "$(basename "$root")" in
    tateru|tateru.dev|tateru-main|tateru.dev-main) echo "the folder is still named $(basename "$root")" ;;
  esac
  return 0
}

if [ "${1:-}" = "--check" ]; then
  is_maintainer && exit 0
  why=$(reasons)
  [ -z "$why" ] && exit 0
  printf '%s\n' "$why"
  exit 1
fi

if [ "${1:-}" = "--rename" ]; then
  name="${2:-}"
  case "$name" in
    ''|*/*|*\\*|.*|*' '*) echo "fresh-start: give a folder name with no spaces or slashes, like my-recipe-app" >&2; exit 2 ;;
  esac
  parent=$(dirname "$root")
  target="$parent/$name"
  [ -e "$target" ] && { echo "fresh-start: $target already exists; pick another name" >&2; exit 1; }
  # Step out first: Windows will not rename a folder a program is working in.
  cd "$parent" || exit 2
  if mv "$root" "$target" 2>/dev/null; then
    echo "Renamed the project folder to: $target"
    echo "Reopen Claude Code in that folder to carry on."
    exit 0
  fi
  # Usually Windows, because Claude Code itself still has the folder open.
  echo "The folder could not be renamed while it is open (Windows keeps open folders locked)."
  echo "Close Claude Code, rename the folder $(basename "$root") to $name in File Explorer or Finder,"
  echo "then open Claude Code again in the renamed folder."
  exit 1
fi

is_maintainer && { echo "fresh-start: this is tateru's maintainer copy (git config tateru.maintainer true); refusing to replace its history." >&2; exit 1; }

if [ -d .git ] && [ -z "$(reasons | grep -v '^the folder')" ]; then
  echo "Already a fresh start: the git history here is the project's own."
  exit 0
fi

# Commits the person made on top of tateru's history. Their files are kept
# either way; this history would go, so stop unless they said yes.
if [ -d .git ] && git cat-file -e "$TATERU_ROOT^{commit}" 2>/dev/null; then
  # Everything tateru's tags and remote branches reach is tateru's; the rest is theirs.
  # ${theirs[@]+...}: bash 3.2 (macOS) treats an empty array as unset under set -u.
  theirs=()
  while IFS= read -r r; do theirs+=("$r"); done < <(git for-each-ref --format='%(refname)' refs/tags refs/remotes)
  # If the count cannot be made, assume there is work to lose: never wipe on a guess.
  own=$(git rev-list --count HEAD --not ${theirs[@]+"${theirs[@]}"} 2>/dev/null) || own="an unknown number of"
  if [ "$own" != 0 ] && [ "${1:-}" != "--keep-own-commits-lost" ]; then
    echo "fresh-start: this copy already has $own commit(s) of the project's own. Their files are kept, but that history would be lost." >&2
    echo "fresh-start: ask the person; if they agree, run again with --keep-own-commits-lost." >&2
    exit 1
  fi
fi

version=$(tr -d '[:space:]' < .claude/TATERU_VERSION 2>/dev/null)
# A name and email set only for this folder live in .git; carry them over.
name=$(git config --local --get user.name 2>/dev/null)
email=$(git config --local --get user.email 2>/dev/null)
rm -rf .git || exit 2
git init -q || exit 2
[ -n "$name" ] && git config user.name "$name"
[ -n "$email" ] && git config user.email "$email"
git symbolic-ref HEAD refs/heads/main
git add -A
# On Windows (core.fileMode false) scripts are staged as non-executable, and git
# on Linux and macOS would then skip the hooks. Mark them executable explicitly.
git ls-files -z .githooks .claude/hooks .claude/scripts | xargs -0 -r git update-index --chmod=+x

if git config user.name >/dev/null && git config user.email >/dev/null; then
  git commit -q -m "chore: start the project from tateru ${version:+v$version}" &&
    echo "Started fresh: a new git history with one first commit, from tateru ${version:+v$version}."
else
  echo "Started fresh: a new git history, with everything staged. Git has no name and email set yet, so nothing is committed."
fi
echo "Every file is where it was. The folder is not linked to any GitHub repository yet."
exit 0
