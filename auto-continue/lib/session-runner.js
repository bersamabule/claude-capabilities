/**
 * Spawns `claude -p` as a child process and returns structured results.
 */

const { spawn } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

// Find the claude.exe binary path
function getClaudePath() {
  const home = process.env.USERPROFILE || process.env.HOME || '';
  const exePath = path.join(home, '.local', 'bin', 'claude.exe');
  if (fs.existsSync(exePath)) return exePath;
  // Fallback: try just 'claude' and hope it's in PATH
  return 'claude';
}

/**
 * Run a Claude CLI session chunk.
 * @param {object} options
 * @param {string} options.prompt - The prompt to send
 * @param {number} options.maxTurns - Max turns for this chunk
 * @param {string} options.permissionMode - Permission mode
 * @param {string} [options.sessionId] - Session ID to resume (omit for new session)
 * @param {string} [options.model] - Model to use
 * @param {string} options.cwd - Working directory
 * @param {string} options.systemPrompt - System prompt (replaces default if provided)
 * @param {number} options.timeoutMs - Timeout in milliseconds
 * @param {boolean} options.verbose - Verbose logging
 * @returns {Promise<{ success: boolean, data: object|null, error: string|null, timedOut: boolean }>}
 */
function runChunk(options) {
  const {
    prompt,
    maxTurns,
    permissionMode,
    sessionId,
    model,
    cwd,
    systemPrompt,
    timeoutMs,
    verbose,
  } = options;

  return new Promise((resolve) => {
    // Build args array — each element is a separate argument, properly handled by Node
    const args = [
      '-p', prompt,
      '--output-format', 'json',
      '--max-turns', String(maxTurns),
      '--permission-mode', permissionMode,
    ];

    if (systemPrompt) {
      args.push('--system-prompt', systemPrompt);
    }

    if (sessionId) {
      args.push('--resume', sessionId);
    }

    if (model) {
      args.push('--model', model);
    }

    // Build clean env without Claude nesting markers
    const env = { ...process.env };
    delete env.CLAUDECODE;
    delete env.CLAUDE_CODE_ENTRYPOINT;

    const claudePath = getClaudePath();

    if (verbose) {
      const argsPreview = args.map((a, i) => {
        // Don't truncate flag names, only truncate long values
        if (a.startsWith('-')) return a;
        return a.length > 80 ? a.slice(0, 77) + '...' : a;
      });
      console.log(`  [runner] ${path.basename(claudePath)} ${argsPreview.join(' ')}`);
    }

    let stdout = '';
    let stderr = '';
    let timedOut = false;

    // Spawn directly with the executable — Node handles argument quoting correctly
    // Using shell:false avoids cmd.exe quoting issues on Windows
    const child = spawn(claudePath, args, {
      cwd,
      env,
      shell: false,
      stdio: ['pipe', 'pipe', 'pipe'],
      windowsHide: true,
    });

    // Close stdin immediately — we're using -p, not interactive
    child.stdin.end();

    child.stdout.on('data', (chunk) => {
      stdout += chunk.toString();
    });

    child.stderr.on('data', (chunk) => {
      stderr += chunk.toString();
    });

    const timer = setTimeout(() => {
      timedOut = true;
      child.kill('SIGTERM');
      setTimeout(() => {
        try { child.kill('SIGKILL'); } catch {}
      }, 5000);
    }, timeoutMs);

    child.on('close', (code) => {
      clearTimeout(timer);

      if (timedOut) {
        return resolve({
          success: false,
          data: null,
          error: `Chunk timed out after ${timeoutMs}ms`,
          timedOut: true,
        });
      }

      // Try to parse JSON from stdout
      try {
        // Claude may output non-JSON lines before the JSON — find the JSON object
        const jsonStart = stdout.indexOf('{');
        const jsonEnd = stdout.lastIndexOf('}');
        if (jsonStart === -1 || jsonEnd === -1) {
          throw new Error('No JSON found in output');
        }
        const jsonStr = stdout.slice(jsonStart, jsonEnd + 1);
        const data = JSON.parse(jsonStr);

        // Check for API errors in the result
        if (data.is_error) {
          return resolve({
            success: false,
            data,
            error: data.result || 'Unknown API error',
            timedOut: false,
          });
        }

        return resolve({
          success: true,
          data,
          error: null,
          timedOut: false,
        });
      } catch (parseErr) {
        // JSON parse failed
        const errorMsg = stderr.trim() || stdout.trim() || `Process exited with code ${code}`;
        return resolve({
          success: false,
          data: null,
          error: `Failed to parse output: ${parseErr.message}. Raw: ${errorMsg.slice(0, 500)}`,
          timedOut: false,
        });
      }
    });

    child.on('error', (err) => {
      clearTimeout(timer);
      resolve({
        success: false,
        data: null,
        error: `Failed to spawn claude: ${err.message}`,
        timedOut: false,
      });
    });
  });
}

module.exports = { runChunk };
