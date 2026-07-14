#!/usr/bin/env bash
# Report (do NOT auto-apply) which installed skills' upstream repos moved since last check. Report-only.
set -u
MAN="$HOME/.claude/skills/_upstream.json"
[ -f "$MAN" ] || { echo "no manifest at $MAN"; exit 0; }
echo "Skill upstream check ($(date -u +%F)):"
python3 - "$MAN" <<'PY'
import json,sys,subprocess
man=json.load(open(sys.argv[1]))
changed=0
for name,info in man.get("skills",{}).items():
    repo=info["repo"]; br=info.get("branch","HEAD"); last=info["last_sha"]
    try:
        out=subprocess.run(["git","ls-remote",repo,br],capture_output=True,text=True,timeout=30).stdout
        cur=out.split()[0] if out.strip() else ""
    except Exception:
        cur=""
    if not cur:
        print(f"  ? {name} — could not reach {repo}"); continue
    if cur!=last:
        print(f"  ⬆ {name}  UPDATED  {last[:10]} → {cur[:10]}")
        print(f"       compare: {repo}/compare/{last}...{cur}")
        changed+=1
    else:
        print(f"  ✓ {name}  up to date ({cur[:10]})")
print()
if changed:
    print(f"{changed} skill(s) have upstream updates — REVIEW the compare diff before refreshing (untrusted code).")
    print("On approval: re-fetch the skill files, bump last_sha in _upstream.json, re-copy to Library/assets/skills/<name>/.")
else:
    print("All skills up to date.")
PY
