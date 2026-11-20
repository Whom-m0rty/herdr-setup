# herdr + Today

A small, no-model, no-token cockpit for running many Claude Code sessions at once in
[herdr](https://herdr.dev) (a terminal workspace manager for coding agents).

- **Today**: an interactive tree in a herdr pane. It shows your tasks from a plain `~/todo.md`, the Claude
  sessions that worked on each task, and what every open session needs from you: *needs you* (a question or a
  permission prompt), *working*, *paused*, or *can close*. It also lists follow-ups that sessions promised and
  background jobs. One key starts a new Claude session on a task, and that task's line gets tagged with the
  session.
- **Session briefs**: every Claude session keeps a short status file (`name / status / progress / eta / next /
  promises`). Today, the herdr sidebar and a *brief* pane next to each session read it, so you can switch
  between ten agents and see at a glance where each one stopped.
- **job**: runs long commands (tests, builds) in a visible pane. When the job ends it notifies you and wakes the
  agent that started it.
- **todayctl**: the same actions from the command line, so Claude itself can add, tick or start tasks for you.
- A herdr config with Option-key shortcuts (Russian-layout twins included), status colours that work in Apple
  Terminal, and sidebar rows that show each agent's verdict, progress bar and ETA.

Everything is plain Python 3 standard library plus the `herdr` and `claude` CLIs. Nothing calls a model; the
scripts only read files and talk to herdr's local socket.

```
┌ Today ──────────────────────────────────────────────────────────────────────────────┐
│ Today  09:10  [↻ refresh]                                                            │
│ Disk 120 GB free (48%)                                                               │
│ ▾ Today (# Now)  · 3                                                                 │
│ ▸ 1 Write the blog post about the new backup setup #writing  ● working               │
│ ▸ 2 Fix the flaky photo-sync script #home  due 2026-11-25  ● needs you: answer       │
│ ▸ 3 Read chapter 4 of the compilers book #study                                      │
│ ▾ Open sessions: 1 need you · 1 working · 2 can close  · 4                           │
│   ● needs you: answer  Photo-sync script fix  ████░░░░░░ 40% · ~1 h  next: wait for… │
│   ● working  Blog post: backup setup  ██████░░░░ 60% · ~30 min  next: write the res… │
│   ● can close: 2d idle  Local LLM note search  ██████████ 100% · done                │
│   ● can close: task done  Dotfiles repo  ██████████ 100% · done                      │
│ ▾ Follow-ups from sessions (a add to todo · h hide)  · 2                             │
│   ☐ write a short README for the dotfiles repo  from Dotfiles repo                   │
│   ☐ send the draft to a friend for a proofread  from Blog post: backup setup         │
│   → 4 more tasks in Next / Waiting: e opens the full tree                            │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

## Requirements

- macOS (tested on macOS 15). Linux should work for everything except `kbd-remap.sh` and the `open -e` used
  to show job logs.
- [herdr](https://herdr.dev) 0.9 or newer (`brew install herdr`), running, with its CLI on `PATH`.
- [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude` on `PATH`).
- Python 3.9 or newer (`python3`; tested with 3.14). Only the standard library is used (`curses` included).
- Optional: `fzf` for the `chats` session picker.
- Terminal:
  - **iTerm2** (recommended): true colour works. Set *Profiles → Keys → Right Option key* to **Esc+**, so the
    right Option key sends the `alt+…` shortcuts and the left one still types `#`, `€`, etc.
  - **Apple Terminal**: it drops 24-bit colours, so the config uses herdr's `terminal` theme (ANSI colours).
    Turn on *Settings → Profiles → Keyboard → Use Option as Meta key* (this takes both Option keys).

## Install

```sh
git clone <this repo> ~/herdr-setup && cd ~/herdr-setup
./install.sh            # links bin/* into ~/bin and installs the herdr config (backs up an existing one)
```

Or by hand: put `bin/` on your `PATH` (or symlink its files into `~/bin`) and copy
`config/herdr/config.toml` to `~/.config/herdr/config.toml`. The scripts find each other through their own
folder, so the repo can live anywhere.

Then:

