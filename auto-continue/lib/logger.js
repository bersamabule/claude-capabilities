/**
 * JSONL run log + markdown summary generation.
 */

const fs = require('fs');
const path = require('path');

class Logger {
  constructor(logsDir, verbose = false) {
    this.logsDir = logsDir;
    this.verbose = verbose;
    this.startTime = Date.now();
    this.events = [];

    // Create logs directory
    fs.mkdirSync(logsDir, { recursive: true });

    // Set up file paths
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
    this.jsonlPath = path.join(logsDir, `run_${timestamp}.jsonl`);
    this.summaryPath = path.join(logsDir, `run_${timestamp}_summary.md`);
  }

  /**
   * Log an event to JSONL file and optionally to console.
   * @param {string} type - Event type (start, chunk, handoff, error, end, etc.)
   * @param {object} data - Event data
   */
  log(type, data = {}) {
    const event = {
      type,
      timestamp: new Date().toISOString(),
      elapsed_ms: Date.now() - this.startTime,
      ...data,
    };

    this.events.push(event);

    // Append to JSONL
    try {
      fs.appendFileSync(this.jsonlPath, JSON.stringify(event) + '\n');
    } catch {
      // Silently fail — logging should not break the orchestrator
    }

    // Console output
    if (this.verbose || type === 'error' || type === 'end') {
      const prefix = `[${this.formatElapsed(event.elapsed_ms)}]`;
      switch (type) {
        case 'start':
          console.log(`${prefix} Starting: ${data.task?.slice(0, 80) || 'unknown task'}...`);
          break;
        case 'chunk_start':
          console.log(`${prefix} Chunk ${data.chunkNumber} (session ${data.sessionNumber}, turns: ${data.maxTurns})`);
          break;
        case 'chunk_end':
          console.log(`${prefix} Chunk done — context: ${data.contextPercent}%, cost: $${data.chunkCost?.toFixed(2)}, turns: ${data.numTurns}`);
          break;
        case 'handoff':
          console.log(`${prefix} Handoff triggered at ${data.contextPercent}% — starting session ${data.nextSession}`);
          break;
        case 'continuation':
          console.log(`${prefix} Continuing in same session (context: ${data.contextPercent}%)`);
          break;
        case 'complete':
          console.log(`${prefix} Task complete! ${data.reason || ''}`);
          break;
        case 'blocked':
          console.log(`${prefix} Task blocked: ${data.blocker || 'unknown'}`);
          break;
        case 'error':
          console.error(`${prefix} Error: ${data.error || 'unknown'}`);
          break;
        case 'retry':
          console.log(`${prefix} Retrying in ${data.delayMs / 1000}s (${data.reason})`);
          break;
        case 'abort':
          console.log(`${prefix} Aborting: ${data.reason}`);
          break;
        case 'end':
          console.log(`${prefix} Run ended — ${data.outcome}. Total cost: $${data.totalCost?.toFixed(2)}`);
          break;
        default:
          if (this.verbose) {
            console.log(`${prefix} [${type}] ${JSON.stringify(data).slice(0, 200)}`);
          }
      }
    }
  }

  /**
   * Format milliseconds as MM:SS.
   */
  formatElapsed(ms) {
    const totalSec = Math.floor(ms / 1000);
    const min = Math.floor(totalSec / 60);
    const sec = totalSec % 60;
    return `${String(min).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
  }

  /**
   * Write the markdown summary at the end of a run.
   * @param {object} summary
   */
  writeSummary(summary) {
    const elapsed = Date.now() - this.startTime;
    const lines = [
      '# Auto-Continue Run Summary',
      '',
      `**Task**: ${summary.task || 'unknown'}`,
      `**Outcome**: ${summary.outcome}`,
      `**Started**: ${new Date(this.startTime).toISOString()}`,
      `**Duration**: ${this.formatElapsed(elapsed)}`,
      '',
      '## Stats',
      '',
      '| Metric | Value |',
      '|--------|-------|',
      `| Sessions | ${summary.totalSessions} |`,
      `| Chunks | ${summary.totalChunks} |`,
      `| Total Cost | $${summary.totalCost?.toFixed(2)} |`,
      `| Total Input Tokens | ${summary.totalInputTokens?.toLocaleString()} |`,
      `| Total Output Tokens | ${summary.totalOutputTokens?.toLocaleString()} |`,
      `| Handoffs | ${summary.handoffs} |`,
      '',
      '## Chunk History',
      '',
      '| # | Session | Turns | Context% | Cost | Result |',
      '|---|---------|-------|----------|------|--------|',
    ];

    for (const chunk of summary.chunks || []) {
      lines.push(
        `| ${chunk.number} | ${chunk.session} | ${chunk.turns} | ${chunk.contextPercent}% | $${chunk.cost?.toFixed(2)} | ${chunk.result} |`
      );
    }

    if (summary.handoffFiles && summary.handoffFiles.length > 0) {
      lines.push('', '## Handoff Files', '');
      for (const hf of summary.handoffFiles) {
        lines.push(`- \`${hf.filePath}\` (session ${hf.sessionNumber})`);
      }
    }

    if (summary.errors && summary.errors.length > 0) {
      lines.push('', '## Errors', '');
      for (const err of summary.errors) {
        lines.push(`- ${err}`);
      }
    }

    lines.push('');

    try {
      fs.writeFileSync(this.summaryPath, lines.join('\n'), 'utf-8');
    } catch {
      // Silent fail
    }
  }
}

module.exports = { Logger };
