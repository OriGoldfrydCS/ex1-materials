#!/usr/bin/env bash
# Be the Harness: a scripted simulation. No model, API key, or Python needed.
# For Bash on Ubuntu (WSL) and macOS.
set -eu
# TA1_WORKSPACE is optional; by default the games live in your home folder.
root="${TA1_WORKSPACE:-$HOME}"
cd -- "$root"
root=$(pwd -P)
case "${1:-}" in
  ""|--reset) ;;
  *) echo "Usage: bash $(basename "$0") [--reset]" >&2; exit 2 ;;
esac
for tool in bash cat mkdir mv grep sed; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing command: $tool. See the course setup instructions." >&2; exit 1; }
done
if [ -e "$root/agent-loop" ] || [ -L "$root/agent-loop" ]; then
  if [ "${1:-}" != --reset ]; then
    echo "The agent-loop game already exists. Your progress has been kept."
    echo "To start again, run: bash ~/$(basename "$0") --reset"
    echo "Reset moves the previous game into a backup folder first."
    exit 1
  fi
  backup=$(mktemp -d "$root/.ta1-agent-loop-backup.XXXXXX")
  if [ -e "$root/agent-loop" ] || [ -L "$root/agent-loop" ]; then mv -- "$root/agent-loop" "$backup/"; fi
  echo "Previous progress backed up to: $backup"
fi
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

This is a scripted simulation, not a real LLM.
THE MODEL requests a tool. THE HARNESS runs it and returns the result.
THE HUMAN gives the task, approves changes in this game, and verifies the result.
In real systems, approval rules depend on the tool and permission settings.

Your task: find the missing ingredient and put it in answer.txt.

1. Type: bash llm.sh
2. Read the requested command. Compare it with recipe.txt.
   If you approve, play the harness: run the command exactly as shown.
   Then type: bash llm.sh
   If you refuse, do not run the command. Type: bash llm.sh no
3. Keep going. A confident claim of DONE is not proof that the answer is correct.
4. Read the final answer back, then run: bash check.sh

DONE WHEN: check.sh reports PASS, and you can explain the mistake and your check.
To replay: bash llm.sh restart
TXT
cat > llm.sh << 'LLM'
#!/usr/bin/env bash
set -eu
cd -- "$(dirname "$0")"
arg=${1:-}
case "$arg" in ""|no|restart) ;; *) echo "Usage: bash llm.sh [no|restart]"; exit 2 ;; esac
if [ "$arg" = restart ]; then
  : > observation.txt; : > .history; rm -f answer.txt; echo 0 > .state
  echo "Reset. Start with: bash llm.sh"; exit 0
fi
state=$(cat .state)
obs=$(cat observation.txt)
request() {
  echo
  echo "MODEL REQUEST: $1"
  echo "HUMAN: check it. HARNESS: if approved, run it, then type bash llm.sh."
  echo "To refuse without running it: bash llm.sh no"
}
memory() { echo "HISTORY returned by the harness:"; sed 's/^/  /' .history; }
questions() {
  echo "Discuss: Who ran the commands? What was the mistake?"
  echo "How did you check the result? What did the human contribute?"
}
verify_request() {
  echo "ROUND 3: verify what was written."
  memory
  echo "The harness must return the result to the model."
  request 'cat answer.txt > observation.txt'
  echo "This reads answer.txt and saves the returned text in observation.txt."
  echo 'Round 3: requested a read-back of answer.txt' >> .history
}
# A refusal never executes a tool. In round 2 the model revises its first request.
if [ "$arg" = no ] && [ "$state" != 2 ]; then
  echo "Request refused. No tool was run; the game has not advanced."
  case "$state" in
    1) request 'cat recipe.txt > observation.txt' ;;
    5) request 'echo "basil" > answer.txt' ;;
    3|6) request 'cat answer.txt > observation.txt' ;;
    *) echo "Run bash llm.sh to see the current step." ;;
  esac
  exit 0
fi
case "$state" in
0)
  echo "ROUND 1: find the missing soup ingredient and save it in answer.txt."
  echo "The model has not received the recipe yet."
  request 'cat recipe.txt > observation.txt'
  echo "This reads the recipe and writes the returned text to observation.txt."
  echo 'Task: find the ingredient; round 1 requested the recipe' >> .history
  echo 1 > .state ;;
1)
  if ! printf '%s\n' "$obs" | grep -q '____'; then
    echo "No recipe result received. Run the requested command first."
    request 'cat recipe.txt > observation.txt'; exit 0
  fi
  echo "ROUND 2: choose an ingredient."
  memory; echo "NEW OBSERVATION:"; cat observation.txt
  echo "The scripted model thinks: I will choose thyme."
  request 'echo "thyme" > answer.txt'
  echo "Check this request against the chef's note before approving."
  echo 'Round 2: requested thyme' >> .history
  echo 2 > .state ;;
2)
  if [ "$arg" = no ]; then
    echo "HUMAN: No. The request was not executed."
    echo "MODEL: The herb must start with B. Thyme starts with T. Let me revise."
    request 'echo "basil" > answer.txt'
    echo 'Human rejected thyme; model revised its request to basil' >> .history
    echo 5 > .state
  elif [ ! -f answer.txt ]; then
    echo "The write has not happened. Approve and run it, or refuse with no."
    request 'echo "thyme" > answer.txt'
  else verify_request; echo 3 > .state
  fi ;;
5)
  if [ ! -f answer.txt ] || [ "$(cat answer.txt)" != basil ]; then
    echo "The corrected write has not happened yet."
    request 'echo "basil" > answer.txt'
  else verify_request; echo 6 > .state
  fi ;;
3|6)
  if [ "$obs" = basil ]; then
    echo "MODEL: The returned result says basil. DONE."
    echo "Now verify independently: bash check.sh"
    questions; echo 4 > .state
  elif [ "$obs" = thyme ]; then
    echo "MODEL: The returned result says thyme. DONE."
    echo "PAUSE: that confident answer is WRONG. The chef's note requires B."
    echo "Reading a file proves what it contains, not that its contents are correct."
    echo "SIMULATION NOT COMPLETE. Replay with: bash llm.sh restart"
    questions; echo 7 > .state
  else
    echo "No usable read-back received. Run the requested command."
    request 'cat answer.txt > observation.txt'
  fi ;;
4) echo "Run bash check.sh and discuss your verification with your neighbor." ;;
7) echo "The wrong answer was accepted. Try again: bash llm.sh restart" ;;
*) echo "Invalid game state. Restart with: bash llm.sh restart"; exit 1 ;;
esac
LLM
cat > check.sh << 'CHECK'
#!/usr/bin/env bash
set -eu
cd -- "$(dirname "$0")"
if [ -f answer.txt ] && [ "$(cat answer.txt)" = basil ] \
  && [ "$(cat observation.txt)" = basil ] && [ "$(cat .state)" = 4 ]; then
  echo "PASS: the answer matches the recipe and was read back."
  echo "Explain the first mistake, who ran the tools, and how you verified the result."
  exit 0
fi
echo "NOT YET: complete the loop and check the answer against the chef's note."
echo "If you accepted the wrong answer, replay with: bash llm.sh restart"
exit 1
CHECK
chmod +x llm.sh check.sh
echo "Be the Harness is ready. Type: cd ~/agent-loop"
echo "Then: cat START-HERE.txt"
