#!/usr/bin/env bash
# Exercise 1 - Git Quest
# Creates the folder ~/TA1/git-quest: a real Git repository with a story and clues.
# Also creates ~/TA1/git-quest-check.sh, which checks your progress.
# For Bash on Ubuntu (WSL) and macOS; Git 2.28 or newer.

set -eu
# TA1_WORKSPACE is optional; by default the games live in ~/TA1.
root="${TA1_WORKSPACE:-$HOME/TA1}"
mkdir -p -- "$root"
cd -- "$root"
root=$(pwd -P)
case "${1:-}" in
  ""|--reset) ;;
  *) echo "Usage: bash $(basename "$0") [--reset]" >&2; exit 2 ;;
esac
for tool in bash cat mkdir mv grep sed git; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing command: $tool. See the course setup instructions." >&2; exit 1; }
done
if [ -e "$root/git-quest" ] || [ -L "$root/git-quest" ] || [ -e "$root/git-quest-check.sh" ] || [ -L "$root/git-quest-check.sh" ]; then
  if [ "${1:-}" != --reset ]; then
    echo "The git-quest game already exists. Your progress has been kept."
    echo "To start again, run: bash ~/TA1/$(basename "$0") --reset"
    echo "Reset moves the previous game into a backup folder first."
    exit 1
  fi
  backup=$(mktemp -d "$root/.ta1-git-quest-backup.XXXXXX")
  if [ -e "$root/git-quest" ] || [ -L "$root/git-quest" ]; then mv -- "$root/git-quest" "$backup/"; fi
  if [ -e "$root/git-quest-check.sh" ] || [ -L "$root/git-quest-check.sh" ]; then mv -- "$root/git-quest-check.sh" "$backup/"; fi
  echo "Previous progress backed up to: $backup"
fi
mkdir git-quest
cd git-quest
git init -q -b main

# The quest master saves the first commits (not you), so we do not touch your Git settings.
qm() { git -c user.name="Quest Master" -c user.email="quest@example.com" "$@"; }

# ---------- main timeline ----------
cat > START-HERE.txt << 'TXT'
WELCOME, TIME TRAVELER!

This folder is a Git repository. The setup script saved some commits for you.
Git saves a new version only when you make a commit.
Your mission: follow the clues, one level at a time.

HOW TO PLAY
  - Lines that start with "Type:" are commands. Type them, then press Enter.
  - After each command, read what Git prints on the screen.
  - Open each level file only when it tells you to.

=================================================
LEVEL 1 - LOOK AROUND
=================================================
Step 1.  Type:   git status
         It means: "What does Git see right now?"
         You should see: nothing to commit, working tree clean

Step 2.  Type:   git log --oneline
         It means: "Show me all the save points."
         Each line is one save point: a short code, then a label.

Step 3.  Find the line whose label starts with the word KEY.
         Read it. It tells you where the next clue is.
         ("Timeline" is another word for "branch".)

YOU LEARNED:
  git status          shows what is happening now
  git log --oneline   shows the history of save points

NEXT:  type   cat LEVEL-2.txt
TXT
qm add START-HERE.txt
qm commit -q -m "Add the map of the island"

echo "The old lighthouse was built in 1850." > lighthouse.txt
qm add lighthouse.txt
qm commit -q -m "Add the old lighthouse note"

echo "The treasure is not in the lighthouse." > hint.txt
qm add hint.txt
qm commit -q -m "KEY: the next clue is on the timeline called cave"

echo "Today it will be sunny." > weather.txt
qm add weather.txt
qm commit -q -m "Add a note about the weather"

cat > treasure-map.txt << 'TXT'
X marks the spot.
The treasure is hidden under the old oak tree.
TXT
cat > LEVEL-2.txt << 'TXT'
=================================================
LEVEL 2 - TRAVEL BETWEEN TIMELINES
=================================================
(In Git, a timeline is called a "branch".)

Step 1.  Type:   git branch
         It means: "Show me all the timelines."
         The star * marks the one you are on now.

Step 2.  Type:   git switch cave
         It means: "Travel to the timeline called cave."
         You should see: Switched to branch 'cave'

Step 3.  Type:   ls
         It means: "List the files here."
         A new file has appeared: LEVEL-3.txt

YOU LEARNED:
  A branch is a separate timeline of save points.
  You can travel between timelines, and tracked files change.
  Commit your changes before switching; unsaved changes may follow you.

NEXT:  type   cat LEVEL-3.txt
TXT
cat > LEVEL-4.txt << 'TXT'
=================================================
LEVEL 4 - UNDO A MISTAKE
=================================================
Sometimes a change is wrong. An AI agent can also change your files
in a way you do not want. Git lets you see exactly what changed, and undo it.

Step 1.  Type:   ls
         Where is explorer.txt? It is not here!
         It lives on the cave timeline. You left it there.

Step 2.  Type:   echo "OOPS, a vandal was here" >> treasure-map.txt
         It means: "Add a bad line at the end of the map."
         (Two arrows >> add a line. One arrow > would replace the whole file.)

