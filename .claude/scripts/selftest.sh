#!/usr/bin/env bash
# Self-test for tateru's own machinery: the git hooks, the Claude hooks, and the
# scripts. CI runs it on every push; run it locally before changing any of them:
#
#   bash .claude/scripts/selftest.sh
#
# A rule that only exists in prose is not a rule — this is where the hooks'
# promises become checks. It needs bash, git, grep, sed and mktemp; shellcheck
# and sqlite3 are used when installed and skipped (and said so) when not.
#
# Exit 0 when everything passes, 1 when anything fails.
set -u

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "selftest: not in a git repository" >&2; exit 1; }
cd "$root" || exit 1

pass=0 fail=0
ok()   { pass=$((pass + 1)); printf '  ok    %s\n' "$1"; }
bad()  { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }
skip() { printf '  skip  %s\n' "$1"; }
check() { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

# One line, space-separated: check() evals its command, and eval reads a newline
# as the end of a command.
scripts=$(git ls-files .githooks .claude/hooks .claude/scripts | grep -v '\.md$' | tr '\n' ' ')

echo "Scripts"
for f in $scripts; do
  check "$f parses" "bash -n '$f'"
  check "$f is executable in git" "git ls-files -s '$f' | grep -q '^100755'"
  check "$f has LF line endings" "! grep -q \$'\\r' '$f'"
done
if command -v shellcheck >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  check "shellcheck finds no warnings" "shellcheck -S warning $scripts"
else
  skip "shellcheck not installed"
fi

echo "Docs"
# The sync rule in CLAUDE.md, made checkable: every command is listed where a
# reader would look for it. Not README.md: in a cloned project that is the
# project's own file.
for c in .claude/commands/*.md; do
  name=$(basename "$c" .md)
  check "/$name is in CLAUDE.md" "grep -q '\[/$name\]' CLAUDE.md"
  [ -f ".claude/skills/$name/SKILL.md" ] && check "/$name is in AGENTS.md" "grep -q '\`/$name\`' AGENTS.md"
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# Test the working tree, not the last commit: /upgrade leaves its changes
# uncommitted and runs this to verify them. Copy every tracked and untracked
# (not ignored) file, keeping executable bits, into a fresh repository.
mkdir -p "$tmp/repo"
git ls-files -z --cached --others --exclude-standard \
  | while IFS= read -r -d '' f; do
      [ -e "$f" ] || continue
      mkdir -p "$tmp/repo/$(dirname "$f")"
      cp -p "$f" "$tmp/repo/$f"
    done
cd "$tmp/repo" || exit 1
git init -q
git -c core.hooksPath=/dev/null -c user.name=selftest -c user.email=selftest@example.com \
  -c core.fileMode=true add -A >/dev/null 2>&1
git -c core.hooksPath=/dev/null -c user.name=selftest -c user.email=selftest@example.com \
  commit -q -m "selftest snapshot" >/dev/null 2>&1
git config core.hooksPath .githooks
git config user.name selftest
git config user.email selftest@example.com
git config advice.ignoredHook true

echo "Git hooks"
check "a commit with no task id succeeds" "git commit -q --allow-empty -m 'plain change'"
check "post-commit appends to commits.jsonl" "[ \"\$(wc -l < .management/commits.jsonl)\" -eq 1 ]"
git commit -q --allow-empty -m "$(printf 'tab\there TSK-ABC123 ADH-3c81 "quoted"')" >/dev/null 2>&1
line=$(tail -1 .management/commits.jsonl 2>/dev/null)
check "task ids are recorded lowercase" "printf '%s' '$line' | grep -q '\"tasks\":\\[\"adh-3c81\",\"tsk-abc123\"\\]'"
check "control characters never reach commits.jsonl" "! printf '%s' \"\$(tail -1 .management/commits.jsonl)\" | grep -q \$'\\t'"
if command -v python3 >/dev/null 2>&1; then
  check "every commits.jsonl line is valid JSON" "python3 -c 'import json,sys; [json.loads(l) for l in open(sys.argv[1])]' .management/commits.jsonl"
else
  skip "python3 not installed, JSON validity not checked"
fi
printf '{"tasks":[{"ref":"tsk-111111"}]}\n' > .management/state.json
check "a known TSK id is accepted" "git commit -q --allow-empty -m 'TSK-111111 known'"
check "an unknown TSK id is rejected" "! git commit -q --allow-empty -m 'TSK-999999 unknown'"
mkdir -p .idea/epics
printf -- '- [ ] Added by /epic after the last /setup (2 pts) ^tsk-222222\n' > ".idea/epics/New Epic.md"
check "a TSK id that only exists in an epic is accepted" "git commit -q --allow-empty -m 'TSK-222222 from epic'"
rm -rf .idea/epics
if command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 .management/board.db "CREATE TABLE task_authored(task_id TEXT); INSERT INTO task_authored VALUES('ADH-3C81');"
  check "a known ADH id is accepted" "git commit -q --allow-empty -m 'ADH-3c81 known'"
  check "an unknown ADH id is rejected" "! git commit -q --allow-empty -m 'ADH-ffff unknown'"
else
  skip "sqlite3 not installed, ADH lookups not checked"
fi
mkdir -p app .claude/team
printf 'LINT="true"\nTEST="true"\n' > .claude/team/checks.env
check "pre-push passes when the checks pass" "sh .githooks/pre-push"
printf 'LINT="false"\n' > .claude/team/checks.env
check "pre-push blocks when a check fails" "! sh .githooks/pre-push"
rm -rf app .claude/team

echo "Claude hooks"
validator=.claude/hooks/validate-vault-note.sh
good=$(find .management/design -name '*.md' | head -1)
check "the validator passes a shipped note" "bash $validator --check '$good'"
mkdir -p .idea/notes
printf '# One\n\n# Two\n' > ".idea/notes/Broken Note.md"
check "the validator rejects a note with no frontmatter" "! bash $validator --check '.idea/notes/Broken Note.md'"
check "the session audit names the broken note" "bash .claude/hooks/vault-preflight.sh | grep -q 'Broken Note'"
rm ".idea/notes/Broken Note.md"
note() { # note <path> <body...>: a note with valid frontmatter, so only the body is under test
  t=$(basename "$1" .md)
  { printf -- '---\ntitle: %s\ncreated: 2026-01-01\nupdated: 2026-01-01\ntags: [test]\nstatus: %s\n---\n\n# %s\n\n' "$t" "$2" "$t"; shift 2; printf '%s\n' "$@"; } > "$1"
}
note ".idea/notes/Code Sample.md" seed '```bash' '# install' '#include <x>' '```'
check "a comment inside a code block is not a heading" "bash $validator --check '.idea/notes/Code Sample.md'"
note ".idea/notes/Two Headings.md" seed '# Another'
check "a real second H1 is still rejected" "! bash $validator --check '.idea/notes/Two Headings.md'"
note ".idea/notes/Wrong Heading.md" seed
sed -i.bak 's/^# Wrong Heading$/# Something Else/' ".idea/notes/Wrong Heading.md"
check "an H1 that differs from the title is rejected" "bash $validator --check '.idea/notes/Wrong Heading.md' | grep -q 'does not match the frontmatter title'"
mkdir -p .idea/epics
note ".idea/epics/Pointed.md" planned '- [ ] The document reopens after a restart (3 pts) ^tsk-4b91c2'
check "the /epic example criterion passes" "bash $validator --check '.idea/epics/Pointed.md'"
note ".idea/epics/Unpointed.md" planned '- [ ] The document reopens after a restart ^tsk-4b91c2'
check "a criterion with no points is rejected" "bash $validator --check '.idea/epics/Unpointed.md' | grep -q 'no points'"
rm -rf .idea/epics .idea/notes/*.md .idea/notes/*.bak
# A clean vault built here, so the project's own notes - which the session
# audit reports on separately - never decide this check.
clean="$tmp/clean"
mkdir -p "$clean/.idea" "$clean/.management"
cp -R .claude "$clean/"
cp -R .management/design "$clean/.management/"
for f in .management/README.md .management/DESIGN.md .idea/README.md; do [ -f "$f" ] && cp "$f" "$clean/$f"; done
check "the session audit passes a clean vault" "CLAUDE_PROJECT_DIR='$clean' bash .claude/hooks/vault-preflight.sh | grep -q 'satisfy the vault contract'"
mkdir -p app
git config --unset core.hooksPath
check "the session audit warns about unwired hooks" "bash .claude/hooks/vault-preflight.sh | grep -q 'not wired'"
git config core.hooksPath .githooks
rmdir app
check "the prompt hook reports the vault" "bash .claude/hooks/idea-context.sh </dev/null | grep -q 'SPECS.md'"

echo "Workflow contracts"
check "CLAUDE.md marks the before-setup block for /setup to replace" "grep -q '<!-- tateru:before-setup -->' CLAUDE.md && grep -q '<!-- /tateru:before-setup -->' CLAUDE.md"
git remote add origin https://github.com/jamesm-dev/tateru.dev.git 2>/dev/null
up=$(git remote -v | awk '/jamesm-dev\/tateru\.dev/ { print $1; exit }')
check "/upgrade finds the tateru remote when it is called origin" "[ '$up' = origin ]"
git remote remove origin 2>/dev/null

echo "Scripts that need a built app"
bash .claude/scripts/dashboard-conformance.sh >/dev/null 2>&1
check "dashboard-conformance exits 2 with nothing built" "[ $? -eq 2 ]"

echo
echo "selftest: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
