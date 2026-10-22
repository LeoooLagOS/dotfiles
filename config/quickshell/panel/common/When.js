.pragma library

// Natural language for the calendar (Spanish and English): what to do and when.
//   parse("entregar reporte de redes viernes 18:00", now) →
//     { title: "Entregar reporte de redes", kind: "task", date: "2026-10-16",
//       start: "18:00", end: "", allDay: false, repeat: "", place: "" }
//   kind   "task" (something to do: entregar, tarea, estudiar, pagar… or no
//          time given) or "event" (clase, reunión, examen… or a time given);
//          "#tarea" / "#task" / "#evento" / "#event" decide it
//   date   today / hoy, tomorrow / mañana, pasado mañana, a weekday (the next
//          one; "próximo"/"next" skips today), "en 3 días" / "in 3 days",
//          "la próxima semana" / "next week" (Monday), "15 de octubre",
//          "15 oct", "Oct 15", "15/10[/2026]"
//   start  "18:00", "6pm", "6:30 pm", "a las 6", "at 6", mediodía / noon;
//          a range: "de 10 a 12", "10:00-12:00", "from 10 to 12"
//   repeat "daily" | "weekdays" | "weekly" | "monthly": "todos los días",
//          "entre semana", "cada lunes", "every week", "cada mes"…
//   place  "@ biblioteca", "en la biblioteca", "en el aula 3", CCO3 310
// describe(r) → the chips the capture box shows. Without lookbehind (QML's
// engine doesn't run it): word boundaries are matched as a prefix group.

const L = "a-z0-9áéíóúüñ";
const B = "(^|[^" + L + "])";
const E = "(?=$|[^" + L + "])";

const MONTHS = {};
[["enero", "january", "jan", "ene"], ["febrero", "february", "feb"], ["marzo", "march", "mar"],
 ["abril", "april", "apr", "abr"], ["mayo", "may"], ["junio", "june", "jun"], ["julio", "july", "jul"],
 ["agosto", "august", "aug", "ago"], ["septiembre", "setiembre", "september", "sept", "sep"],
 ["octubre", "october", "oct"], ["noviembre", "november", "nov"], ["diciembre", "december", "dec", "dic"]]
    .forEach((names, i) => names.forEach(n => MONTHS[n] = i));
// Sunday = 0 (Date.getDay)
const WEEKDAYS = {};
[["domingo", "sunday", "dom", "sun"], ["lunes", "monday", "lun", "mon"], ["martes", "tuesday", "tue"],
 ["miércoles", "miercoles", "wednesday", "mié", "mie", "wed"], ["jueves", "thursday", "jue", "thu"],
 ["viernes", "friday", "vie", "fri"], ["sábado", "sabado", "saturday", "sáb", "sab", "sat"]]
    .forEach((names, i) => names.forEach(n => WEEKDAYS[n] = i));
const byLength = o => Object.keys(o).sort((a, b) => b.length - a.length).join("|");
const MONTH_RE = byLength(MONTHS);
const DAY_RE = byLength(WEEKDAYS);

const TASK_WORDS = "entregar|entrega|tarea|tareas|hacer|terminar|acabar|enviar|mandar|subir|estudiar|repasar|leer|pagar|comprar|llamar|revisar|preparar|imprimir|escribir|resolver|pendiente|deadline|submit|due|homework|finish|send|buy|pay|call|study|review|todo";
const EVENT_WORDS = "clase|clases|reunión|reunion|junta|cita|examen|parcial|asesoría|asesoria|conferencia|meeting|class|appointment|exam|lecture|cumpleaños|fiesta|cena|comida|desayuno|partido|concierto|vuelo";

function pad(n) { return String(n).padStart(2, "0"); }
function key(d) { return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()); }
function hm(h, m) { return pad(h) + ":" + pad(m); }
function addDays(d, n) { const x = new Date(d); x.setHours(12, 0, 0, 0); x.setDate(x.getDate() + n); return x; }
function to24(h, m, ap) {
    ap = (ap || "").replace(/[.\s]/g, "").toLowerCase();
    h = +h; m = +(m || 0);
    if (ap === "pm" && h < 12) h += 12;
    if (ap === "am" && h === 12) h = 0;
    return h <= 23 && m <= 59 ? hm(h, m) : "";
}

