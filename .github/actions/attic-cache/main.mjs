import { appendFileSync } from "node:fs";
import { spawn, spawnSync } from "node:child_process";

const token = process.env.INPUT_TOKEN;
const server = process.env.INPUT_SERVER;
const cache = process.env.INPUT_CACHE;

function run(args) {
  const result = spawnSync("nix", args, { stdio: "inherit" });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}

run(["run", "nixpkgs#attic-client", "login", "local", server, token]);

const watcher = spawn(
  "nix",
  ["run", "nixpkgs#attic-client", "watch-store", cache],
  { detached: true, stdio: "ignore" },
);
watcher.unref();
appendFileSync(process.env.GITHUB_STATE, `watcher_pid=${watcher.pid}\n`);
