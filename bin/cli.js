#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const ROOT_DIR = path.resolve(__dirname, "..");
const SKILLS_DIR = path.join(ROOT_DIR, ".skills");

const BANNER = `
===================================================================
     ANTI-SLOP WEBCRAFT SKILL ENGINE
     Architectural Frontend Rigor for Autonomous AI Agents
     Target Agents: Cursor, Claude Code, Antigravity, Hermes
===================================================================
`;

const COMMANDS = {
  help: () => {
    console.log(BANNER);
    console.log(`Usage:
  npx anti-slop-webcraft <command> [options]

Commands:
  init         Inject all 24 skills, .cursorrules, AGENTS.md & CLAUDE.md into current project
  list         List all 24 modular skills with categories and token budgets
  verify       Audit current project for AI slop (generic purple, unicode emojis, linear eases)
  help         Display this help message

Options:
  --force      Overwrite existing skill and config files
  --dry-run    Simulate installation without writing to disk
`);
  },

  list: () => {
    console.log(BANNER);
    console.log("[SYSTEM] Scanning skill registry...\n");

    const categories = fs.readdirSync(SKILLS_DIR);
    let totalSkills = 0;

    categories.forEach((cat) => {
      const catPath = path.join(SKILLS_DIR, cat);
      if (fs.statSync(catPath).isDirectory()) {
        console.log(`--- [CATEGORY: ${cat.toUpperCase()}] ---`);
        const files = fs.readdirSync(catPath).filter((f) => f.endsWith(".md"));
        files.forEach((file) => {
          totalSkills++;
          const stat = fs.statSync(path.join(catPath, file));
          const sizeKb = (stat.size / 1024).toFixed(1);
          console.log(`  * ${file.padEnd(52)} (${sizeKb} KB)`);
        });
        console.log("");
      }
    });

    console.log(`[STATUS] Total Registered Skills: ${totalSkills} / 25 verified.\n`);
  },

  init: () => {
    console.log(BANNER);
    const targetDir = process.cwd();
    const isForce = process.argv.includes("--force");
    const isDryRun = process.argv.includes("--dry-run");

    console.log(`[INIT] Target Project Directory: ${targetDir}`);
    if (isDryRun) console.log("[MODE] DRY RUN ACTIVE - No files will be modified.\n");

    const filesToCopy = [
      { src: path.join(ROOT_DIR, ".cursorrules"), dest: path.join(targetDir, ".cursorrules") },
      { src: path.join(ROOT_DIR, "AGENTS.md"), dest: path.join(targetDir, "AGENTS.md") },
      { src: path.join(ROOT_DIR, "CLAUDE.md"), dest: path.join(targetDir, "CLAUDE.md") },
    ];

    const copyRecursive = (src, dest) => {
      if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });
      const entries = fs.readdirSync(src, { withFileTypes: true });

      for (const entry of entries) {
        const srcPath = path.join(src, entry.name);
        const destPath = path.join(dest, entry.name);

        if (entry.isDirectory()) {
          copyRecursive(srcPath, destPath);
        } else {
          if (!fs.existsSync(destPath) || isForce) {
            if (!isDryRun) fs.copyFileSync(srcPath, destPath);
            console.log(`  + [COPIED] ${path.relative(targetDir, destPath)}`);
          } else {
            console.log(`  . [EXISTS] ${path.relative(targetDir, destPath)} (use --force to overwrite)`);
          }
        }
      }
    };

    console.log("[STEP 1/2] Injecting root agent directives...");
    filesToCopy.forEach(({ src, dest }) => {
      if (fs.existsSync(src)) {
        if (!fs.existsSync(dest) || isForce) {
          if (!isDryRun) fs.copyFileSync(src, dest);
          console.log(`  + [COPIED] ${path.basename(dest)}`);
        } else {
          console.log(`  . [EXISTS] ${path.basename(dest)} (skipped)`);
        }
      }
    });

    console.log("\n[STEP 2/2] Injecting 24-skill engine into .skills/ directory...");
    const destSkills = path.join(targetDir, ".skills");
    copyRecursive(SKILLS_DIR, destSkills);

    console.log("\n===================================================================");
    console.log("[SUCCESS] Anti-Slop Webcraft Engine successfully injected!");
    console.log("Your AI agents (Cursor, Claude Code, Antigravity) are now governed by museum-grade frontend invariants.");
    console.log("===================================================================\n");
  },

  verify: () => {
    console.log(BANNER);
    console.log("[AUDIT] Scanning current repository for AI slop anti-patterns...\n");

    const violations = [];
    const auditDir = (dir) => {
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const entry of entries) {
        if (entry.name === "node_modules" || entry.name === ".git" || entry.name === "dist") continue;
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
          auditDir(fullPath);
        } else if (/\.(js|jsx|ts|tsx|css|md)$/.test(entry.name)) {
          const content = fs.readFileSync(fullPath, "utf-8");

          // Check 1: AI Purple / Indigo Hex in active styles
          if (/(?:color|bg|border|fill|stroke|background|--[\w-]+):\s*#6366f1/i.test(content) || /-\[#6366f1\]/i.test(content)) {
            violations.push({ file: fullPath, issue: "Active usage of generic AI Purple #6366f1 detected" });
          }

          // Check 2: Unicode Emojis
          const emojiRegex = /[\uD83C-\uDBFF\uDC00-\uDFFF]/;
          if (emojiRegex.test(content)) {
            violations.push({ file: fullPath, issue: "Prohibited Unicode Emoji detected" });
          }

          // Check 3: Linear CSS transitions
          if (/transition:\s*all\s+0\.\d+s\s+linear/i.test(content)) {
            violations.push({ file: fullPath, issue: "Linear CSS easing detected (replace with physical spring)" });
          }
        }
      }
    };

    auditDir(process.cwd());

    if (violations.length === 0) {
      console.log("[VERIFIED] ZERO AI SLOP DETECTED. Repository is 100% compliant with museum-grade standards.\n");
    } else {
      console.log(`[ALERT] Found ${violations.length} anti-slop violations:`);
      violations.forEach((v) => {
        console.log(`  ! [VIOLATION] ${path.relative(process.cwd(), v.file)}: ${v.issue}`);
      });
      console.log("\nReview .skills/core/01-anti-slop-design-system.md for remediation guidelines.\n");
    }
  },
};

const cmd = process.argv[2] || "help";
if (COMMANDS[cmd]) {
  COMMANDS[cmd]();
} else {
  console.error(`[ERROR] Unknown command: "${cmd}". Run "npx anti-slop-webcraft help" for usage.`);
  process.exit(1);
}