function parse(text, now) {
    now = now || new Date();
    let s = " " + String(text || "") + " ";
    const r = { title: "", kind: "", date: "", start: "", end: "", allDay: false, repeat: "", place: "" };
    let day = null;                 // a Date (noon) once known
    let repeatDay = null;           // "cada martes": the first one, unless a date is said
    let morning = false;

    // Find `core` (a regex source, case-insensitive) on a word boundary; run
    // `fn` with its groups (after the prefix) and take it out of the text
    function take(core, fn) {
        const re = new RegExp(B + "(" + core + ")" + E, "i");
        const m = re.exec(s);
        if (!m) return false;
        if (fn(m.slice(2), m) === false) return false;
        s = s.slice(0, m.index + m[1].length) + " " + s.slice(m.index + m[0].length);
        return true;
    }

    // Kind tags
    take("#(tarea|task|todo|pendiente)", () => { r.kind = "task"; });
    take("#(evento|event|cita)", () => { r.kind = "event"; });

    // Repeat
    take("(todos los días|todos los dias|cada día|cada dia|diario|diariamente|every ?day|daily)", () => { r.repeat = "daily"; });
    take("(entre semana|de lunes a viernes|días hábiles|dias habiles|every weekday|weekdays)", () => { r.repeat = "weekdays"; });
    take("(cada|todos los|todas las|every)\\s+(" + DAY_RE + ")s?", g => {
        r.repeat = "weekly";
        const wd = WEEKDAYS[g[2].toLowerCase()];
        repeatDay = addDays(now, (wd - now.getDay() + 7) % 7);
    });
    take("(cada semana|semanal|semanalmente|every week|weekly)", () => { r.repeat = "weekly"; });
    take("(cada mes|mensual|mensualmente|every month|monthly)", () => { r.repeat = "monthly"; });

    // Time: a range first ("de 10 a 12", "10:00-12:00", "from 10 to 12")
    const T = "(\\d{1,2})(?::(\\d{2}))?\\s*(a\\.?\\s?m\\.?|p\\.?\\s?m\\.?|am|pm)?";
    take("(?:de|from|desde)\\s+" + T + "\\s*(?:a|to|hasta|-|–)\\s*" + T, g => {
        const a = to24(g[1], g[2], g[3] || g[6]), b = to24(g[4], g[5], g[6]);
        if (!a || !b) return false;
        r.start = a; r.end = b;
    }) || take("(\\d{1,2}):(\\d{2})\\s*(a\\.?\\s?m\\.?|p\\.?\\s?m\\.?|am|pm)?\\s*(?:-|–|a|to)\\s*(\\d{1,2}):(\\d{2})\\s*(a\\.?\\s?m\\.?|p\\.?\\s?m\\.?|am|pm)?", g => {
        const a = to24(g[1], g[2], g[3] || g[6]), b = to24(g[4], g[5], g[6]);
        if (!a || !b) return false;
        r.start = a; r.end = b;
    });
    // A single time
    if (!r.start) {
        take("(?:a las|a la|at|@)?\\s*(\\d{1,2}):(\\d{2})\\s*(a\\.?\\s?m\\.?|p\\.?\\s?m\\.?|am|pm|hrs|h)?", g => {
            const t = to24(g[1], g[2], g[3]);
            if (!t) return false;
            r.start = t;
        }) || take("(?:a las|a la|at|@)?\\s*(\\d{1,2})\\s*(a\\.?\\s?m\\.?|p\\.?\\s?m\\.?|am|pm)", g => {
            const t = to24(g[1], 0, g[2]);
            if (!t) return false;
            r.start = t;
        }) || take("(?:a las|a la|at)\\s+(\\d{1,2})(?:\\s*(?:hrs|h|horas))?", g => {
            let h = +g[1];
            if (h > 23) return false;
            if (h >= 1 && h <= 7) h += 12;                   // "a las 5": in the afternoon
            r.start = hm(h, 0);
        }) || take("(mediodía|mediodia|noon)", () => { r.start = "12:00"; })
          || take("(medianoche|midnight)", () => { r.start = "23:59"; });
    }
    // "en la mañana / por la mañana / in the morning": a part of the day, not tomorrow
    take("(?:en|por|in)\\s+(?:la|the)\\s+(mañana|morning)", () => { morning = true; });
    take("(?:en|por|in)\\s+(?:la|the)\\s+(tarde|afternoon)", () => { if (!r.start) r.start = "16:00"; });
    take("(?:en|por|in)\\s+(?:la|the)\\s+(noche|evening|night)", () => { if (!r.start) r.start = "20:00"; });

    // Date
    if (!day) {
        take("(pasado mañana|pasado manana|day after tomorrow)", () => { day = addDays(now, 2); })
        || take("(?:para\\s+)?(hoy|today|tonight|esta noche)", g => { day = addDays(now, 0); if (/noche|tonight/i.test(g[1]) && !r.start) r.start = "20:00"; })
        || take("(?:para\\s+)?(mañana|manana|tomorrow)", () => { day = addDays(now, 1); })
        || take("(?:en|in|dentro de)\\s+(\\d{1,2})\\s+(días|dias|days)", g => { day = addDays(now, +g[1]); })
        || take("(la próxima semana|la proxima semana|la semana que viene|next week)", () => { day = addDays(now, ((1 - now.getDay() + 7) % 7) || 7); })
        || take("(?:el\\s+|on\\s+)?(\\d{1,2})\\s*(?:de\\s+)?(" + MONTH_RE + ")\\.?(?:\\s*(?:de|del|,)?\\s*(\\d{4}))?", g => {
            const d = new Date(g[3] ? +g[3] : now.getFullYear(), MONTHS[g[2].toLowerCase()], +g[1], 12);
            if (d.getDate() !== +g[1]) return false;
            if (!g[3] && d < addDays(now, -60)) d.setFullYear(d.getFullYear() + 1);
            day = d;
        })
        || take("(?:on\\s+)?(" + MONTH_RE + ")\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?(?:,?\\s*(\\d{4}))?", g => {
            const d = new Date(g[3] ? +g[3] : now.getFullYear(), MONTHS[g[1].toLowerCase()], +g[2], 12);
            if (d.getDate() !== +g[2]) return false;
            if (!g[3] && d < addDays(now, -60)) d.setFullYear(d.getFullYear() + 1);
            day = d;
        })
        || take("(?:el\\s+)?(\\d{1,2})/(\\d{1,2})(?:/(\\d{2,4}))?", g => {
            const y = g[3] ? (g[3].length === 2 ? 2000 + +g[3] : +g[3]) : now.getFullYear();
            const d = new Date(y, +g[2] - 1, +g[1], 12);
            if (d.getMonth() !== +g[2] - 1) return false;
            if (!g[3] && d < addDays(now, -60)) d.setFullYear(d.getFullYear() + 1);
            day = d;
        })
        || take("(?:el\\s+|este\\s+|on\\s+|this\\s+)?(próximo|proximo|next)?\\s*(" + DAY_RE + ")", g => {
            const wd = WEEKDAYS[g[2].toLowerCase()];
            let ahead = (wd - now.getDay() + 7) % 7;
            if (ahead === 0 && g[1]) ahead = 7;
            day = addDays(now, ahead);
        });
    }
    if (!day && repeatDay) day = repeatDay;
    if (morning && !r.start) r.start = "09:00";

    // Place
    take("@\\s*([^,#;]+?)\\s*(?=$|[,#;])", g => { r.place = g[1].trim(); })
    || take("(?:en|in|at)\\s+((?:el|la|the)\\s+)?((?:biblioteca|biblio|cafetería|cafeteria|auditorio|aula|salón|salon|sala|lab|laboratorio|edificio|room|library|cubículo|cubiculo)(?:\\s+[\\w-]+)?)", g => { r.place = g[2].trim(); })
    || take("(cco\\d?\\s*-?\\s*\\d{3})", g => { r.place = g[0].toUpperCase().replace(/\s+/g, " "); });

    // Kind: a tag decides; else something to do is a task, a meeting / class an event
    const lower = s.toLowerCase();
    if (!r.kind) {
        if (new RegExp(B + "(" + TASK_WORDS + ")" + E, "i").test(lower)) r.kind = "task";
        else if (new RegExp(B + "(" + EVENT_WORDS + ")" + E, "i").test(lower)) r.kind = "event";
        else r.kind = r.start ? "event" : "task";
    }
    // Only a time: today, or tomorrow when it has passed
    if (!day && r.start && r.kind === "event") {
        const [h, m] = r.start.split(":").map(Number);
        day = addDays(now, h * 60 + m <= now.getHours() * 60 + now.getMinutes() ? 1 : 0);
    }
    if (!day && r.start && r.kind === "task") day = addDays(now, 0);
    if (!day && r.repeat === "daily" || !day && r.repeat === "weekdays") day = addDays(now, 0);
    if (day) r.date = key(day);
    // A repeat whose time today has passed starts with the next one
    if (r.repeat && r.start && r.date === key(now)) {
        const [h, m] = r.start.split(":").map(Number);
        if (h * 60 + m <= now.getHours() * 60 + now.getMinutes()) r.date = nextDate(r.date, r.repeat);
    }
    if (r.kind === "event" && !r.date) r.date = key(now);
    r.allDay = r.kind === "event" && !r.start;

    // What's left is the title, without dangling words
    let title = s.replace(/\s+/g, " ").trim();
    const tail = /(\s+(el|la|los|las|de|del|a|al|para|en|on|at|by|the|to|for|por|y|and|,|-|–|·))+$/i;
    const head = /^((el|la|para|on|at|by|the|to|-|–|·|,)\s+)+/i;
    for (let i = 0; i < 3; i++) title = title.replace(tail, "").replace(head, "").trim();
    title = title.replace(/[,;:\-–·]+$/, "").trim();
    r.title = title ? title[0].toUpperCase() + title.slice(1) : "";
    return r;
}

