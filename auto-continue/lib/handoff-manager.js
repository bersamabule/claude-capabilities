/**
 * Manages handoff files for session transitions.
 * Claude writes the primary handoff; this module provides fallback and tracking.
 */

const fs = require('fs');
const path = require('path');

class HandoffManager {
  constructor(handoffDir, cwd) {
    this.handoffDir = path.isAbsolute(handoffDir)
      ? handoffDir
      : path.join(cwd, handoffDir);
    this.cwd = cwd;
    this.handoffHistory = [];
    this.handoffCounter = 0;
  }

  /**
   * Ensure the handoff directory exists.
   */
  ensureDir() {
    fs.mkdirSync(this.handoffDir, { recursive: true });
  }

  /**
   * Generate the next handoff file path.
   * @returns {string} Absolute path to the handoff file
   */
  nextHandoffPath() {
    this.handoffCounter++;
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
    const filename = `HANDOFF_auto_${this.handoffCounter}_${timestamp}.md`;
    return path.join(this.handoffDir, filename);
  }

  /**
   * Get the relative path (from cwd) for a handoff file — used in prompts.
   * @param {string} absPath
   * @returns {string}
   */
  relativePath(absPath) {
    return path.relative(this.cwd, absPath).replace(/\\/g, '/');
  }

  /**
   * Check if Claude successfully wrote the handoff file.
   * @param {string} filePath
   * @returns {string|null} File content if exists and non-empty, null otherwise
   */
  readHandoff(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf-8').trim();
      return content.length > 50 ? content : null;
    } catch {
      return null;
    }
  }

  /**
   * Write a fallback handoff file when Claude fails to create one.
   * @param {string} filePath - Where to write
   * @param {object} context - Available context
   * @param {string} context.originalTask - The original task
   * @param {string} [context.lastOutput] - Last Claude output
   * @param {object} [context.tokenSummary] - Token usage summary
   * @returns {string} The content written
   */
  writeFallbackHandoff(filePath, context) {
    this.ensureDir();

    const content = `# Auto-Continue Handoff (Fallback)

> This handoff was generated automatically because Claude did not write one.
> Information may be incomplete.

## Original Task
${context.originalTask || 'Unknown'}

## Last Output (truncated)
${(context.lastOutput || 'No output captured').slice(-2000)}

## Token Usage at Handoff
${context.tokenSummary ? JSON.stringify(context.tokenSummary, null, 2) : 'Unknown'}

## Resume Instructions
The previous session was unable to write a proper handoff. Review the last output above
for context on what was accomplished. Continue working on the original task, checking
existing files to understand what progress was made.
`;

    fs.writeFileSync(filePath, content, 'utf-8');
    return content;
  }

  /**
   * Record a successful handoff.
   * @param {string} filePath
   * @param {number} sessionNumber
   */
  recordHandoff(filePath, sessionNumber) {
    this.handoffHistory.push({
      filePath,
      sessionNumber,
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * Get handoff history for logging.
   */
  getHistory() {
    return [...this.handoffHistory];
  }
}

module.exports = { HandoffManager };
