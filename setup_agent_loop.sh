#!/usr/bin/env bash
# Exercise 1 - "Be the Harness": a game that shows how an AI agent works.
# Creates the folder ~/agent-loop. There is no real AI here:
# llm.sh is a pretend LLM, and YOU play the harness.
# Works on Ubuntu (WSL) and on Mac.

set -e
cd "$HOME"
rm -rf agent-loop
mkdir agent-loop
cd agent-loop

cat > recipe.txt << 'TXT'
Tomato soup
Ingredients: tomatoes, onion, salt, water, ____ (one herb is missing)
TXT

echo "Chef's note: the missing herb starts with the letter B." > chef-note.txt
echo "Pantry shelf: tomatoes, onion, salt, thyme, parsley, basil, oregano" > pantry.txt
: > observation.txt
echo 0 > .state

cat > START-HERE.txt << 'TXT'
BE THE HARNESS

An AI agent has two parts:

  THE LLM       The brain. It only reads and writes TEXT.
                It cannot see your files. It cannot run anything.
  THE HARNESS   The hands. It is a program on your computer.
                It runs the tools (commands) that the LLM asks for,
                and sends the result back to the LLM.

Together they work in a LOOP:

  1. The LLM thinks, and asks for a tool.
  2. The harness runs the tool.
  3. The result goes back to the LLM.
  4. Repeat, until the task is done.

In this game there is no real AI. The file llm.sh is a pretend LLM.
YOU are the harness.

HOW TO PLAY
  Step 1.  Type:   bash llm.sh
           The LLM tells you what it is thinking, and asks for ONE tool.
  Step 2.  Read the request. Do you approve it?
           If yes, run the command EXACTLY as written.
           (It ends with > observation.txt. That is how the result goes back.)
  Step 3.  Type:   bash llm.sh      again.
           The LLM reads the result and asks for the next tool.
  Keep going until the LLM says DONE.

Start now:   bash llm.sh
TXT

cat > llm.sh << 'LLM'
#!/usr/bin/env bash
# The pretend LLM. It only knows what is written in observation.txt.
cd "$(dirname "$0")"
state=$(cat .state 2>/dev/null || echo 0)
obs=$(cat observation.txt 2>/dev/null || true)

line="==================================================="
req() {
  echo "TOOL REQUEST:   $1"
  echo "$line"
  echo ""
  echo "YOU are the HARNESS. Read the request. Do you approve it?"
  echo "If yes, run the command EXACTLY as written. Then type:   bash llm.sh"
}
head_llm() { echo "================= LLM (the brain) ================="; }
req0='ls > observation.txt'
req1='cat recipe.txt > observation.txt'
req2='cat chef-note.txt > observation.txt'
req3='cat pantry.txt > observation.txt'
req4='echo "basil" > answer.txt'
req5='cat answer.txt > observation.txt'
retry() {
  head_llm
  echo "THINKING: I did not get the result of my last tool."
  echo "          I can only know what the harness sends me!"
  echo "          Please run my request again. Make sure the command ends with > observation.txt"
  echo ""
  req "$1"
}

case "$state" in
0)
  head_llm
  echo "TASK from the user: The soup recipe is missing one ingredient."
  echo "                    Find it, and write it in a file called answer.txt."
  echo ""
  echo "THINKING: I cannot see your computer. I only get text."
  echo "          I need a tool to look at the files."
  req "$req0"; echo 1 > .state ;;
1)
  if echo "$obs" | grep -q "recipe.txt"; then
    head_llm
    echo "THINKING: Thank you. I see these files: recipe.txt, chef-note.txt, pantry.txt."
    echo "          I will read the recipe first."
    req "$req1"; echo 2 > .state
  else retry "$req0"; fi ;;
2)
  if echo "$obs" | grep -q "____"; then
    head_llm
    echo "THINKING: One ingredient is missing (____). Maybe the chef left a note."
    req "$req2"; echo 3 > .state
  else retry "$req1"; fi ;;
3)
  if echo "$obs" | grep -q "herb"; then
    head_llm
    echo "THINKING: The missing ingredient is an herb that starts with B."
    echo "          Which herbs are in the pantry?"
    req "$req3"; echo 4 > .state
  else retry "$req2"; fi ;;
4)
  if echo "$obs" | grep -q "basil"; then
    head_llm
    echo "THINKING: Basil is the only herb that starts with B."
    echo "          I will write the answer. I cannot write files myself,"
    echo "          so I ask the harness to do it."
    echo ""
    echo "          WARNING: this tool CHANGES your computer. Read it carefully before you approve!"
    echo ""
    req "$req4"; echo 5 > .state
  else retry "$req3"; fi ;;
5)
  head_llm
  echo "THINKING: I cannot see whether the file was written."
  echo "          I should not just believe it worked. Let me check."
  req "$req5"; echo 6 > .state ;;
6)
  if [ "$obs" = "basil" ]; then
    head_llm
    echo "THINKING: answer.txt says: basil. The task is complete."
    echo "$line"
    echo ""
    echo "DONE!  The missing ingredient is basil."
    echo ""
    echo "What you just did is what EVERY AI agent does:"
    echo "  think  ->  ask for a tool  ->  the harness runs it  ->  the result goes back  ->  repeat"
    echo "Real agents do it by themselves, very fast. You are the one who approves, and checks."
    echo 7 > .state
  else
    head_llm
    echo "THINKING: I read answer.txt, and it does not say basil. Something went wrong."
    echo "          Let me ask you to write it again."
    echo ""
    req "$req4"; echo 5 > .state
  fi ;;
*)
  echo "The task is complete. To play again, run setup_agent_loop.sh again." ;;
esac
LLM
chmod +x llm.sh

echo ""
echo "Be the Harness is ready!  Now type:   cd ~/agent-loop"
echo "and then:                           cat START-HERE.txt"