const REPEAT_LABEL = { daily: "Every day", weekdays: "Weekdays", weekly: "Every week", monthly: "Every month" };

// The words below are English unless `tr` translates them: the panel passes
// its Tr singleton (common/Tr.qml: t(text), date(d, format)); this library
// can't see it on its own
const EN = { t: s => s, date: (d, f) => Qt.formatDate(d, f) };

// Words for a date key: "Today", "Tomorrow", "Friday", "Fri 16 Oct"
function dayWord(dateKey, now, tr) {
    tr = tr || EN;
    now = now || new Date();
    const d = new Date(dateKey + "T12:00");
    const diff = Math.round((d - addDays(now, 0)) / 86400000);
    if (diff === 0) return tr.t("Today");
    if (diff === 1) return tr.t("Tomorrow");
    if (diff === -1) return tr.t("Yesterday");
    if (diff > 1 && diff < 7) return tr.date(d, "dddd");
    return tr.date(d, "ddd d MMM");
}

// The chips the capture box shows: [{ icon, text }]
function describe(r, now, tr) {
    tr = tr || EN;
    const out = [];
    out.push(r.kind === "event" ? { icon: "", text: tr.t("Event") } : { icon: "", text: tr.t("Task") });
    if (r.date) out.push({ icon: "", text: dayWord(r.date, now, tr) });
    else if (r.kind === "task") out.push({ icon: "", text: tr.t("No date") });
    if (r.start) out.push({ icon: "", text: r.start + (r.end ? " – " + r.end : "") });
    else if (r.allDay) out.push({ icon: "", text: tr.t("All day") });
    if (r.repeat) out.push({ icon: "", text: tr.t(REPEAT_LABEL[r.repeat]) });
    if (r.place) out.push({ icon: "\u{f034e}", text: r.place });
    return out;
}

// The next date of a repeating to-do after `dateKey` (YYYY-MM-DD)
function nextDate(dateKey, repeat) {
    const d = new Date((dateKey || key(new Date())) + "T12:00");
    if (repeat === "daily") d.setDate(d.getDate() + 1);
    else if (repeat === "weekdays") { do d.setDate(d.getDate() + 1); while (d.getDay() === 0 || d.getDay() === 6); }
    else if (repeat === "weekly") d.setDate(d.getDate() + 7);
    else if (repeat === "monthly") {
        const want = d.getDate();
        d.setDate(1);
        d.setMonth(d.getMonth() + 1);
        d.setDate(Math.min(want, new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()));
    }
    return key(d);
}
