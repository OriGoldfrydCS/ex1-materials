#!/usr/bin/env bash
# Exercise 1 - "Be the Harness": a game that shows how an AI agent works,
# and what the HUMAN does in the loop.
# Creates the folder ~/agent-loop. There is no real AI here:
# llm.sh is a pretend LLM. YOU play the harness AND the human.
# Works on Ubuntu (WSL) and on Mac.

set -e
cd "$HOME"
rm -rf agent-loop
mkdir agent-loop
cd agent-loop

cat > recipe.txt << 'TXT'
Tomato soup
Ingredients: tomatoes, onion, salt, water, ____ (one herb is missing)
Chef's note: the missing herb starts with the letter B.
Pantry shelf: thyme, parsley, basil, oregano
TXT
: > observation.txt
: > .history
echo 0 > .state

cat > START-HERE.txt << 'TXT'
BE THE HARNESS (and the human)

An AI agent has three players:

  THE LLM       The brain. It only reads and writes TEXT.
                It cannot see your files. It cannot run anything.
                And it can be WRONG.
  THE HARNESS   The hands. A program on your computer.
                It runs the tools (commands) the LLM asks for,
                and sends the result back to the LLM.
  THE HUMAN     You. You give the task, you approve what is risky,
                and you CHECK the result. The agent is your tool,
                but you are responsible for what it does.

They work in a LOOP:
  1. The LLM thinks, and asks for a tool.     (tool request)
  2. The harness runs the tool.               (after the human approves)
  3. The result goes back to the LLM.         (observation)
  4. Repeat, until the task is done.

In this game there is no real AI. The file llm.sh is a pretend LLM.
YOU play two roles: the HARNESS (you run the commands)
and the HUMAN (you decide if a request is right). There are only 3 rounds.

HOW TO PLAY
  1. Type:   bash llm.sh
     The LLM shows what it knows, what it thinks, and asks for ONE tool.
  2. HUMAN: read the request. Is it right? Is it safe?
     - If yes: HARNESS, run the command EXACTLY as written.
               (It ends with > observation.txt, or it writes a file.)
               Then type:   bash llm.sh
     - If NOT: do not run it. Tell the LLM:   bash llm.sh no
  3. Repeat until the LLM says DONE.

Start now:   bash llm.sh
(To start over at any time:   bash llm.sh restart)
TXT

cat > llm.sh << 'LLM'
#!/usr/bin/env bash
# The pretend LLM. It only knows what is written in observation.txt and .history.
cd "$(dirname "$0")"
state=$(cat .state 2>/dev/null || echo 0)
obs=$(cat observation.txt 2>/dev/null || true)
arg="$1"

if [ "$arg" = "restart" ]; then
  : > observation.txt; : > .history; rm -f answer.txt; echo 0 > .state
  echo "The game is reset. Type:   bash llm.sh"
  exit 0
fi

line="----------------------------------------------------------"
req0='cat recipe.txt > observation.txt'
req_bad='echo "thyme" > answer.txt'
req_ok='echo "basil" > answer.txt'
req_check='cat answer.txt > observation.txt'

round() { echo; echo "================== ROUND $1 of 3 =================="; }
memory() {
  echo "MEMORY (the harness keeps the history and sends it every time):"
  sed 's/^/   /' .history
}
read_job() {
  echo
  echo "YOUR JOB:"
  echo "   HUMAN:    Read the request. Is it safe?"
  echo "   HARNESS:  If yes, run it EXACTLY as written. Then type:   bash llm.sh"
}
write_job() {
  echo
  echo "YOUR JOB:"
  echo "   HUMAN:    Read the request. Is it RIGHT? Check it against the recipe."
  echo "             If you do NOT approve it, do not run it. Type:   bash llm.sh no"
  echo "   HARNESS:  If you approve it, run it EXACTLY as written. Then type:   bash llm.sh"
}
retry() {
  echo
  echo "THE LLM SAYS: I did not get the result of my last tool."
  echo "   I can only know what the harness sends me!"
  echo "   Please run my request again. Make sure it ends with > observation.txt"
  echo
  echo "TOOL REQUEST:   $1"
  read_job
}
questions() {
  echo
  echo "TALK ABOUT IT with your neighbor, then with your TA:"
  echo "   1. Who ran the commands: the LLM, the harness, or the human?"
  echo "   2. What are the jobs of the human in the loop?"
  echo "   3. What would have happened without a human?"
}
check_round() {
  round 3
  echo "THE HARNESS SENDS THE LLM:"
  memory
  echo
  echo "THE LLM THINKS:"
  echo "   I cannot see whether the file was written."
  echo "   I should not just believe that it worked. Let me check."
  echo
  echo "TOOL REQUEST  [READ tool: it only looks, nothing changes]"
  echo "   $req_check"
  read_job
  echo
  echo "WHY THIS MATTERS: a good agent checks its work. And so should the human."
  echo "Round 3: the LLM asked to run: $req_check" >> .history
}

