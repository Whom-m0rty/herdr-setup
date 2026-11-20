#!/bin/sh
# Run todo-view, todayctl and brief against the sample data in this folder, never your real todo.md or briefs.
# Everything is copied to a temporary folder first, so the demo can tick tasks without changing the repo.
#   examples/demo.sh                 status + task view + one brief pane
#   examples/demo.sh todayctl done photo-sync   any todayctl command on the sample data
#   examples/demo.sh today           the interactive tree on the sample data (q quits)
set -e
here=$(cd "$(dirname "$0")" && pwd)
bin="$here/../bin"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$here/todo.md" "$tmp/todo.md"
mkdir -p "$tmp/state/briefs" "$tmp/claude/demo"
cp "$here"/briefs/*.md "$tmp/state/briefs/"
cp "$here"/claude-projects/demo/*.jsonl "$tmp/claude/demo/"
# Make the sample sessions look their age: the question was asked 20 minutes ago, the note-search session has
# been idle for two days, the dotfiles one for an hour.
touch -t "$(date -v-20M +%Y%m%d%H%M)" "$tmp"/claude/demo/b2c3d4e5-*.jsonl
touch -t "$(date -v-2d +%Y%m%d%H%M)" "$tmp"/claude/demo/c3d4e5f6-*.jsonl
touch -t "$(date -v-1H +%Y%m%d%H%M)" "$tmp"/claude/demo/d4e5f6a7-*.jsonl
export TODAY_TODO="$tmp/todo.md" TODAY_HOME="$tmp/state" CLAUDE_PROJECTS="$tmp/claude" CHATS_CACHE="$tmp/chats"
export PATH="$here/fake-bin:$PATH"
unset HERDR_ENV HERDR_PANE_ID
if [ $# -gt 0 ]; then
  cmd=$1; shift
  "$bin/$cmd" "$@"
  [ "$cmd" = todayctl ] && { echo; echo "--- todo.md after the command ---"; cat "$tmp/todo.md"; }
  exit 0
fi
echo '$ todayctl status'; "$bin/todayctl" status
echo; echo '$ todo-view all --once'; "$bin/todo-view" all --once
echo; echo '$ brief b2c3d4e5-... --once'; COLUMNS=70 "$bin/brief" b2c3d4e5-0000-4000-8000-000000000002 --once
