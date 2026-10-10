// C API of the quickcalc engine (engine.cc), used by the rofi mode (mode.c)
#pragma once
#ifdef __cplusplus
extern "C" {
#endif
void qc_start(void);                 // load the Calculator in a background thread
void qc_stop(void);
void qc_update(const char *input);   // evaluate if the input changed
const char *qc_result(void);         // "" = no result row
const char *qc_expression(void);     // the evaluated expression
int qc_plottable(void);              // has x (and no other unknowns)
#ifdef __cplusplus
}
#endif
