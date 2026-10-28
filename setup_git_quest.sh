#!/usr/bin/env bash
# Exercise 1 - Git Quest
# Creates the folder ~/git-quest: a real Git repository with a story and clues.
# Also creates ~/git-quest-check.sh, which checks your progress.
# Works on Ubuntu (WSL) and on Mac.

set -e
cd "$HOME"
rm -rf git-quest git-quest-check.sh
mkdir git-quest
cd git-quest
git init -q -b main

# The quest master saves the first commits (not you), so we do not touch your Git settings.
qm() { git -c user.name="Quest Master" -c user.email="quest@example.com" "$@"; }

# ---------- main timeline ----------
cat > START-HERE.txt << 'TXT'
WELCOME, TIME TRAVELER!

This folder is a Git repository. Git has been watching it and saving its history.
Your mission: follow the clues. Do the levels in order.

LEVEL 1 - LOOK AROUND

  1. Type:   git status
     In plain words: "What does Git see right now?"
     Everything is clean: nothing changed since the last save point.

  2. Type:   git log --oneline
     In plain words: "Show me all the save points."
     Each line is one save point: a short code, then a label.

  3. One label starts with the word KEY. Read it.
     It tells you where to go next.

Do NOT open LEVEL-4.txt yet. Wait until you reach level 4.
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
cat > LEVEL-4.txt << 'TXT'
LEVEL 4 - UNDO A MISTAKE

Sometimes a change is wrong. An AI agent can also change your files in a way you do not want.
Git lets you see exactly what changed, and undo it. Let us practise.

  1. Pretend you (or an agent) made a bad change. Type:
        echo "OOPS, a vandal was here" >> treasure-map.txt
     In plain words: "Add a line at the end of the map." Two arrows add, one arrow replaces.

  2. Type:   git status
     In plain words: "What does Git see?"
     It says "modified": a saved file was changed.

  3. Type:   git diff
     In plain words: "Show me exactly what changed."
     Lines that start with + are new. This is how you check an agent's work.

  4. Type:   git restore treasure-map.txt
     In plain words: "Go back to the last save point for this file."

  5. Type:   cat treasure-map.txt
     The vandal is gone. Type  git status  again: clean.

QUEST COMPLETE!
Type:   bash ~/git-quest-check.sh   and show it to your TA.
TXT
qm add treasure-map.txt LEVEL-4.txt
qm commit -q -m "Add the treasure map"

# ---------- cave timeline (level 2 and 3) ----------
qm switch -q -c cave
cat > CLUE-2.txt << 'TXT'
LEVEL 2 COMPLETE - You travelled to another timeline!

Look: this file exists only here, on the cave timeline.
(Type  git switch main  later and see that it disappears. That is what a branch is.)

LEVEL 3 - LEAVE YOUR MARK
Make your own save point on this timeline. Do it step by step:

  1. Create a file with your name. Type:
        echo "Your Name" > explorer.txt
     In plain words: "Write my name into a new file." One arrow creates the file.

  2. Type:   git status
     It says "untracked": Git sees the file, but does not save it yet.

  3. Type:   git add explorer.txt
     In plain words: "Put the file in the basket."

  4. Type:   git commit -m "Explorer arrived at the cave"
     In plain words: "Take the photo, with a label." You may write your own label.

  5. Type:   git log --oneline
     Your save point is at the top of the list.

Now go back to the main timeline:   git switch main
Type  ls : where did explorer.txt go? It lives on the cave timeline.
Then read the file  LEVEL-4.txt  on main.
TXT
qm add CLUE-2.txt
qm commit -q -m "Add the cave clue"

# ---------- mountain timeline (a wrong turn) ----------
qm switch -q main
qm switch -q -c mountain
echo "WRONG WAY! Go back to the quest:  git switch main" > WRONG-WAY.txt
qm add WRONG-WAY.txt
qm commit -q -m "Add a wrong way sign"
qm switch -q main

# ---------- checker (outside the repository) ----------
cat > "$HOME/git-quest-check.sh" << 'CHK'
#!/usr/bin/env bash
# Checks your progress in the Git Quest.
cd "$HOME/git-quest" 2>/dev/null || { echo "Folder ~/git-quest not found. Run setup_git_quest.sh first."; exit 1; }
ok=0
echo "Git Quest check"
echo "---------------"
# Level 3: a save point by you (not by the Quest Master) with explorer.txt on the cave timeline
mine=$(git log cave --format=%an 2>/dev/null | grep -vc "Quest Master")
if [ "$mine" -ge 1 ] && git cat-file -e cave:explorer.txt 2>/dev/null; then
  echo "[OK]  Level 3: you made your own save point on the cave timeline"
  l3=1
else
  echo "[ ]   Level 3: not yet. On the cave timeline: create explorer.txt, then git add and git commit"
  l3=0
fi
# Level 4: you are on main, the map is clean and has no vandal line
branch=$(git branch --show-current)
if [ "$branch" = "main" ] && git diff --quiet && ! grep -q "OOPS" treasure-map.txt 2>/dev/null; then
  echo "[OK]  Level 4: you are on main and the map is clean"
  l4=1
else
  echo "[ ]   Level 4: not yet. Be on main, and make sure  git status  is clean"
  l4=0
fi
echo "---------------"
if [ "$l3" = 1 ] && [ "$l4" = 1 ]; then
  echo "ALL LEVELS DONE! Show this screen to your TA."
else
  echo "Keep going. Read the clue files again if you are stuck."
fi
CHK
chmod +x "$HOME/git-quest-check.sh"

echo ""
echo "Git Quest ready!  Now type:   cd ~/git-quest"
echo "and then:                     cat START-HERE.txt"
