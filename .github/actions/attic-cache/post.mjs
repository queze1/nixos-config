import { existsSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";

const watcherPid = process.env.STATE_WATCHER_PID;
const cache = process.env.INPUT_CACHE;
const outputPathsFile = process.env.INPUT_OUTPUT_PATHS_FILE;

if (watcherPid) {
  try {
    process.kill(-Number(watcherPid), "SIGTERM");
  } catch (error) {
    if (error.code !== "ESRCH") throw error;
  }
}

if (!existsSync(outputPathsFile)) process.exit(0);

const paths = readFileSync(outputPathsFile, "utf8").split("\n").filter(Boolean);
if (paths.length === 0) process.exit(0);

const result = spawnSync(
  "nix",
  ["run", "nixpkgs#attic-client", "push", cache, ...paths],
  { stdio: "inherit" },
);
if (result.error) throw result.error;
if (result.status !== 0) process.exit(result.status ?? 1);
