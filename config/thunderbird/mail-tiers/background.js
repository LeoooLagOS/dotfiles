// lagOS mail tiers: every listed folder has an importance tier, [markReadDays, deleteDays].
// Mail older than markReadDays is marked read; older than deleteDays goes to the Trash.
// null means "never". Runs at startup and every hour while Thunderbird is open.
//
// tiers.json is built into the add-on at install time (build.sh). It names your
// accounts, so it lives in ~/.config/lagos/mail/, never in the repo:
//   { "dryRun": true, "protect": { "money": ["receipt", "recibo"] },
//     "accounts": { "you@example.com": { "/Promos": [7, 14, ["money"]], "/Dev": [90, 180] } } }
// With dryRun the add-on only counts and reports; nothing is changed.

const DAY = 24 * 60 * 60 * 1000;

async function loadConfig() {
  const res = await fetch(messenger.runtime.getURL("tiers.json"));
  return res.json();
}

// All folders of an account, depth first (generator: yields one at a time)
function* walk(folders) {
  for (const f of folders ?? []) {
    yield f;
    yield* walk(f.subFolders);
  }
}

// messages.query returns pages; this hides the paging (async generator)
async function* query(queryInfo) {
  let page = await messenger.messages.query(queryInfo);
  while (true) {
    yield* page.messages;
    if (!page.id) return;
    page = await messenger.messages.continueList(page.id);
  }
}

// Safety net: a subject containing a "protect" phrase (certificates, results, receipts…)
// is never moved to the Trash, only marked read. In Gmail a folder is a label, so
// trashing a copy from an old folder would trash the message everywhere.
// cfg.protect groups phrases ({ "money": [...], "outcomes": [...] }). A folder can name
// the groups that apply to it as a third value: "/Promos": [7, 14, ["money"]], because
// ads love words like "selected" or "approved". Without it, every group applies.
function protector(cfg, groups) {
  const names = groups ?? Object.keys(cfg.protect ?? {});
  const phrases = names.flatMap(g => cfg.protect?.[g] ?? []).map(p => p.toLowerCase());
  return subject => {
    const s = (subject ?? "").toLowerCase();
    return phrases.some(p => s.includes(p));
  };
}

async function applyTiers(cfg) {
  const stats = { read: 0, deleted: 0, protected: 0, missing: [], errors: [] };
  const now = Date.now();
  for (const account of await messenger.accounts.list(true)) {
    const email = account.identities?.[0]?.email ?? account.name;
    const tiers = cfg.accounts[email];
    if (!tiers) continue;
    const top = account.rootFolder?.subFolders ?? account.folders;
    const byPath = new Map([...walk(top)].map(f => [f.path, f]));

    for (const [path, [readDays, deleteDays, protectGroups]] of Object.entries(tiers)) {
      const folder = byPath.get(path);
      if (!folder) { stats.missing.push(`${email}${path}`); continue; }
      const isProtected = protector(cfg, protectGroups);
      try {

        // Delete first, so the mark-read pass doesn't touch mail that is about to go
        const deleted = new Set();
        if (deleteDays != null) {
          const before = new Date(now - deleteDays * DAY);
          for await (const m of query({ folderId: folder.id, toDate: before })) {
            if (isProtected(m.subject)) { stats.protected++; continue; }  // only ever marked read
            deleted.add(m.id);
          }
          if (deleted.size && !cfg.dryRun) await messenger.messages.delete([...deleted]); // no options: to the Trash
          stats.deleted += deleted.size;
        }
        if (readDays != null) {
          const before = new Date(now - readDays * DAY);
          for await (const m of query({ folderId: folder.id, unread: true, toDate: before })) {
            if (deleted.has(m.id)) continue;   // dry run: still listed, but it would be gone
            if (!cfg.dryRun) await messenger.messages.update(m.id, { read: true });
            stats.read++;
          }
        }
      } catch (e) {
        // One folder failing (server busy, folder renamed…) must not stop the others
        console.error("mail-tiers", email + path, e);
        stats.errors.push(`${email.split("@")[0]}${path}: ${e.message ?? e}`);
      }
    }
  }
  return stats;
}

async function run() {
  const cfg = await loadConfig();
  const s = await applyTiers(cfg);
  console.log("mail-tiers", cfg.dryRun ? "(dry run)" : "", s);
  // Only speak when something happened (or always in a dry run, which is a test)
  if (cfg.dryRun || s.read || s.deleted || s.missing.length || s.errors.length) {
    const verb = cfg.dryRun ? "Would mark" : "Marked";
    let message = `${verb} ${s.read} read · ${cfg.dryRun ? "would move" : "moved"} ${s.deleted} to Trash`;
    if (s.protected) message += ` · kept ${s.protected} protected`;
    if (s.missing.length) message += `\nMissing folders: ${s.missing.join(", ")}`;
    if (s.errors.length) message += `\nErrors: ${s.errors.join("; ")}`;
    messenger.notifications.create({ type: "basic", title: "Mail tiers" + (cfg.dryRun ? " (dry run)" : ""), message });
  }
}

messenger.alarms.create("mail-tiers", { periodInMinutes: 60 });
messenger.alarms.onAlarm.addListener(alarm => { if (alarm.name === "mail-tiers") run(); });
run(); // background scripts load at startup and on install
