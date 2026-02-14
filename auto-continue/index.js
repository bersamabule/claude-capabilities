#!/usr/bin/env node

/**
 * Auto-Continue Orchestrator
 *
 * Wraps Claude Code CLI with automatic context handoff:
 * 1. Runs Claude in headless mode (-p) with chunked execution (--max-turns)
 * 2. Monitors token usage after each chunk
 * 3. When context hits threshold, triggers handoff and spawns fresh session
 * 4. Repeats until task complete or safety limits hit
 *
 * Usage:
 *   node index.js "task description" [options]
 *
 * Zero dependencies — Node.js builtins only.
 */

const fs = require('fs');
const path = require('path');
const { loadConfig } = require('./config');
const { runChunk } = require('./lib/session-runner');
const { TokenTracker } = require('./lib/token-tracker');
const { HandoffManager } = require('./lib/handoff-manager');
const { detectCompletion } = require('./lib/completion-detector');
const { Logger } = require('./lib/logger');
const {
  ORCHESTRATOR_SYSTEM_SUFFIX,
  buildInitialPrompt,
  buildContinuationPrompt,
  buildHandoffRequestPrompt,
  buildNewSessionPrompt,
} = require('./lib/prompts');

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  const { config, task } = loadConfig(process.argv.slice(2));

  if (!task) {
    console.error('Error: No task provided. Usage: node index.js "task description" [options]');
    process.exit(1);
  }

  // Load context file if provided
  let contextContent = null;
  if (config.contextFile) {
    try {
      const ctxPath = path.isAbsolute(config.contextFile)
        ? config.contextFile
        : path.join(config.workingDirectory, config.contextFile);
      contextContent = fs.readFileSync(ctxPath, 'utf-8');
    } catch (err) {
      console.error(`Warning: Could not read context file: ${err.message}`);
    }
  }

  // Dry run
  if (config.dryRun) {
    console.log('=== DRY RUN ===');
    console.log('Task:', task);
    console.log('Config:', JSON.stringify(config, null, 2));
    console.log('Would run: claude -p "<prompt>" --output-format json --max-turns', config.turnsPerChunk);
    process.exit(0);
  }

  // Initialize components
  const logsDir = path.join(__dirname, 'logs');
  const logger = new Logger(logsDir, config.verbose);
  const tracker = new TokenTracker(config.tokenThresholdPercent);
  const handoffMgr = new HandoffManager(config.handoffDirectory, config.workingDirectory);

  // Run state
  let sessionNumber = 1;
  let chunkNumber = 0;
  let currentSessionId = null;
  let stalledChunks = 0;
  let currentPrompt = buildInitialPrompt(task, contextContent);
  let isNewSession = true;
  const errors = [];
  const chunkHistory = [];
  const startTime = Date.now();

  logger.log('start', { task, config: { ...config, _task: undefined } });

  console.log('');
  console.log('╔═══════════════════════════════════════════════════════╗');
  console.log('║           Auto-Continue Orchestrator v1.0            ║');
  console.log('╠═══════════════════════════════════════════════════════╣');
  console.log(`║ Task: ${task.slice(0, 47).padEnd(47)} ║`);
  console.log(`║ Turns/chunk: ${String(config.turnsPerChunk).padEnd(40)} ║`);
  console.log(`║ Threshold: ${String(config.tokenThresholdPercent + '%').padEnd(42)} ║`);
  console.log(`║ Max sessions: ${String(config.maxSessions).padEnd(39)} ║`);
  console.log(`║ Max cost: $${String(config.maxTotalCostUsd).padEnd(42)} ║`);
  console.log('╚═══════════════════════════════════════════════════════╝');
  console.log('');

  // ─── Main Loop ────────────────────────────────────────────────────────────

  while (true) {
    chunkNumber++;

    // ─── Safety checks ──────────────────────────────────────────────────────

    // Time limit
    const elapsedMin = (Date.now() - startTime) / 60000;
    if (elapsedMin > config.maxTotalDurationMinutes) {
      logger.log('abort', { reason: `Time limit exceeded: ${Math.round(elapsedMin)}min > ${config.maxTotalDurationMinutes}min` });
      break;
    }

    // Cost limit
    if (tracker.totalCostUsd > config.maxTotalCostUsd) {
      logger.log('abort', { reason: `Cost limit exceeded: $${tracker.totalCostUsd.toFixed(2)} > $${config.maxTotalCostUsd}` });
      break;
    }

    // Session limit
    if (sessionNumber > config.maxSessions) {
      logger.log('abort', { reason: `Session limit exceeded: ${sessionNumber} > ${config.maxSessions}` });
      break;
    }

    // Stall detection
    if (stalledChunks >= config.stalledChunkThreshold) {
      logger.log('abort', { reason: `Stalled: ${stalledChunks} consecutive chunks with no progress` });
      break;
    }

    // ─── Start new session if needed ────────────────────────────────────────

    if (isNewSession) {
      tracker.startSession(`session-${sessionNumber}`);
      currentSessionId = null; // will be set from first chunk's response
      isNewSession = false;
    }

    // ─── Run chunk ──────────────────────────────────────────────────────────

    logger.log('chunk_start', {
      chunkNumber,
      sessionNumber,
      maxTurns: config.turnsPerChunk,
      hasSessionId: !!currentSessionId,
    });

    const chunkResult = await runChunk({
      prompt: currentPrompt,
      maxTurns: config.turnsPerChunk,
      permissionMode: config.permissionMode,
      sessionId: currentSessionId,
      model: config.model,
      cwd: config.workingDirectory,
      systemPrompt: ORCHESTRATOR_SYSTEM_SUFFIX,
      timeoutMs: config.chunkTimeoutMs,
      verbose: config.verbose,
    });

    // ─── Handle chunk failure ───────────────────────────────────────────────

    if (!chunkResult.success) {
      const errMsg = chunkResult.error || 'Unknown error';

      // Timeout
      if (chunkResult.timedOut) {
        logger.log('error', { error: 'Chunk timed out', chunkNumber });
        errors.push(`Chunk ${chunkNumber}: timed out`);
        // Treat as stall — might be stuck in a loop
        stalledChunks++;
        chunkHistory.push({ number: chunkNumber, session: sessionNumber, turns: '?', contextPercent: '?', cost: 0, result: 'TIMEOUT' });
        currentPrompt = buildContinuationPrompt('');
        continue;
      }

      // Rate limit / overloaded
      if (errMsg.includes('rate limit') || errMsg.includes('429')) {
        logger.log('retry', { reason: 'Rate limited', delayMs: config.retryDelayMs });
        await sleep(config.retryDelayMs);
        chunkNumber--; // retry doesn't count
        continue;
      }

      if (errMsg.includes('overloaded') || errMsg.includes('529')) {
        logger.log('retry', { reason: 'API overloaded', delayMs: config.overloadDelayMs });
        await sleep(config.overloadDelayMs);
        chunkNumber--;
        continue;
      }

      // Unrecoverable error
      logger.log('error', { error: errMsg, chunkNumber });
      errors.push(`Chunk ${chunkNumber}: ${errMsg}`);
      break;
    }

    // ─── Process successful chunk ───────────────────────────────────────────

    const data = chunkResult.data;
    const resultText = data.result || '';
    const subtype = data.subtype || 'success';

    // Track session ID for resume
    if (data.session_id && !currentSessionId) {
      currentSessionId = data.session_id;
    }

    // Track tokens
    const tokenStatus = tracker.recordChunk(data);

    logger.log('chunk_end', {
      chunkNumber,
      sessionNumber,
      subtype,
      contextPercent: tokenStatus.contextPercent,
      overThreshold: tokenStatus.overThreshold,
      progress: tokenStatus.progress,
      chunkCost: data.total_cost_usd || 0,
      numTurns: data.num_turns || 0,
      resultSnippet: resultText.slice(-300),
    });

    chunkHistory.push({
      number: chunkNumber,
      session: sessionNumber,
      turns: data.num_turns || 0,
      contextPercent: tokenStatus.contextPercent,
      cost: data.total_cost_usd || 0,
      result: subtype,
    });

    // Progress tracking for stall detection
    if (tokenStatus.progress) {
      stalledChunks = 0;
    } else {
      stalledChunks++;
      if (config.verbose) {
        console.log(`  [stall] No progress detected (${stalledChunks}/${config.stalledChunkThreshold})`);
      }
    }

    // ─── Check for task completion ──────────────────────────────────────────

    const completion = detectCompletion(resultText);

    if (completion.isComplete) {
      logger.log('complete', { reason: completion.reason, chunkNumber });
      console.log('');
      console.log('Task completed successfully!');
      console.log(`  Reason: ${completion.reason}`);

      // Print the final result snippet
      const snippet = resultText.replace('[TASK COMPLETE]', '').trim();
      if (snippet.length > 0) {
        console.log('');
        console.log('── Final output ──────────────────────────────────────');
        console.log(snippet.slice(-1000));
        console.log('─────────────────────────────────────────────────────');
      }

      finalize(logger, tracker, handoffMgr, task, 'COMPLETE', chunkHistory, errors);
      process.exit(0);
    }

    if (completion.isBlocked) {
      logger.log('blocked', { blocker: completion.blocker, chunkNumber });
      console.log('');
      console.log(`Task blocked: ${completion.blocker}`);
      finalize(logger, tracker, handoffMgr, task, 'BLOCKED', chunkHistory, errors);
      process.exit(1);
    }

    // ─── Decide: handoff, continue, or natural complete ───────────────────

    // KEY INSIGHT: When subtype is 'success', Claude stopped its agent loop
    // voluntarily (didn't exhaust turns). This almost always means the task
    // is done — Claude just didn't include the explicit [TASK COMPLETE] marker.
    // Only 'error_max_turns' means Claude was cut off mid-work.

    if (subtype === 'success' && !completion.isBlocked) {
      // Claude completed naturally without using all turns
      logger.log('complete', { reason: 'Natural completion (subtype: success)', chunkNumber });
      console.log('');
      console.log('Task completed (natural completion — Claude finished before max turns).');

      const snippet = resultText.trim();
      if (snippet.length > 0) {
        console.log('');
        console.log('── Final output ──────────────────────────────────────');
        console.log(snippet.slice(-1500));
        console.log('─────────────────────────────────────────────────────');
      }

      finalize(logger, tracker, handoffMgr, task, 'COMPLETE', chunkHistory, errors);
      process.exit(0);
    }

    // From here, subtype is 'error_max_turns' — Claude needs more turns.

    if (tokenStatus.overThreshold) {
      // Context is getting full — trigger handoff
      await performHandoff(
        config, logger, tracker, handoffMgr, task, resultText,
        currentSessionId, sessionNumber, tokenStatus, config.verbose
      );

      // Start fresh session
      sessionNumber++;
      isNewSession = true;
      stalledChunks = 0;
      currentSessionId = null;
      currentPrompt = buildNewSessionPrompt(
        handoffMgr.getHistory().length > 0
          ? fs.readFileSync(handoffMgr.getHistory().at(-1).filePath, 'utf-8')
          : `Previous session ran out of context. Original task: ${task}`,
        task
      );

      console.log(`  Session ${sessionNumber - 1} → ${sessionNumber} (handoff at ${tokenStatus.contextPercent}%)`);

    } else {
      // Max turns exhausted but context OK — resume in same session
      logger.log('continuation', { contextPercent: tokenStatus.contextPercent });
      currentPrompt = buildContinuationPrompt(resultText.slice(-500));
    }
  }

  // ─── Loop exited via safety check ─────────────────────────────────────────

  finalize(logger, tracker, handoffMgr, task, 'ABORTED', chunkHistory, errors);
  process.exit(2);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function performHandoff(config, logger, tracker, handoffMgr, task, resultText, sessionId, sessionNumber, tokenStatus, verbose) {
  const handoffPath = handoffMgr.nextHandoffPath();
  const handoffRelPath = handoffMgr.relativePath(handoffPath);

  logger.log('handoff', {
    contextPercent: tokenStatus.contextPercent,
    nextSession: sessionNumber + 1,
    handoffPath: handoffRelPath,
  });

  // Ask Claude to write the handoff file
  const handoffPrompt = buildHandoffRequestPrompt(handoffRelPath, task);
  const handoffResult = await runChunk({
    prompt: handoffPrompt,
    maxTurns: 5,
    permissionMode: config.permissionMode,
    sessionId,
    model: config.model,
    cwd: config.workingDirectory,
    systemSuffix: ORCHESTRATOR_SYSTEM_SUFFIX,
    timeoutMs: config.chunkTimeoutMs,
    verbose,
  });

  // Track cost of handoff chunk
  if (handoffResult.success && handoffResult.data) {
    tracker.recordChunk(handoffResult.data);
  }

  // Read the handoff file (or create fallback)
  handoffMgr.ensureDir();
  let handoffContent = handoffMgr.readHandoff(handoffPath);

  if (!handoffContent) {
    if (verbose) {
      console.log('  [handoff] Claude did not write handoff file — creating fallback');
    }
    handoffContent = handoffMgr.writeFallbackHandoff(handoffPath, {
      originalTask: task,
      lastOutput: resultText,
      tokenSummary: tracker.getSummary(),
    });
  }

  handoffMgr.recordHandoff(handoffPath, sessionNumber);
}