1. Create `~/todo.md` (format below; `examples/todo.md` is a start).
2. Add the [CLAUDE.md snippet](#claudemd-snippet) to `~/.claude/CLAUDE.md`, so sessions keep their briefs.
3. Start herdr, then run `herdr-layout` inside it. It builds a **Today** workspace (Claude on the left,
   `today all` on the right), one workspace per `#area` in your todo.md, and a **Chats** workspace.
   Run it again after a reboot; it only adds what is missing.
4. `herdr server reload-config` after changing the config.

Try it first without touching your own files: `examples/demo.sh` runs `todayctl status`, `todo-view` and a
brief pane on the sample data, and `examples/demo.sh today` opens the interactive tree on it (`q` quits).

### Settings (environment, all optional)

| variable          | default               | what                                              |
|-------------------|-----------------------|---------------------------------------------------|
| `TODAY_TODO`      | `~/todo.md`           | the task list                                     |
| `TODAY_HOME`      | `~/.cache/today`      | state: `briefs/`, `jobs/`, open/closed tree state |
| `TODAY_PROJECT`   | `~`                   | folder new Claude sessions start in               |
| `CLAUDE_PROJECTS` | `~/.claude/projects`  | Claude Code transcripts                           |

Set them in your shell profile (`~/.zshrc`), not only in one shell: herdr panes start fresh login shells.

## What is in here

| file                        | what it does |
|-----------------------------|--------------|
| `bin/today`                 | the interactive tree (curses). `today all` = home screen, sidebar reporting, brief panes; `today <area>` = one area |
| `bin/todayctl`              | command-line twin of Today's keys (`todayctl --help`) |
| `bin/todo-view`             | read-only live view of todo.md (`--once` prints and exits); also the todo.md parser |
| `bin/brief`                 | the pane next to each Claude session: name, verdict, task, brief, last exchange |
| `bin/agent-close`           | closes a session pane after asking it to update its brief; refuses with uncommitted git changes |
| `bin/job`                   | long jobs in a visible pane, notification + agent wake-up at the end |
| `bin/chats`                 | index and fzf picker of past Claude Code sessions (`claude --resume`) |
| `bin/agentlib`              | shared helpers: paths, herdr calls, brief parser, verdict |
| `bin/herdr-layout`          | builds the workspaces |
| `bin/kbd-remap.sh`          | swaps Alt/Win on Windows-layout keyboards, per device (`hidutil`) |
| `config/herdr/config.toml`  | herdr theme, keys, sidebar rows |
| `examples/`                 | sample todo.md, briefs, transcripts, a fake `herdr`, and `demo.sh` |

## Keys

### herdr (from `config.toml`; Option = the right Option key in iTerm2)

| key | action |
|-----|--------|
| `⌥1` … `⌥9` | go to tab 1…9 |
| `⌥[` / `⌥]` | previous / next tab |
| `⌥Tab` / `⌥⇧Tab` | next / previous agent (across workspaces) |
| `⌥w` | workspace picker |
| `⌥o` | jump to the pane of the last notification |
| `⌥z` | zoom the pane |
| `⌥b` | hide / show the sidebar |
| `⌥←↑→↓` | move between panes |

Each letter key also works on the Russian layout (`⌥ц` = `⌥w`, `⌥х` = `⌥[` …). All other herdr keys stay
on their default `ctrl+b` prefix.

### Today

| key | action |
|-----|--------|
| `Enter` / `→` / click | open or close a row; on a session: go to it (or resume it); on `[+ new session]`: start one |
| `←` | close the row, or jump to its parent |
| `e` | home screen ↔ full tree (areas → tasks → sessions) |
| `n` | new Claude session for the selected task |
| `s` | quick-question session, not tied to a task |
| `g` | jump to the next session that needs you |
| `c` | close the selected session (it updates its brief first) |
| `a` | add a task (on a follow-up: add it to `# Next`) |
| `h` | hide the selected follow-up |
| `x` / `u` | tick the task (to `# Done` with today's date) / undo |
| `m` | move a task between `# Now` and `# Next` |
| `p` | plan the day: tick what goes into `# Now` |
| `r` / `q` | reload / quit (the pane loop restarts it) |

Letters work on the Russian layout too. In a brief pane: `c` close after handoff, `C` close now, `f` full
last reply.

### Session verdicts

| verdict | when |
|---------|------|
| `needs you: permission` | herdr says the agent is blocked (a permission prompt) |
| `needs you: answer` | Claude's last message ends with a question (less than 12 h ago) |
| `working` | herdr says the agent is working |
| `paused 2h · uncommitted` | idle, and the pane's folder has uncommitted git changes |
| `can close: task done` | the session's task line is ticked |
| `can close: quick, 40m idle` | a quick session idle for over 30 minutes |
| `can close: 2d idle` | idle for over a day |
| `paused 2h` | anything else |

## todo.md format

```markdown
# Now
- [ ] Fix the flaky photo-sync script #home due 2026-11-25 [s:b2c3d4e5]

# Next
- [ ] Try a local LLM for note search #home [s:c3d4e5f6]
- [ ] Renew the passport due 2026-12-15

# Waiting
- Plumber to confirm a date for the boiler check #home

# Done
- [x] Move the dotfiles into one git repo #home [s:d4e5f6a7] (2026-11-18)
```

- Sections: `# Now` (today's plan), `# Next`, `# Waiting` (plain `- ` lines are fine there), `# Done`.
- One task per line. `#area` (first one wins) groups tasks and picks the herdr workspace their sessions open
  in (`#home` → workspace "Home"; no tag → "Tasks").
- `due YYYY-MM-DD` shows a due date (red when late).
- `[s:<first 8 chars of a session id>]` links a Claude session to the task. Today adds it when you start a
  session with `n`; a session adds it itself when it works on a task (see the CLAUDE.md snippet).
- Ticking (`x`) moves the line to `# Done` with today's date. You can edit the file by hand at any time;
  Today redraws when it changes.

## Session brief format

Each session keeps `~/.cache/today/briefs/<first 8 chars of its session id>.md`, overwritten at every
milestone (it is the current state, not a log):

```
name: Photo-sync script fix          (2-5 words, under 40 characters)
task: what this session is for, one sentence
status: where it stands now, one sentence; start with what it is doing ("running tests", "needs a decision")
progress: 40                          (0-100; the sidebar draws a bar)
eta: ~1 h                             (time to the next milestone)
done:
- the main things finished
next: the very next step, one sentence
waiting: who or what we wait on, or "nothing"
promises:
- things promised to someone that are not in todo.md yet (Today shows them as follow-ups)
```

The herdr sidebar shows the bar, the ETA and the first ~30 characters of `status:`.

## CLAUDE.md snippet

Paste into `~/.claude/CLAUDE.md` (adjust to taste):

```markdown
# herdr

When `HERDR_ENV=1` (running inside herdr), start reviewers, second-opinion agents and long jobs (tests,
builds, data runs) as visible herdr panes next to the current one, so I can watch and type into them. Use
hidden subagents only for quick read-only lookups.

For a long job (test suite, build, data run, anything over ~2 minutes) use
`job "<label>" [--cwd DIR] -- <command>`: it runs in a visible pane in the Jobs workspace, logs to
~/.cache/today/jobs/, notifies me at the end, and prompts this session with the exit code when it is idle.
So start the job, tell me what runs, and end the turn instead of waiting on it.

# My to-do list: ~/todo.md

Sections `# Now`, `# Next`, `# Waiting`, `# Done`. One task per line:

    - [ ] Fix the flaky photo-sync script #home due 2026-11-25 [s:b2c3d4e5]

- `#area` = which area the task belongs to (first tag wins).
- `[s:<first 8 chars of a session id>]` = a Claude session that worked on the task. When I work on a task from
  this list in a session, add the current session's tag to that line once (the session id is the newest
  file name in `~/.claude/projects/<project>/`).
- Ticked item: move it to `# Done` with today's date. Optional deadline at the end: `due 2026-11-20`.

# Session brief (read by Today, the herdr sidebar and the brief pane)

Every session that does real work (not a one-answer question) keeps a short brief at
`~/.cache/today/briefs/<first 8 chars of the session id>.md`, so I can switch between many agents and pick up
a closed session later. Write it after the first real step and update it at every milestone: plan agreed,
change made, tests run, blocked, decision made, and when I say I am closing the session. Overwrite it (it is
the current state, not a log); max ~15 lines; plain English; no secrets.

    name: Photo-sync script fix     (2-5 words; under 40 characters)
    task: what this session is for, one sentence
    status: where it stands now, one sentence (e.g. "running tests", "needs a decision: A or B")
    progress: 60      (0-100: honest estimate of how far this session's task is; the sidebar draws a bar)
    eta: ~40 min      (time to the next milestone I care about)
    done:
    - the main things finished
    next: the very next step, one sentence
    waiting: who or what we wait on, or "nothing"
    promises:
    - things promised to a person that are not in ~/todo.md yet

The sidebar shows the bar + eta and the first ~30 characters of `status:`, so start `status:` with what the
session is doing now. Update `progress:` and `eta:` at every brief update.

# Today from chat

When I ask in a chat to add, move, tick or undo a task, start or close a session, or jump to one, use
`todayctl` (`todayctl --help`); it does exactly what the Today keys do, on the same files, and the Today pane
redraws by itself. `todayctl status` shows open sessions, the task list and follow-ups.
```

## How it fits together

- `today all` polls every 2 seconds: `herdr agent list` (open Claude panes and their state), the todo file,
  and the brief files. It pushes `$name`, `$verdict`, `$progress`, `$eta`, `$doing` per pane and `$work` per
  workspace to the herdr sidebar (`herdr pane/workspace report-metadata`), and opens a `brief` pane to the
  right of any Claude pane that has none. Run only one `today all`.
- `n` creates a session id, tags the task line with it, writes a short context file (the task, the last brief
  of an earlier session on the same task, links to earlier transcripts) and starts
  `claude --session-id <id> --append-system-prompt-file <file>` in a new tab of the task's area workspace.
- A verdict needs no model: herdr's agent state, the end of the session transcript, git status of the pane's
  folder, and the todo file.

## License

MIT, see `LICENSE`.
