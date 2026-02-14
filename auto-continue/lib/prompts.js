/**
 * Prompt templates — the most critical file in the orchestrator.
 * These prompts control how Claude behaves within the auto-continue loop.
 */

/**
 * A. System suffix injected via --append-system-prompt into every invocation.
 * Teaches Claude about the orchestrator's control markers.
 */
const ORCHESTRATOR_SYSTEM_SUFFIX = `
You are Claude Code running in HEADLESS AUTOMATION mode inside an auto-continue orchestrator. You have access to all standard tools (Read, Write, Edit, Bash, Glob, Grep, etc.).

Rules:
1. Execute the task in the user prompt IMMEDIATELY. No greetings, no status summaries, no session startup rituals.
2. When the task is fully complete, end your final message with: [TASK COMPLETE]
3. If blocked and need human input, end with: [TASK BLOCKED: brief reason]
4. If you receive a [HANDOFF REQUEST], write the handoff file as instructed.
5. Work efficiently. Do not repeat completed work. Check for existing files before creating new ones.
6. Do not mention the orchestrator or markers in normal output.
`.trim();

/**
 * B. Wraps the user's task for the initial prompt.
 * Must be forceful enough to override CLAUDE.md session startup rituals.
 */
function buildInitialPrompt(task, contextContent) {
  const parts = [
    `<auto-continue-directive>`,
    `HEADLESS MODE ACTIVE. This is an automated orchestrator session, not an interactive conversation.`,
    `SKIP all session startup checks, greetings, status summaries, and dashboard reviews.`,
    `Execute the following task IMMEDIATELY and DIRECTLY. Do not read current-state.md or schedule-reference.md unless the task specifically requires them.`,
    `</auto-continue-directive>`,
    ``,
  ];

  if (contextContent) {
    parts.push(`## Context from previous work`, ``, contextContent, ``);
  }

  parts.push(`## Task`, ``, task);

  return parts.join('\n');
}

/**
 * C. Continuation prompt for --resume within the same session.
 * Used when max-turns is hit but tokens are still OK.
 */
function buildContinuationPrompt(lastResultSnippet) {
  return `Continue where you left off. Do not repeat work already completed. Pick up from where you stopped and keep making progress toward the original task.`;
}

/**
 * D. Handoff request prompt — tells Claude to write a structured handoff file.
 * Used when token threshold is exceeded and we need to start a fresh session.
 */
function buildHandoffRequestPrompt(filePath, originalTask) {
  return `[HANDOFF REQUEST]

The context window is getting full. Before I start a fresh session, write a comprehensive handoff file so the next session can continue seamlessly.

Use the Write tool to create the file at: ${filePath}

The file MUST contain these sections in this exact format:

# Auto-Continue Handoff

## Original Task
${originalTask}

## Completed Work
(List everything accomplished so far — files created, files modified, analyses done, decisions made)

## Remaining Work
(List what still needs to be done to complete the original task)

## Key Decisions Made
(Any important decisions or choices that the next session should know about)

## Files Modified
(List all files that were created or modified, with a one-line description of each change)

## Critical Context
(Any important context that would be lost — variable values, patterns discovered, errors encountered and resolved)

## Resume Instructions
(Specific instructions for the next session on where to pick up — which file to edit next, what step in the process, etc.)

After writing the file, confirm with: "Handoff file written successfully."`;
}

/**
 * E. New session prompt — feeds handoff content + original task to a fresh session.
 */
function buildNewSessionPrompt(handoffContent, originalTask) {
  return `## Auto-Continue: Resuming from previous session

You are continuing a task that was started in a previous session. The previous session ran out of context space and created a handoff document.

### Handoff from previous session:

${handoffContent}

### Important instructions:
1. Do NOT re-read files that the previous session already processed (they are summarized in the handoff above)
2. Do NOT redo work that is marked as completed
3. Start from the "Remaining Work" section and continue
4. If files were modified, trust that those modifications are correct unless you have reason to doubt
5. When all remaining work is done, end with [TASK COMPLETE]
6. If you get stuck, end with [TASK BLOCKED: reason]

Begin working on the remaining tasks now.`;
}

module.exports = {
  ORCHESTRATOR_SYSTEM_SUFFIX,
  buildInitialPrompt,
  buildContinuationPrompt,
  buildHandoffRequestPrompt,
  buildNewSessionPrompt,
};
