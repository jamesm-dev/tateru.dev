#!/usr/bin/env bash
# SessionStart hook.
# Two jobs, both up front rather than on first failure:
#   1. Report whether the Obsidian MCP is installed and has a vault covering each
#      vault folder, with the exact command to fix it if not.
#   2. Audit every existing note against the vault contract, catching drift from
#      edits made outside Claude, which no tool hook can see.
# Always exits 0. Emits only fixed strings, integers, and file paths.
set -u

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$root" 2>/dev/null || exit 0
# Git Bash reports /c/Users/...; the MCP config stores C:/Users/... Normalise to the
# Windows form so the two compare equal and the printed command is one a user can run.
root=$(printf '%s' "$root" | sed 's#\\#/#g; s#^/\([a-zA-Z]\)/#\1:/#')

VALIDATOR="$root/.claude/hooks/validate-vault-note.sh"
lines=""
add() { lines="$lines$1\\n"; }

# --- 1. Obsidian MCP readiness ----------------------------------------------
installed=no
for f in "$root/.mcp.json" "$HOME/.claude.json" "$HOME/.claude/settings.json" "$root/.claude/settings.json"; do
  [ -f "$f" ] || continue
  grep -qi 'obsidian' "$f" && { installed=yes; break; }
done

covered() {
  command -v node >/dev/null 2>&1 || { echo unknown; return; }
  node -e '
    const fs=require("fs"),p=require("path");
    const want=process.argv[1].toLowerCase();
    let hit=false;
    const check=(cfg)=>{ if(!cfg||!cfg.mcpServers) return;
      for(const [k,v] of Object.entries(cfg.mcpServers)){
        if(!/obsidian/i.test(k)) continue;
        const blob=[...(v.args||[]),...Object.values(v.env||{})].join(" ").replace(/\\/g,"/").toLowerCase();
        if(blob.includes(want)) hit=true;
      }};
    for(const f of [p.join(process.argv[2],".mcp.json"),p.join(process.argv[3],".claude.json")]){
      try{ const c=JSON.parse(fs.readFileSync(f,"utf8")); check(c);
        if(c.projects) for(const v of Object.values(c.projects)) check(v);
      }catch(e){}
    }
    process.stdout.write(hit?"yes":"no");
  ' "$1" "$root" "$HOME" 2>/dev/null || echo unknown
}

missing=""
for folder in .idea .management; do
  [ -d "$folder" ] || continue
  if [ "$installed" = "no" ]; then
    missing="$missing $folder"
  elif [ "$(covered "$root/$folder")" = "no" ]; then
    missing="$missing $folder"
  fi
done

if [ "$installed" = "no" ]; then
  add "[vault] The Obsidian MCP is NOT installed. Markdown in .idea/ and .management/ cannot be written until it is."
  add "[vault] Tell the user to run, in an interactive session:"
  for folder in .idea .management; do
    [ -d "$folder" ] || continue
    id=$(printf '%s' "$folder" | sed 's#^\.##')
    add "[vault]   claude mcp add obsidian -s user -- npx -y obsidian-mcp@2 serve --vault $id=$root/$folder"
  done
  add "[vault] Claude cannot install it or run an OAuth flow on the user behalf. Do not fall back to Write or Edit."
elif [ -n "$missing" ]; then
  add "[vault] The Obsidian MCP is installed, but no vault covers:$missing"
  add "[vault] Markdown there cannot be written until a vault is registered. Tell the user to re-add the server keeping existing --vault flags and adding:"
  for folder in $missing; do
    id=$(printf '%s' "$folder" | sed 's#^\.##')
    add "[vault]   --vault $id=$root/$folder"
  done
  add "[vault] The folder must be the vault ROOT, since Obsidian ignores dot-prefixed folders."
else
  add "[vault] Obsidian MCP ready. Write notes with obsidian_create_note / obsidian_edit_note, never Write or Edit."
fi

# --- 2. Audit existing notes -------------------------------------------------
if [ -x "$VALIDATOR" ] || [ -f "$VALIDATOR" ]; then
  total=0
  n=0
  bad=""
  # NUL-delimited: note filenames are Title Case With Spaces, so a word-split
  # loop would count fragments instead of files.
  while IFS= read -r -d '' f; do
    total=$((total+1))
    if ! bash "$VALIDATOR" --check "$f" >/dev/null 2>&1; then
      n=$((n+1))
      bad="$bad | $f"
    fi
  done < <(find .idea .management -name '*.md' -print0 2>/dev/null | sort -z)
  if [ -n "$bad" ]; then
    add "[vault] $n of $total existing notes FAIL the vault contract:$bad"
    add "[vault] Run: bash .claude/hooks/validate-vault-note.sh --check <file> to see why, and offer to fix them."
  elif [ "$total" -gt 0 ]; then
    add "[vault] All $total notes in .idea/ and .management/ satisfy the vault contract."
  fi
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"},"suppressOutput":true}\n' "$lines"
exit 0