case "$state" in
0)
  round 1
  echo "THE HARNESS SENDS THE LLM:"
  echo "   Task from the user: The soup recipe is in recipe.txt."
  echo "   One ingredient is missing. Find it, and write it in a file called answer.txt."
  echo
  echo "THE LLM THINKS:"
  echo "   I cannot see your computer. I only get text."
  echo "   I need a tool to read recipe.txt."
  echo
  echo "TOOL REQUEST  [READ tool: it only looks, nothing changes]"
  echo "   $req0"
  read_job
  echo
  echo "WHY THIS MATTERS: the LLM cannot run the command. Only the harness can."
  echo "Read tools are safe: they only look. Real agents use them all the time."
  echo "Task: find the missing ingredient and write it in answer.txt" >> .history
  echo "Round 1: the LLM asked to run: $req0" >> .history
  echo 1 > .state ;;
1)
  if echo "$obs" | grep -q "____"; then
    round 2
    echo "THE HARNESS SENDS THE LLM:"
    memory
    echo "   New result (the observation):"
    sed 's/^/      | /' observation.txt
    echo
    echo "THE LLM THINKS:"
    echo "   One herb is missing. The pantry has thyme, parsley, basil and oregano."
    echo "   I will pick thyme. I cannot write files myself, so I ask the harness."
    echo
    echo "TOOL REQUEST  [WRITE tool: it CHANGES your computer!]"
    echo "   $req_bad"
    write_job
    echo
    echo "WHY THIS MATTERS: a write tool changes things, so a human approves it first."
    echo "Real harnesses ask you before they run it. The LLM can be wrong. Check!"
    echo "Round 2: the LLM asked to run: $req_bad" >> .history
    echo 2 > .state
  else
    echo; echo "================== ROUND 1 of 3 (again) =================="; retry "$req0"
  fi ;;
2)
  if [ "$arg" = "no" ]; then
    echo
    echo "THE HUMAN SAYS: No."
    echo
    echo "THE LLM THINKS:"
    echo "   The human refused my request. Let me re-read the chef's note:"
    echo "   the missing herb starts with the letter B. Thyme starts with T."
    echo "   I was wrong! Basil starts with B."
    echo
    echo "NEW TOOL REQUEST  [WRITE tool: it CHANGES your computer!]"
    echo "   $req_ok"
    write_job
    echo
    echo "WHY THIS MATTERS: the human stopped a mistake BEFORE it happened."
    echo "Round 2 (again): the human refused. The LLM asked to run: $req_ok" >> .history
    echo 5 > .state
  else
    check_round; echo 3 > .state
  fi ;;
5)
  check_round; echo 6 > .state ;;
3)
  if [ "$obs" = "basil" ]; then
    echo; echo "$line"; echo "THE LLM SAYS:  I read answer.txt, and it says: basil."
    echo; echo "DONE!  The missing ingredient is basil."; echo "$line"
    echo; echo "You wrote basil yourself. Good: the human is allowed to correct the agent."
    questions; echo 4 > .state
  elif [ "$obs" = "thyme" ]; then
    echo; echo "$line"
    echo "THE LLM SAYS:  I read answer.txt, and it says: thyme."
    echo; echo "DONE!  The missing ingredient is thyme."; echo "$line"
    echo
    echo "...BUT THIS ANSWER IS WRONG!"
    echo
    echo "WHAT WENT WRONG:"
    echo "   1. In round 2 the LLM chose thyme."
    echo "   2. The chef's note in recipe.txt says: the missing herb starts with the letter B."
    echo "   3. Thyme starts with T. The right answer is basil."
    echo "   4. The LLM said DONE with confidence. It did not notice its own mistake."
    echo "   5. You approved the request, and you did not check it against the recipe."
    echo
    echo "HOW TO CATCH IT:"
    echo "   Before you approve a tool that changes things, ask: does this match the goal?"
    echo "   Check the request against what you know. Here: the chef's note."
    echo "   An agent can be wrong, and still sound sure. Only the human can check."
    questions
    echo
    echo "TRY AGAIN:   type   bash llm.sh restart"
    echo "   This time, read the request in round 2 carefully, and compare it with the recipe"
    echo "   before you approve it."
    echo 4 > .state
  else
    echo
    echo "THE LLM SAYS: I could not read my answer. Something went wrong."
    echo "   Please run my request again."
    echo "   $req_check"
    read_job
  fi ;;
6)
  if [ "$obs" = "basil" ]; then
    echo; echo "$line"; echo "THE LLM SAYS:  I read answer.txt, and it says: basil."
    echo; echo "DONE!  The missing ingredient is basil."; echo "$line"
    echo
    echo "You caught my mistake! The LLM first chose thyme. YOU (the human) said no."
    echo "That is the human's job: DIRECT the agent, APPROVE what is risky, and VERIFY the result."
    echo
    echo "What you did is what every AI agent loop does, with a human in it:"
    echo "   think -> ask for a tool -> the human approves -> the harness runs it -> the result goes back -> repeat"
    questions
    echo
    echo "PLAY AGAIN (optional):   bash llm.sh restart"
    echo 4 > .state
  else
    echo
    echo "THE LLM SAYS: I read answer.txt, and it does not say basil. Please write it again."
    echo "   $req_ok"
    write_job
    echo 5 > .state
  fi ;;
*)
  echo "The game is finished. To play again, type:   bash llm.sh restart" ;;
esac
LLM
chmod +x llm.sh

echo ""
echo "Be the Harness is ready!  Now type:   cd ~/agent-loop"
echo "and then:                           cat START-HERE.txt"
