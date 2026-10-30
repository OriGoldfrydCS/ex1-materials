#!/usr/bin/env bash
# Exercise 1 - Terminal Treasure Hunt
# Creates the folder ~/TA1/treasure with a chain of clues.
# For Bash on Ubuntu (WSL) and macOS.

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
for tool in bash cat mkdir mv grep sed; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing command: $tool. See the course setup instructions." >&2; exit 1; }
done
if [ -e "$root/treasure" ] || [ -L "$root/treasure" ]; then
  if [ "${1:-}" != --reset ]; then
    echo "The treasure game already exists. Your progress has been kept."
    echo "To start again, run: bash ~/TA1/$(basename "$0") --reset"
    echo "Reset moves the previous game into a backup folder first."
    exit 1
  fi
  backup=$(mktemp -d "$root/.ta1-treasure-backup.XXXXXX")
  if [ -e "$root/treasure" ] || [ -L "$root/treasure" ]; then mv -- "$root/treasure" "$backup/"; fi
  echo "Previous progress backed up to: $backup"
fi

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
  ls ~/TA1/treasure/done
Also check that the key is no longer in mountain:
  ls ~/TA1/treasure/mountain

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
echo "Treasure hunt ready!  Now type:   cd ~/TA1/treasure"
echo "and then:                         cat README.txt"
