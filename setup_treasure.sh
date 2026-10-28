#!/usr/bin/env bash
# Exercise 1 - Terminal Treasure Hunt
# Creates the folder ~/treasure with a chain of clues.
# Works on Ubuntu (WSL) and on Mac.

set -e
cd "$HOME"

# Start fresh if the hunt already exists
rm -rf treasure

mkdir -p treasure/start
mkdir -p treasure/forest/tree treasure/forest/river treasure/forest/cave-of-secrets
mkdir -p treasure/mountain
mkdir -p treasure/desert

cat > treasure/README.txt << 'TXT'
Welcome to the Treasure Hunt!

Your mission: find the golden key and move it to a new folder called "done".

Start here: go into the folder called "start" and read the file clue1.txt
(Hint: use cd to go in, ls to look around, cat to read a file.)
TXT

cat > treasure/start/clue1.txt << 'TXT'
CLUE 1
Well done! The next clue is in the folder "forest".
It is next to the folder you are in now. Go up one level with:  cd ..
Then go into the forest and read clue2.txt.
TXT

cat > treasure/forest/clue2.txt << 'TXT'
CLUE 2
Look around with ls. This folder has three folders inside it.
Only ONE of them has a name about a secret.
Go inside it and read clue3.txt.
TXT

echo "Nothing here, only trees. Go back with: cd .." > treasure/forest/tree/not_here.txt
echo "Nothing here, only water. Go back with: cd .." > treasure/forest/river/not_here.txt

cat > treasure/forest/cave-of-secrets/clue3.txt << 'TXT'
CLUE 3
The golden key is in the folder "mountain".
The mountain is in the "treasure" folder, two levels above this cave.
Go up two levels with:  cd ../..
Then go into the mountain and read clue4.txt.
TXT

echo "Only sand here. This is not the way." > treasure/desert/sand.txt

cat > treasure/mountain/clue4.txt << 'TXT'
CLUE 4 - the last one!
Do these two things:
  1. Go up one level to the "treasure" folder and make a new folder called done.
     (Hint: mkdir)
  2. Move the file golden_key.txt from the mountain folder into the done folder.
     (Hint: mv)

You are finished when this command shows golden_key.txt:
  ls ~/treasure/done

BONUS for fast finishers: there is a hidden file in this folder.
Hidden files start with a dot. Try:  ls -a
TXT

cat > treasure/mountain/golden_key.txt << 'TXT'
You found the golden key!
You can now move around the terminal and read files. Great job.
TXT

cat > treasure/mountain/.bonus.txt << 'TXT'
BONUS FOUND!
Hidden files exist on every computer. Many tools (like git) keep their
settings in hidden files and folders, for example ".git" and ".gitignore".
We will see them again soon.
TXT

echo ""
echo "Treasure hunt ready!  Now type:   cd ~/treasure"
echo "and then:                         cat README.txt"
