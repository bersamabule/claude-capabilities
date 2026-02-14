/**
 * Detects task completion or blocking markers in Claude's output.
 */

/**
 * Parse the result text for completion/blocking markers.
 * @param {string} resultText - The text output from Claude
 * @returns {{ isComplete: boolean, isBlocked: boolean, blocker: string|null, reason: string|null }}
 */
function detectCompletion(resultText) {
  if (!resultText || typeof resultText !== 'string') {
    return { isComplete: false, isBlocked: false, blocker: null, reason: null };
  }

  // Primary: exact markers
  const completeMatch = resultText.includes('[TASK COMPLETE]');
  const blockedMatch = resultText.match(/\[TASK BLOCKED:\s*(.+?)\]/);

  if (completeMatch) {
    return { isComplete: true, isBlocked: false, blocker: null, reason: 'Explicit [TASK COMPLETE] marker' };
  }

  if (blockedMatch) {
    return { isComplete: false, isBlocked: true, blocker: blockedMatch[1].trim(), reason: 'Explicit [TASK BLOCKED] marker' };
  }

  // Secondary: natural language detection in the last 500 chars
  const tail = resultText.slice(-500).toLowerCase();
  const completionPhrases = [
    'all tasks completed',
    'all tasks have been completed',
    'task is complete',
    'task is now complete',
    'all done',
    'everything has been completed',
    'finished all',
    'completed all requested',
    'that completes the task',
    'that completes everything',
  ];

  const blockerPhrases = [
    'cannot proceed without',
    'need your input',
    'waiting for your',
    'need clarification',
    'unable to continue',
    'blocked by',
    'requires manual',
  ];

  for (const phrase of completionPhrases) {
    if (tail.includes(phrase)) {
      return { isComplete: true, isBlocked: false, blocker: null, reason: `Natural language: "${phrase}"` };
    }
  }

  for (const phrase of blockerPhrases) {
    if (tail.includes(phrase)) {
      return { isComplete: false, isBlocked: true, blocker: phrase, reason: `Natural language: "${phrase}"` };
    }
  }

  return { isComplete: false, isBlocked: false, blocker: null, reason: null };
}

module.exports = { detectCompletion };