function finalize(logger, tracker, handoffMgr, task, outcome, chunkHistory, errors) {
  const summary = tracker.getSummary();

  logger.log('end', {
    outcome,
    totalCost: summary.totalCostUsd,
    totalSessions: summary.totalSessions,
    totalChunks: summary.totalChunks,
  });

  logger.writeSummary({
    task,
    outcome,
    totalSessions: summary.totalSessions,
    totalChunks: summary.totalChunks,
    totalCost: summary.totalCostUsd,
    totalInputTokens: summary.totalInputTokens,
    totalOutputTokens: summary.totalOutputTokens,
    handoffs: handoffMgr.getHistory().length,
    handoffFiles: handoffMgr.getHistory(),
    chunks: chunkHistory,
    errors,
  });

  console.log('');
  console.log('╔═══════════════════════════════════════════════════════╗');
  console.log(`║ Outcome: ${outcome.padEnd(44)} ║`);
  console.log(`║ Sessions: ${String(summary.totalSessions).padEnd(43)} ║`);
  console.log(`║ Chunks: ${String(summary.totalChunks).padEnd(45)} ║`);
  console.log(`║ Total cost: $${summary.totalCostUsd.toFixed(2).padEnd(40)} ║`);
  console.log(`║ Log: ${path.basename(logger.jsonlPath).padEnd(48)} ║`);
  console.log('╚═══════════════════════════════════════════════════════╝');
}

// ─── Run ──────────────────────────────────────────────────────────────────────

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(99);
});
