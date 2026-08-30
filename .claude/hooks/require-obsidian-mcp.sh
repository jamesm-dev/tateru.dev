#!/usr/bin/env bash
# PreToolUse hook on Write|Edit.
# Markdown inside .idea/ and .management/ must be written through the Obsidian MCP,
# never with a raw Write or Edit. This denies the direct call and returns the exact
# next step, which differs depending on how far the MCP is set up:
#
#   1. MCP not configured        -> stop and have the user install it
#   2. MCP configured, no vault  -> stop and have the user register the vault
#   3. MCP and vault ready       -> use the obsidian_* tools instead
#
# Every path outside those two folders is allowed through untouched.
set -u

input=$(cat 2>/dev/null || true)

fp=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$fp" ] && exit 0
fp=$(printf '%s' "$fp" | sed 's#\\\\#/#g; s#\\#/#g')

case "$fp" in
  *.md|*.MD) ;;
  *) exit 0 ;;
esac

case "$fp" in
  */.idea/*|.idea/*)             folder=".idea";       suggested="idea" ;;
  */.management/*|.management/*) folder=".management"; suggested="management" ;;
  *) exit 0 ;;
esac

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
# Git Bash reports /c/Users/...; the MCP config stores C:/Users/... Normalise to the
# Windows form so the two compare equal and the printed command is one a user can run.
root=$(printf '%s' "$root" | sed 's#\\#/#g; s#^/\([a-zA-Z]\)/#\1:/#')

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

# --- Is an Obsidian MCP server configured at all? ----------------------------
installed=no
for f in "$root/.mcp.json" "$HOME/.claude.json" "$HOME/.claude/settings.json" "$root/.claude/settings.json"; do
  [ -f "$f" ] || continue
  grep -qi 'obsidian' "$f" && { installed=yes; break; }
done

if [ "$installed" = "no" ]; then
  deny "Markdown in $folder must be written through the Obsidian MCP, but no Obsidian MCP server is configured.\\n\\nSTOP. Do not fall back to Write or Edit, and do not work around this.\\n\\nTell the user to install it, in an interactive session:\\n  claude mcp add obsidian -s user -- npx -y obsidian-mcp@2 serve --vault $suggested=$root/$folder\\n\\nOr run /mcp to manage servers. Claude cannot run the install or an OAuth flow on the user behalf. Once it is installed and the session has reloaded, retry using mcp__obsidian__obsidian_create_note or mcp__obsidian__obsidian_edit_note."
fi

# --- Is a vault registered that actually covers this folder? -----------------
vault_ok=unknown
if command -v node >/dev/null 2>&1; then
  vault_ok=$(node -e '
    const fs=require("fs"),p=require("path");
    const want=process.argv[1].toLowerCase();
    // Home comes from bash, not os.homedir(): on Windows those can differ.
    const files=[p.join(process.argv[2],".mcp.json"),p.join(process.argv[3],".claude.json")];
    let hit=false;
    const check=(cfg)=>{ if(!cfg||!cfg.mcpServers) return;
      for(const [k,v] of Object.entries(cfg.mcpServers)){
        if(!/obsidian/i.test(k)) continue;
        const blob=[...(v.args||[]),...Object.values(v.env||{})].join(" ").replace(/\\/g,"/").toLowerCase();
        if(blob.includes(want)) hit=true;
      }};
    for(const f of files){ try{ const c=JSON.parse(fs.readFileSync(f,"utf8")); check(c);
      if(c.projects) for(const v of Object.values(c.projects)) check(v);
    }catch(e){} }
    process.stdout.write(hit?"yes":"no");
  ' "$root/$folder" "$root" "$HOME" 2>/dev/null) || vault_ok=unknown
fi

if [ "$vault_ok" = "no" ]; then
  deny "Markdown in $folder must be written through the Obsidian MCP. The MCP is installed, but no vault is registered that covers $folder, so the tools cannot reach this file.\\n\\nSTOP. Do not fall back to Write or Edit.\\n\\nTell the user to register it, in an interactive session:\\n  claude mcp remove obsidian -s user\\n  claude mcp add obsidian -s user -- npx -y obsidian-mcp@2 serve --vault $suggested=$root/$folder\\n\\nKeep any existing --vault flags and add this one alongside them. $folder must be the vault ROOT, because Obsidian ignores folders whose name starts with a dot. After the session reloads, run mcp__obsidian__obsidian_list_vaults to confirm, then use mcp__obsidian__obsidian_create_note or obsidian_edit_note."
fi

# --- Configured and reachable: route through the MCP -------------------------
rel=$(printf '%s' "$fp" | sed "s#.*/$folder/##")
deny "Write and Edit are not allowed on Markdown inside $folder. Use the Obsidian MCP so the note goes through the vault index.\\n\\nUse mcp__obsidian__obsidian_create_note for a new note, or mcp__obsidian__obsidian_edit_note for an existing one. Read it first with mcp__obsidian__obsidian_read_note and pass its etag when editing.\\n\\nCall obsidian_list_vaults if the vault id is unknown. The path is relative to the vault root, so for this file it is: $rel\\n\\nThe note must still satisfy .claude/skills/shared/vault-contract.md."
