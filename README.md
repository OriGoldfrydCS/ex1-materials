# TA Session 1: your workspace

Practice terminal navigation, Git, and a simulated agent loop. Then draft your project topic.

Use **Ubuntu (WSL)** on Windows or **Terminal with Bash** on macOS.
Run one command at a time and read its output. Do not include a prompt symbol such as `$`.

## Requirements

Use the tools from the course's existing setup instructions: Bash, Git (2.28+),
curl, and standard command-line utilities. No Python packages, model download,
AI subscription, or API key is needed for these games. The agent game is scripted.
Use any text editor for the Markdown files; VS Code is optional.

## 1. Terminal Treasure Hunt (10 minutes)

```bash
cd ~
curl -fLO https://raw.githubusercontent.com/OriGoldfrydCS/ex1-materials/main/setup_treasure.sh
bash ~/setup_treasure.sh
cd ~/treasure
cat README.txt
```

Follow the clues. Finish when `golden_key.txt` is in `~/treasure/done` and no longer
in `~/treasure/mountain`. Explain which command moved it.

## 2. Git Quest (15 minutes)

```bash
cd ~
curl -fLO https://raw.githubusercontent.com/OriGoldfrydCS/ex1-materials/main/setup_git_quest.sh
bash ~/setup_git_quest.sh
cd ~/git-quest
cat START-HERE.txt
```

Follow all four levels. Finish with:

```bash
bash ~/git-quest-check.sh
```

The checker must print `ALL LEVELS DONE`. Also explain `git add`, `git commit`,
`git diff`, and `git restore` to your neighbor. The checker checks the final state;
it cannot prove which commands you typed.

If a commit says `Author identity unknown`, set your identity in the game repository:

```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

Replace the example values with your own. Retry the commit. These settings are local
to the current repository. If your project later needs them, configure them there too.

## 3. Be the Harness (12 minutes, followed by discussion)

```bash
cd ~
curl -fLO https://raw.githubusercontent.com/OriGoldfrydCS/ex1-materials/main/setup_agent_loop.sh
bash ~/setup_agent_loop.sh
cd ~/agent-loop
cat START-HERE.txt
```

Start with `bash llm.sh`. You play the harness (run approved commands) and the human
(check requests and results). Refuse with `bash llm.sh no` **without running the request**.
Finish when `bash check.sh` reports `PASS` and you can explain the error and your check.
A model's `DONE` claim alone does not establish correctness.

The setup creates `llm.sh` and `check.sh`; you do not download those separately.
Similarly, Git Quest creates `~/git-quest-check.sh` for you.

## 4. Project topic and disclosure

You can answer the three questions directly in the Markdown template, or use
the [browser form](proposal-form.html). On GitHub, choose **Download raw file** for
`proposal-form.html`, then open the downloaded file in your browser. Fill it in and
choose **Download proposal-draft.md**. Move that file into your project's `docs`
folder. The form saves a file on your device; it does not collect submissions centrally.

Use a new course project folder. These commands also work if the folder already exists.
If it contains work from another project, choose a different folder name first.

```bash
mkdir -p ~/my-project/docs
cd ~/my-project
git init -b main
curl -fL -o docs/proposal-draft.md https://raw.githubusercontent.com/OriGoldfrydCS/ex1-materials/main/proposal-draft.md
curl -fL -o docs/disclosure.md https://raw.githubusercontent.com/OriGoldfrydCS/ex1-materials/main/disclosure-template.md
```

Open both files in your text editor. Downloading again replaces the same template
file, so keep your answers and do not repeat the downloads after editing.
Answer the three proposal questions and show the draft to a TA. Add an honest
disclosure row about today, then save both files:

```bash
git add docs/proposal-draft.md docs/disclosure.md
git commit -m "Add topic and disclosure"
git log --oneline
```

This session uses local commits. Fork, clone, remotes, pull and push come in session 2.

## Restarting a game

Running a setup script again without `--reset` stops and keeps your work.
An explicit reset moves the old game into a backup folder before building a new one:

```bash
bash ~/setup_treasure.sh --reset
bash ~/setup_git_quest.sh --reset
bash ~/setup_agent_loop.sh --reset
```

Only run the reset for the game you want to restart. The script prints the backup
location. To replay just the agent conversation, use `bash llm.sh restart` inside
`~/agent-loop`; that clears only the simulation's answer, history and observations.

## If a download fails

Do not run a file downloaded with an error. `curl -fLO` fails on HTTP errors.
Open this repository in your browser, select the script, and use **Download raw file**.
If the course page provides an offline copy, you can use that copy instead.

On Windows, find your Windows user folder with `ls /mnt/c/Users/`, then copy the file
from Downloads into Ubuntu. Replace NAME and use the relevant script filename:

```bash
cp "/mnt/c/Users/NAME/Downloads/setup_treasure.sh" ~/
bash ~/setup_treasure.sh
```

On macOS:

```bash
cp ~/Downloads/setup_treasure.sh ~/
bash ~/setup_treasure.sh
```

Repository text files use LF line endings. Upload the supplied files as files,
rather than copying shell code through a word processor.
