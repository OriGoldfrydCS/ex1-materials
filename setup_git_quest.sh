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
Your mission: follow the clues, level by level.

HOW TO PLAY
  - Lines that start with "Type:" are commands. Type them, then press Enter.
  - After each command, read what Git prints on the screen.
  - To read a clue file, type:   cat FILE-NAME

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
         Read it carefully. It tells you where the next clue is.
         ("Timeline" is another word for "branch".)

=================================================
LEVEL 2 - TRAVEL BETWEEN TIMELINES
=================================================
Step 1.  Type:   git branch
         It means: "Show me all the timelines."
         The star * marks the one you are on now.

Step 2.  Type:   git switch cave
         It means: "Travel to the timeline called cave."
         You should see: Switched to branch 'cave'

Step 3.  Type:   ls
         It means: "List the files here."
         A new file has appeared!

Step 4.  Type:   cat CLUE-2.txt
         It is your next clue. Read it.

(Do not open LEVEL-4.txt yet. Wait until you reach level 4.)
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
=================================================
LEVEL 4 - UNDO A MISTAKE
=================================================
Sometimes a change is wrong. An AI agent can also change your files in a way you do not want.
Git lets you see exactly what changed, and undo it. Let us practise.

Step 1.  Type:   echo "OOPS, a vandal was here" >> treasure-map.txt
         It means: "Add a bad line at the end of the map."
         (Two arrows >> add a line. One arrow > would replace the whole file.)

Step 2.  Type:   git status
         It means: "What does Git see now?"
         You should see: modified: treasure-map.txt

Step 3.  Type:   git diff
         It means: "Show me exactly what changed."
         Lines that start with + are new. This is how you check what an agent did.

Step 4.  Type:   git restore treasure-map.txt
         It means: "Go back to the last save point for this file."

Step 5.  Type:   cat treasure-map.txt
         The vandal line is gone.

Step 6.  Type:   git status
         It is clean again.

=================================================
QUEST COMPLETE!
=================================================
Type:   bash ~/git-quest-check.sh
and show the screen to your TA.
TXT
qm add treasure-map.txt LEVEL-4.txt
qm commit -q -m "Add the treasure map"

# ---------- cave timeline (level 2 and 3) ----------
qm switch -q -c cave
cat > CLUE-2.txt << 'TXT'
LEVEL 2 COMPLETE - You travelled to another timeline!

Look: the file CLUE-2.txt exists only here, on the cave timeline.
You will see it disappear when you go back to main. That is what a branch is.

=================================================
LEVEL 3 - LEAVE YOUR MARK
=================================================
You will make your own save point, on this timeline.

Step 1.  Type:   echo "Your Name" > explorer.txt
         It means: "Write my name into a new file called explorer.txt."
         (Replace Your Name with your own name. Keep the quotation marks.)

Step 2.  Type:   git status
         It means: "What does Git see now?"
         You should see: explorer.txt is "untracked". Git sees it, but does not save it yet.

Step 3.  Type:   git add explorer.txt
         It means: "Put the file in the basket."

Step 4.  Type:   git commit -m "Explorer arrived at the cave"
         It means: "Take the photo, with a label." You may write your own label.

Step 5.  Type:   git log --oneline
         Your save point is now at the top of the list.

Step 6.  Type:   git switch main
         It means: "Travel back to the main timeline."

Step 7.  Type:   ls
         Where did explorer.txt and CLUE-2.txt go?
         They live on the cave timeline. You left them there.

Step 8.  Type:   cat LEVEL-4.txt
         It is your last clue.
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
