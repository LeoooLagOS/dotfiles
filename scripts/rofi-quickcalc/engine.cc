// quickcalc engine: libqalculate evaluation for the quickcalc rofi mode
// (mode.c). Kept apart because libqalculate's and rofi's headers both define
// PropertyType. See mode.c for what the mode does.
#include <libqalculate/qalculate.h>

#include <algorithm>
#include <atomic>
#include <cctype>
#include <set>
#include <string>
#include <thread>

#include "engine.h"

namespace {

struct State {
    std::thread loader;
    std::atomic<bool> ready{false};
    std::string input;         // last input we evaluated
    std::string expression;    // what was evaluated (input without a leading "=")
    std::string result;        // printed result, "" = no result row
    bool plottable = false;    // has x and no other unknowns
};

State *g_state = nullptr;

void loadCalculator(State *st) {
    new Calculator();
    CALCULATOR->loadGlobalDefinitions();
    CALCULATOR->loadLocalDefinitions();
    CALCULATOR->loadExchangeRates();
    st->ready = true;
}

// Words that may appear in an expression besides functions, variables and units
const std::set<std::string> kKeywords = {"to", "in", "of", "x", "mod", "rem", "and", "or", "not", "xor",
                                         "deg", "rad", "gra", "bin", "hex", "oct", "dec", "base"};

bool isWordChar(unsigned char c) { return std::isalpha(c) || c == '_' || c >= 0x80; }

// Every identifier must be something qalculate knows (exact name)
bool wordsAreKnown(const std::string &s) {
    size_t i = 0;
    while (i < s.size()) {
        if (!isWordChar(s[i])) { i++; continue; }
        size_t j = i;
        while (j < s.size() && (isWordChar(s[j]) || std::isdigit((unsigned char)s[j]))) j++;
        const std::string w = s.substr(i, j - i);
        std::string lower = w;
        for (auto &c : lower) c = std::tolower((unsigned char)c);
        const bool known = kKeywords.count(lower) || CALCULATOR->getActiveFunction(w) ||
                           CALCULATOR->getActiveVariable(w) || CALCULATOR->getActiveUnit(w) ||
                           CALCULATOR->getActiveUnit(lower);
        if (!known) return false;
        i = j;
    }
    return true;
}

bool hasX(const std::string &s) {
    for (size_t i = 0; i < s.size(); i++) {
        if (s[i] != 'x') continue;
        const bool before = i > 0 && (std::isalpha((unsigned char)s[i - 1]) || s[i - 1] == '_');
        const bool after = i + 1 < s.size() && (std::isalpha((unsigned char)s[i + 1]) || s[i + 1] == '_');
        if (!before && !after) return true;
    }
    return false;
}

void update(State *st, const char *raw) {
    const std::string input = raw ? raw : "";
    if (input == st->input) return;
    st->input = input;
    st->result.clear();
    st->plottable = false;

    std::string expr = input;
    while (!expr.empty() && std::isspace((unsigned char)expr.front())) expr.erase(0, 1);
    while (!expr.empty() && std::isspace((unsigned char)expr.back())) expr.pop_back();
    const bool forced = !expr.empty() && expr[0] == '=';
    if (forced) expr.erase(0, 1);
    if (expr.empty()) return;
    bool digit = false;
    for (unsigned char c : expr) digit |= std::isdigit(c) != 0;
    if (!forced && !digit && !hasX(expr)) return;

    if (!st->ready) {
        if (st->loader.joinable()) st->loader.join();
        else return;
    }
    if (!forced && !wordsAreKnown(expr)) return;
    st->expression = expr;

    EvaluationOptions eo;
    eo.parse_options.unknowns_enabled = true;
    eo.mixed_units_conversion = MIXED_UNITS_CONVERSION_NONE;
    MathStructure m;
    if (!CALCULATOR->calculate(&m, CALCULATOR->unlocalizeExpression(expr, eo.parse_options), 250, eo)) return;
    if (CALCULATOR->message()) {          // parse/eval errors → no row
        bool error = false;
        do { error |= CALCULATOR->message()->type() == MESSAGE_ERROR; } while (CALCULATOR->nextMessage());
        if (error) return;
    }

    if (m.containsUnknowns()) {
        st->plottable = hasX(expr);
        return;
    }
    PrintOptions po;
    po.use_unicode_signs = true;
    po.number_fraction_format = FRACTION_DECIMAL;
    po.indicate_infinite_series = true;
    po.spacious = true;
    const std::string out = CALCULATOR->print(m, 250, po);
    // A bare number that equals the input ("2048") is not worth a row
    std::string plain = expr;
    plain.erase(std::remove(plain.begin(), plain.end(), ' '), plain.end());
    std::string outPlain = out;
    outPlain.erase(std::remove(outPlain.begin(), outPlain.end(), ' '), outPlain.end());
    if (outPlain == plain) return;
    st->result = out;
}

}  // namespace

extern "C" {
void qc_start(void) {
    if (g_state) return;
    g_state = new State();
    g_state->loader = std::thread(loadCalculator, g_state);
}
void qc_stop(void) {
    if (!g_state) return;
    if (g_state->loader.joinable()) g_state->loader.join();
    delete g_state;
    g_state = nullptr;
}
void qc_update(const char *input) { if (g_state) update(g_state, input); }
const char *qc_result(void) { return g_state ? g_state->result.c_str() : ""; }
const char *qc_expression(void) { return g_state ? g_state->expression.c_str() : ""; }
int qc_plottable(void) { return g_state && g_state->plottable; }
}
