// quickcalc — rofi mode that shows a live calculator result as a row, meant to
// be combined with drun (`-combi-modi quickcalc,drun`), so the app launcher
// (SUPER D) answers "2+2*3", "15% * 80", "10 km to mi" or "100 USD to MXN"
// while you type, without switching to the Calc tab.
//
// Rows (hidden unless they apply):
//   0  = result            Enter copies it (wl-copy)
//   1  Plot y = f(x)       when the expression has x; Enter opens the graph
//                          (scripts/wm/CalcPlot.sh, Lagos colors)
//
// The math is in engine.cc (libqalculate in-process; the Calculator loads in a
// background thread when rofi starts, so typing never waits for qalc). Only
// input with a digit (or x, or a leading "=") is evaluated, and every word in
// it must be a known function, variable, unit or keyword — app names like
// "IntelliJ 2026" are never treated as math.
//
// rofi's combi mode does not pass the raw input to its modes, so the text is
// read from the view (rofi_view_get_user_input, exported by rofi).

#include <gmodule.h>
#include <rofi/helper.h>
#include <rofi/mode-private.h>
#include <rofi/mode.h>
#include <rofi/rofi-icon-fetcher.h>

#include "engine.h"

typedef struct RofiViewState RofiViewState;
RofiViewState *rofi_view_get_active(void);
const char *rofi_view_get_user_input(const RofiViewState *state);

#define QC_MARKUP 8   // rofi's MARKUP text state (textbox.h, not installed)

static uint32_t calc_icon = 0, plot_icon = 0;

static void refresh(void) {
  RofiViewState *view = rofi_view_get_active();
  qc_update(view ? rofi_view_get_user_input(view) : "");
}

static int qc_init(Mode *sw) {
  (void)sw;
  qc_start();
  return TRUE;
}

static void qc_destroy(Mode *sw) {
  (void)sw;
  qc_stop();
}

// Fixed count: combi reads it once; rows are shown or hidden by token_match
static unsigned int qc_num_entries(const Mode *sw) {
  (void)sw;
  return 2;
}

static int qc_token_match(const Mode *sw, rofi_int_matcher **tokens, unsigned int index) {
  (void)sw;
  (void)tokens;
  refresh();
  return index == 0 ? qc_result()[0] != '\0' : qc_plottable();
}

static char *qc_display(const Mode *sw, unsigned int line, int *state, GList **attrs, int get_entry) {
  (void)sw;
  (void)attrs;
  *state |= QC_MARKUP;
  if (!get_entry) return NULL;
  // Short: the launcher shows two columns, and the expression is already in
  // the search box
  if (line == 0) {
    gchar *res = g_markup_escape_text(qc_result(), -1);
    gchar *out = g_strdup_printf("<b>= %s</b>   <span alpha='55%%'>↵ copy</span>", res);
    g_free(res);
    return out;
  }
  gchar *expr = g_markup_escape_text(qc_expression(), -1);
  gchar *out = g_strdup_printf("<b>Plot</b>  y = %s   <span alpha='55%%'>↵ graph</span>", expr);
  g_free(expr);
  return out;
}

static cairo_surface_t *qc_icon(const Mode *sw, unsigned int line, unsigned int height) {
  (void)sw;
  uint32_t *uid = line == 0 ? &calc_icon : &plot_icon;
  if (*uid == 0) *uid = rofi_icon_fetcher_query(line == 0 ? "accessories-calculator" : "x-office-spreadsheet", height);
  return rofi_icon_fetcher_get(*uid);
}

static ModeMode qc_result_cb(Mode *sw, int retv, char **input, unsigned int line) {
  (void)sw;
  (void)input;
  if (retv & MENU_NEXT) return NEXT_DIALOG;
  if (retv & MENU_PREVIOUS) return PREVIOUS_DIALOG;
  if (retv & MENU_QUICK_SWITCH) return (ModeMode)(retv & MENU_LOWER_MASK);
  if (!(retv & MENU_OK)) return MODE_EXIT;
  GError *error = NULL;
  if (line == 0) {
    const char *argv[] = {"wl-copy", "--", qc_result(), NULL};
    g_spawn_async(NULL, (gchar **)argv, NULL, G_SPAWN_SEARCH_PATH, NULL, NULL, NULL, &error);
  } else {
    gchar *script = g_build_filename(g_get_home_dir(), ".config/hypr/scripts/CalcPlot.sh", NULL);
    const char *argv[] = {script, qc_expression(), NULL};
    g_spawn_async(NULL, (gchar **)argv, NULL, G_SPAWN_DEFAULT, NULL, NULL, NULL, &error);
    g_free(script);
  }
  if (error) g_error_free(error);
  return MODE_EXIT;
}

G_MODULE_EXPORT Mode mode = {
    .abi_version = ABI_VERSION,
    .name = "quickcalc",
    .cfg_name_key = "display-quickcalc",
    ._init = qc_init,
    ._destroy = qc_destroy,
    ._get_num_entries = qc_num_entries,
    ._result = qc_result_cb,
    ._token_match = qc_token_match,
    ._get_display_value = qc_display,
    ._get_icon = qc_icon,
    .type = MODE_TYPE_SWITCHER,
};
