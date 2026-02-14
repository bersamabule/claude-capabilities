/**
 * Configuration loader: defaults < config.json < CLI overrides
 */

const fs = require('fs');
const path = require('path');

const DEFAULTS = {
  turnsPerChunk: 15,
  tokenThresholdPercent: 75,
  maxSessions: 5,
  maxTotalCostUsd: 10.0,
  maxTotalDurationMinutes: 120,
  stalledChunkThreshold: 2,
  permissionMode: 'acceptEdits',
  handoffDirectory: 'docs/context/auto-continue',
  workingDirectory: 'C:\\Claude-Work',
  model: null,
  verbose: false,
  chunkTimeoutMs: 600000,
  retryDelayMs: 60000,
  overloadDelayMs: 30000,
};

function loadFileConfig() {
  const configPath = path.join(__dirname, 'config.json');
  try {
    const raw = fs.readFileSync(configPath, 'utf-8');
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function parseArgs(argv) {
  const args = { _task: null };
  let i = 0;

  while (i < argv.length) {
    const arg = argv[i];

    if (arg === '--turns') {
      args.turnsPerChunk = parseInt(argv[++i], 10);
    } else if (arg === '--threshold') {
      args.tokenThresholdPercent = parseInt(argv[++i], 10);
    } else if (arg === '--max-sessions') {
      args.maxSessions = parseInt(argv[++i], 10);
    } else if (arg === '--max-cost') {
      args.maxTotalCostUsd = parseFloat(argv[++i]);
    } else if (arg === '--max-time') {
      args.maxTotalDurationMinutes = parseInt(argv[++i], 10);
    } else if (arg === '--model') {
      args.model = argv[++i];
    } else if (arg === '--cwd') {
      args.workingDirectory = argv[++i];
    } else if (arg === '--context') {
      args.contextFile = argv[++i];
    } else if (arg === '--verbose') {
      args.verbose = true;
    } else if (arg === '--dry-run') {
      args.dryRun = true;
    } else if (arg === '--permission-mode') {
      args.permissionMode = argv[++i];
    } else if (arg === '--handoff-dir') {
      args.handoffDirectory = argv[++i];
    } else if (arg === '--help' || arg === '-h') {
      printHelp();
      process.exit(0);
    } else if (!arg.startsWith('--')) {
      // First non-flag argument is the task
      if (!args._task) {
        args._task = arg;
      }
    }

    i++;
  }

  return args;
}

function printHelp() {
  console.log(`
Auto-Continue Orchestrator — wraps Claude Code CLI with automatic context handoff

Usage:
  node index.js "task description" [options]

Options:
  --turns N              Turns per chunk (default: 15)
  --threshold N          Token threshold % to trigger handoff (default: 75)
  --max-sessions N       Max fresh sessions (default: 5)
  --max-cost N           Max total cost in USD (default: 10.0)
  --max-time N           Max total duration in minutes (default: 120)
  --model MODEL          Model to use (default: auto)
  --cwd PATH             Working directory (default: C:\\Claude-Work)
  --context FILE         Context file to feed into initial prompt
  --permission-mode MODE Permission mode (default: acceptEdits)
  --handoff-dir PATH     Handoff directory relative to cwd (default: docs/context/auto-continue)
  --verbose              Verbose logging
  --dry-run              Show what would run without executing
  --help, -h             Show this help
`);
}

function loadConfig(argv) {
  const fileConfig = loadFileConfig();
  const cliArgs = parseArgs(argv);

  // Merge: defaults < file config < CLI overrides
  const config = { ...DEFAULTS };

  for (const [key, value] of Object.entries(fileConfig)) {
    if (value !== null && value !== undefined) {
      config[key] = value;
    }
  }

  const task = cliArgs._task;
  delete cliArgs._task;

  for (const [key, value] of Object.entries(cliArgs)) {
    if (value !== null && value !== undefined) {
      config[key] = value;
    }
  }

  return { config, task };
}

module.exports = { loadConfig, DEFAULTS };