Step 3.  Type:   git status
         It means: "What does Git see now?"
         You should see: modified: treasure-map.txt

Step 4.  Type:   git diff
         It means: "Show me exactly what changed."
         Lines that start with + are new.

Step 5.  Type:   git restore treasure-map.txt
         It means: "Discard unstaged edits to this tracked file."
         Here, we did not stage the edit, so this returns to the saved map.

Step 6.  Type:   cat treasure-map.txt
         The vandal line is gone.

Step 7.  Type:   git status
         It is clean again.

YOU LEARNED:
  git diff      shows exactly what changed
  git restore   undoes a change
  This is how you check, and undo, what an AI agent did to your files.

=================================================
QUEST COMPLETE!
=================================================
Type:   bash ~/TA1/git-quest-check.sh
Then do the self-check, alone or with your neighbor.
TXT
qm add treasure-map.txt LEVEL-2.txt LEVEL-4.txt
qm commit -q -m "Add the treasure map"

# ---------- cave timeline (level 2 and 3) ----------
qm switch -q -c cave
cat > LEVEL-3.txt << 'TXT'
=================================================
LEVEL 3 - LEAVE YOUR MARK
=================================================
You will make your own save point, here on the cave timeline.

Step 1.  Type:   echo "Your Name" > explorer.txt
         It means: "Write my name into a new file called explorer.txt."
         (Replace Your Name with your own name. Keep the quotation marks.)

Step 2.  Type:   git status
         It means: "What does Git see now?"
         You should see: explorer.txt is "untracked".
         Git sees the file, but does not save it yet.
         The file is plain text. Its .txt ending is part of its name.

Step 3.  Type:   git add explorer.txt
         It means: "Put the file in the basket."

Step 4.  Type:   git commit -m "Explorer arrived at the cave"
         It means: "Take the photo, with a label."
         You may write your own label between the quotation marks.
         If Git says "Author identity unknown", set your identity for THIS game:
           git config user.name "Your Name"
           git config user.email "your.email@example.com"
         Replace the example values with your own name and email, then retry.
         These two commands affect only this repository.

Step 5.  Type:   git log --oneline
         Your save point is now at the top of the list.

Step 6.  Type:   git switch main
         It means: "Travel back to the main timeline."

YOU LEARNED:
  git add      puts a change in the basket
  git commit   takes the photo, with a label

NEXT:  type   cat LEVEL-4.txt
TXT
qm add LEVEL-3.txt
qm commit -q -m "Add the cave clue"

# ---------- mountain timeline (a wrong turn) ----------
qm switch -q main
qm switch -q -c mountain
echo "WRONG WAY! Go back to the quest:  git switch main" > WRONG-WAY.txt
qm add WRONG-WAY.txt
qm commit -q -m "Add a wrong way sign"
qm switch -q main

# ---------- checker (outside the repository) ----------
cat > "$root/git-quest-check.sh" << 'CHK'
#!/usr/bin/env bash
# Checks the final Git state, not which commands you personally typed.
set -eu
root="${TA1_WORKSPACE:-$HOME/TA1}"
cd "$root/git-quest" 2>/dev/null || { echo "Run setup_git_quest.sh first."; exit 1; }
echo "Git Quest check"
echo "---------------"
l3=0; l4=0
if git rev-parse --verify cave >/dev/null 2>&1 && git cat-file -e cave:explorer.txt 2>/dev/null; then
  if [ -n "$(git log cave --format=%H -- explorer.txt)" ] && [ -n "$(git show cave:explorer.txt)" ]; then
    echo "[OK] Level 3: explorer.txt is saved in a commit on cave"
    l3=1
  fi
fi
if [ "$l3" = 0 ]; then echo "[ ] Level 3: save your name in explorer.txt on cave; add and commit it."; fi
branch=$(git branch --show-current)
if [ "$branch" = main ] && [ -z "$(git status --porcelain)" ] && [ -f treasure-map.txt ] && ! grep -q OOPS treasure-map.txt; then
  echo "[OK] Level 4: on main, with no staged, unstaged, or untracked changes"
  l4=1
else
  echo "[ ] Level 4: return to main and check git status. The map must be restored."
fi
echo "---------------"
if [ "$l3" = 1 ] && [ "$l4" = 1 ]; then
  echo "FINAL STATE CHECK PASSED"
  echo "This checks the final state, not which commands you typed."
  echo
  echo "SELF-CHECK: alone or with your neighbor, can you explain these terms?"
  echo "  - Repository and branch: what are main and cave?"
  echo "  - Working tree: what do untracked and modified mean?"
  echo "  - Staging: what does git add prepare?"
  echo "  - Commit and history: what do git commit and git log show?"
  echo "  - git status and git diff: what does each one tell you?"
  echo "  - git restore: which edit did it undo in this game?"
  echo "Use examples from the quest. If unsure, revisit the relevant level."
  exit 0
fi
echo "Keep going. Read the clue files again."
exit 1
CHK
chmod +x "$root/git-quest-check.sh"

echo ""
echo "Git Quest ready!  Now type:   cd ~/TA1/git-quest"
echo "and then:                     cat START-HERE.txt"
