# Lessons Learned: Scilab vs. MATLAB for Control System GUI Development

This document records specific challenges, differences, and solutions encountered while developing SciLoopShaper, particularly for developers familiar with MATLAB. These observations are based on **Scilab 2024.0.0**.

## Introduction

Migrating development practices or replicating tools from MATLAB to Scilab involves navigating differences in syntax, function behavior, and environment setup. This log aims to capture key hurdles faced during the initial stages of the SciLoopShaper project.

## Environment and Setup

1.  **Path Management (`addpath`)**
    *   **Problem:** Tried using `addpath` (MATLAB style) to make functions in subdirectories available.
    *   **Scilab Approach:** Scilab doesn't use a persistent search path like MATLAB's `addpath`. Functions defined in `.sci` or `.sce` files must be loaded into the session using `exec('path/to/file.sce')`.
    *   **Solution:** The `main.sce` script explicitly uses `exec()` to load all `.sce` files containing function definitions from the `src/` subdirectories.

## Core Syntax Differences

1.  **String Escaping**
    *   **Problem:** Errors like `Heterogeneous string detected...` occurred when using single quotes (`'`) inside double-quoted strings (`"`).
    *   **MATLAB:** Often tolerant of mixing quote types or uses `"` for strings.
    *   **Scilab Solution:** To include a literal single quote within a double-quoted string, double it (`''`). Example: `disp("Variable ''myVar'' not found.");`

2.  **Function Call Syntax (`figure`)**
    *   **Problem:** Attempted to create a figure and set multiple properties using `'PropertyName', PropertyValue` pairs within the `figure(...)` call (MATLAB style).
    *   **Scilab Approach:** The `figure()` function typically takes fewer arguments (like the figure number). Properties are set afterwards using the returned graphics handle.
    *   **Solution:** Create the figure first (`fig = figure();`), then set properties (`fig.figure_name = 'My Figure'; fig.figure_position = [x, y, w, h];`). Note that not all MATLAB figure properties have direct Scilab equivalents or may be properties of axes instead.

3.  **List/Vector Definitions**
    *   **Problem:** Defining lists or vectors across multiple lines using `..` continuation, especially lists of structures (`paramsList = [struct(...), .. struct(...)]`), seemed unstable or led to later errors (`%st_c_st: Field names mismatch` when accessing elements in a loop). Defining string arrays with `..` caused `length()` to behave unexpectedly.
    *   **Scilab Solution:**
        *   For lists of structures: Initialize with `myList = list();` and append using `myList($+1) = struct(...);`.
        *   For column vectors of strings: Use standard matrix notation with semicolons: `myVec = ["String1"; "String2"; ...]`.

## Core Function Behavior Differences

1.  **Displaying Transfer Functions (`systf`)**
    *   **Problem:** Used `systf()` (a common user-defined function in MATLAB control toolboxes) expecting it to display a transfer function.
    *   **Scilab Solution:** Scilab's built-in `disp()` function correctly displays `syslin` objects in a readable rational polynomial format. Use `disp(my_syslin_object);`.

2.  **Checking Numeric Type (`isnumeric`)**
    *   **Problem:** Used `isnumeric()` (MATLAB function) to check if a variable was numeric.
    *   **Scilab Solution:** Use the `type()` function, which returns an integer code. For standard numeric matrices (real or complex), `type(var) == 1`. Combine with `size(var, "*") == 1` to check for scalars if needed.

3.  **`length()` Function on String Arrays**
    *   **Problem:** In Scilab 2024.0.0, `length(string_column_vector)` unexpectedly returned a *vector* containing the character length of *each string element*, not the scalar number of elements (rows). This caused errors in loop definitions (`for i = 1:length(...)`).
    *   **MATLAB:** `length` on a non-empty vector generally returns the number of elements along the largest dimension.
    *   **Scilab Solution:** Use `size(string_vector, "*")` or `size(string_vector, 1)` (for column vectors) to reliably get the number of string elements.

4.  **`syslin()` Constructor for Constants**
    *   **Problem:** In Scilab 2024.0.0, creating a constant gain transfer function using `syslin('c', gain_constant)` failed with `Wrong type for input argument #2`.
    *   **Previous Scilab/MATLAB:** Often allowed creating constant gains this way.
    *   **Scilab 2024.0.0 Solution:** Must provide explicit numerator and denominator, or a rational polynomial. Use `syslin('c', gain_constant, 1)` or `syslin('c', poly(gain_constant,'s','c') / poly(1,'s','c'))`.

5.  **`dscr()` Discretization Methods**
    *   **Problem:** In Scilab 2024.0.0, specifying discretization methods using strings (e.g., `dscr(sys, Ts, 'tustin')` or `'zoh'`) failed with `%s_c_c` or similar "Undefined operation" errors.
    *   **Scilab Documentation/Previous Versions:** Suggested string arguments were valid.
    *   **Scilab 2024.0.0 Solution:** Use the corresponding **numeric method codes**. For Tustin (bilinear), use `dscr(sys, Ts, 2)`. (ZOH likely uses code 0, needs verification). This appears to be a bug or regression in string argument handling for `dscr`. Note: `dscr` returns state-space by default; use `ss2tf()` if TF is needed.

## Graphics Quirks

1.  **Grid Display (`grid()`)**
    *   **Problem:** Simply calling `grid()` after plotting commands (`plot`, `semilogx`) sometimes didn't display the grid lines.
    *   **Scilab Solution (Partial/Needs Monitoring):** Explicitly get the axes handle (`a = gca();`) and set the grid property (`a.grid = [1 1];`). Placing this *after* all other plotting commands (labels, titles) for the axes seemed necessary in tests, but reliability might depend on the graphics backend and specific plot types. This needs further investigation during GUI development.

## General Advice

*   **Assume Differences:** Don't assume MATLAB functions or syntax work directly in Scilab.
*   **Use `help`:** Scilab's built-in `help function_name` is essential.
*   **Test Incrementally:** When debugging, simplify code drastically (like the minimal tests we performed) to isolate the exact point of failure.
*   **Be Aware of Version Changes:** Function behavior (like `length`, `syslin`, `dscr`) can change between Scilab versions. Note the version being used.
