// Simple bundler to regenerate _deploy_pastebin/mastermine.lua
// from the contents of programs/perlytiara/mastermine
// Usage: node scripts/build_bundle.js [--check]
// If --check is passed, the script only validates that the output is up-to-date.

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const outputDir = path.join(repoRoot, '_deploy_pastebin');
const outputFile = path.join(outputDir, 'mastermine.lua');

const INCLUDE_TOP_LEVEL = new Set([
  'LICENSE',
  'README.md',
  'hub.lua',
  'pocket.lua',
  'turtle.lua',
]);

const INCLUDE_DIRS = new Set([
  'hub_files',
  'pocket_files',
  'turtle_files',
]);

function listFilesRecursive(baseDir, rel = '') {
  const full = path.join(baseDir, rel);
  const entries = fs.readdirSync(full, { withFileTypes: true });
  const files = [];
  for (const e of entries) {
    if (e.name === '.git' || e.name === '.DS_Store') continue;
    if (rel === '' && e.isDirectory()) {
      // Only include whitelisted directories at the top-level
      if (!INCLUDE_DIRS.has(e.name)) continue;
    }
    if (rel === '' && e.isFile()) {
      // Only include whitelisted top-level files
      if (!INCLUDE_TOP_LEVEL.has(e.name)) continue;
    }
    const nextRel = path.posix.join(rel.replace(/\\/g, '/'), e.name);
    const nextFull = path.join(baseDir, nextRel);
    if (e.isDirectory()) {
      for (const f of listFilesRecursive(baseDir, nextRel)) files.push(f);
    } else if (e.isFile()) {
      files.push({ relPath: nextRel.replace(/\\/g, '/'), absPath: nextFull });
    }
  }
  return files;
}

function chooseEquals(content) {
  // Find a bracket level that doesn't collide with content
  // We'll try up to 10 '=' signs which should be plenty
  for (let n = 3; n <= 10; n++) {
    const marker = ']'+ '='.repeat(n) +']';
    if (!content.includes(marker)) return '='.repeat(n);
  }
  // Fallback: escape closing brackets by splitting
  return '='.repeat(12);
}

function buildFilesTable(baseDir) {
  const files = listFilesRecursive(baseDir);
  // Stable order: top-level files first, then dirs alphabetically, then files in them
  files.sort((a, b) => a.relPath.localeCompare(b.relPath));
  const lines = [];
  for (let i = 0; i < files.length; i++) {
    const { relPath, absPath } = files[i];
    const content = fs.readFileSync(absPath, 'utf8');
    const eq = chooseEquals(content);
    const open = `[${eq}[`;
    const close = `]${eq}]`;
    const comma = i === files.length - 1 ? '' : ',';
    // Preserve exact file contents, do not normalize newlines
    lines.push(`    ["${relPath}"] = ${open}${content}${close}${comma}`);
  }
  return lines.join('\n');
}

function generateBundle(baseDir) {
  const header = [
    'output_dir = ...',
    'local function find_disk_mount()',
    '    for i = 1, 16 do',
    "        local name = (i == 1) and 'disk' or ('disk' .. i)",
    '        if fs.isDir(name) then return name end',
    '    end',
    '    for _, n in ipairs(fs.list("/")) do',
    '        if string.match(n, "^disk%d*$") and fs.isDir(n) then return n end',
    '    end',
    '    return nil',
    'end',
    'local function ensure_dir(p)',
    '    if not fs.isDir(p) then fs.makeDir(p) end',
    'end',
    'if not output_dir or output_dir == "" then',
    '    output_dir = find_disk_mount() or "disk"',
    'end',
    'path = shell.resolve(output_dir)',
    'if not fs.isDir(path) then',
    '    local alt = find_disk_mount()',
    '    if alt and fs.isDir(alt) then',
    '        path = shell.resolve(alt)',
    '    else',
    '        path = shell.resolve("files")',
    '        ensure_dir(path)',
    '        print("No disk mount found; writing files to ./files")',
    '    end',
    'end',
    '',
    'files = {',
  ].join('\n');

  const tableBody = buildFilesTable(baseDir);

  const footer = [
    '}',
    '',
    'local function ensure_dir_for(file_path)',
    '    local parent = fs.getDir(file_path)',
    '    if parent ~= "" and not fs.exists(parent) then',
    '        fs.makeDir(parent)',
    '    end',
    'end',
    '',
    'for k, v in pairs(files) do',
    '    local target = fs.combine(path, k)',
    '    ensure_dir_for(target)',
    '    local file = fs.open(target, \"w\")',
    '    file.write(v)',
    '    file.close()',
    'end',
    '',
  ].join('\n');

  return `${header}\n${tableBody}\n${footer}`;
}

function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function run() {
  const checkOnly = process.argv.includes('--check');
  const bundle = generateBundle(repoRoot);
  ensureDir(outputDir);
  if (checkOnly && fs.existsSync(outputFile)) {
    const current = fs.readFileSync(outputFile, 'utf8');
    const upToDate = current === bundle;
    process.stdout.write(upToDate ? 'Bundle is up-to-date.\n' : 'Bundle is stale.\n');
    process.exit(upToDate ? 0 : 1);
  }
  fs.writeFileSync(outputFile, bundle, 'utf8');
  process.stdout.write(`Wrote ${path.relative(repoRoot, outputFile)} (size ${bundle.length} bytes)\n`);
}

run();


