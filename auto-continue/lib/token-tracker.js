/**
 * Tracks token usage across chunks and sessions.
 * Determines when context is getting full and a handoff is needed.
 */

class TokenTracker {
  constructor(thresholdPercent = 75) {
    this.thresholdPercent = thresholdPercent;
    this.contextWindow = 200000; // default, updated from API response
    this.sessions = []; // array of session tracking objects
    this.currentSession = null;
    this.totalCostUsd = 0;
    this.totalInputTokens = 0;
    this.totalOutputTokens = 0;
  }

  /**
   * Start tracking a new session (resets context tracking).
   */
  startSession(sessionId) {
    this.currentSession = {
      sessionId,
      chunks: [],
      lastContextUsed: 0,
      lastContextPercent: 0,
    };
    this.sessions.push(this.currentSession);
  }

  /**
   * Record a chunk's token usage from Claude's JSON output.
   * @param {object} jsonResult - The parsed JSON output from `claude -p --output-format json`
   * @returns {{ contextUsed: number, contextPercent: number, overThreshold: boolean, progress: boolean }}
   */
  recordChunk(jsonResult) {
    if (!this.currentSession) {
      this.startSession(jsonResult.session_id || 'unknown');
    }

    // Extract token counts from usage (top-level)
    const usage = jsonResult.usage || {};
    const inputTokens = usage.input_tokens || 0;
    const cacheCreation = usage.cache_creation_input_tokens || 0;
    const cacheRead = usage.cache_read_input_tokens || 0;
    const outputTokens = usage.output_tokens || 0;

    // Extract from modelUsage for context window size
    const modelUsage = jsonResult.modelUsage || {};
    const modelKeys = Object.keys(modelUsage);
    if (modelKeys.length > 0) {
      const model = modelUsage[modelKeys[0]];
      if (model.contextWindow) {
        this.contextWindow = model.contextWindow;
      }
    }

    // Total tokens in the current context = input + cacheCreation + cacheRead + output
    // This represents the cumulative context used in this session
    // For --resume sessions, this grows with each chunk
    const contextUsed = inputTokens + cacheCreation + cacheRead + outputTokens;
    const contextPercent = Math.round((contextUsed / this.contextWindow) * 100);

    // Track cost
    const chunkCost = jsonResult.total_cost_usd || 0;
    this.totalCostUsd += chunkCost;
    this.totalInputTokens += inputTokens + cacheCreation + cacheRead;
    this.totalOutputTokens += outputTokens;

    // Determine progress: did this chunk actually do something?
    const numTurns = jsonResult.num_turns || 0;
    const progress = outputTokens > 50 || numTurns > 1;

    const chunkData = {
      inputTokens,
      cacheCreation,
      cacheRead,
      outputTokens,
      contextUsed,
      contextPercent,
      cost: chunkCost,
      numTurns,
      progress,
      timestamp: Date.now(),
    };

    this.currentSession.chunks.push(chunkData);
    this.currentSession.lastContextUsed = contextUsed;
    this.currentSession.lastContextPercent = contextPercent;

    return {
      contextUsed,
      contextPercent,
      overThreshold: contextPercent >= this.thresholdPercent,
      progress,
    };
  }

  /**
   * Get summary stats for logging.
   */
  getSummary() {
    const totalChunks = this.sessions.reduce((sum, s) => sum + s.chunks.length, 0);
    return {
      totalSessions: this.sessions.length,
      totalChunks,
      totalCostUsd: Math.round(this.totalCostUsd * 100) / 100,
      totalInputTokens: this.totalInputTokens,
      totalOutputTokens: this.totalOutputTokens,
      contextWindow: this.contextWindow,
      currentContextPercent: this.currentSession ? this.currentSession.lastContextPercent : 0,
    };
  }
}

module.exports = { TokenTracker };
