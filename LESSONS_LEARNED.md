# Lessons Learned: Scilab vs. MATLAB for Control System GUI Development

This document records specific challenges, differences, and solutions encountered while developing SciLoopShaper, particularly for developers familiar with MATLAB. These observations are based on **Scilab 2024.0.0**.

## Introduction

Migrating development practices or replicating tools from MATLAB to Scilab involves navigating differences in syntax, function behavior, and environment setup. This log aims to capture key hurdles faced during the initial stages of the SciLoopShaper project.

## Environment and Setup

1.  **Path Management (`addpath`)**
    *   **Problem:** Tried using `addpath` (MATLAB style) to make functions in subdirectories available.
    *   **Scilab Approach:** Scilab doesn't use a persistent search path like MATLAB's `addpath`. Functions defined in `.sci` or `.sce` files must be loaded into the session using `exec('path/to/file.sce')`.
    *   **Solution:** The `main.sce` script explicitly uses `exec()` to load all `.sce` files containing function definitions from the `src/` subdirectories.

2.  **Function Loading Scope (`exec`)**
    *   **Problem:** Functions defined in files loaded via `exec()` inside a main script were sometimes not found when called later (either from the console after the main script finished, or from within GUI callbacks). MWEs often worked, but the full application failed.
    *   **Diagnosis:** This indicated that errors (sometimes silent) during the execution of *any* file loaded by `exec` could prevent subsequent function definitions from being registered correctly, or that the dynamic file finding logic itself was flawed.
    *   **Solution:** Simplified `main.sce` to manually list essential files in dependency order and execute them verbosely (`exec(..., 0)`) during debugging to ensure each file loads cleanly. Ensured the main GUI function was defined *last*. Once the loading was confirmed clean, the functions became available as expected.

## Core Syntax Differences

1.  **String Escaping**
    *   **Problem:** Errors like `Heterogeneous string detected...` occurred when using single quotes (`'`) inside double-quoted strings (`"`).
    *   **Scilab Solution:** To include a literal single quote within a double-quoted string, double it (`''`). Example: `disp("Variable ''myVar'' not found.");`

2.  **Function Call Syntax (`figure`)**
    *   **Problem:** Attempted to create a figure and set multiple properties using `'PropertyName', PropertyValue` pairs within the `figure(...)` call (MATLAB style).
    *   **Scilab Approach:** The `figure()` function typically takes fewer arguments. Properties are set afterwards using the returned graphics handle.
    *   **Solution:** Create the figure first (`fig = figure();`), then set properties (`fig.figure_name = 'My Figure'; fig.figure_size = [w h];`).

3.  **List/Vector Definitions**
    *   **Problem:** Defining lists/vectors across multiple lines using `..` continuation seemed unstable, especially for lists of structures or string arrays, leading to `length()` issues or `%st_c_st` errors later.
    *   **Scilab Solution:**
        *   For lists: Initialize with `myList = list();` and append using `myList($+1) = ...;`.
        *   For column vectors of strings: Use standard matrix notation with semicolons: `myVec = ["String1"; "String2"; ...]`.

4.  **Checking Variable Existence (`exists`)**
    *   **Problem:** Used `exists('varname', 'type')` or `exists('varname', 'g')` incorrectly.
    *   **Scilab Solution:** `exists('varname')` checks for existence in the current scope. To check for global variables, use `isdef('varname', 'global')` or `try...catch` with `getglobal('varname')`. `exists` does not accept a type string as the second argument.

## Core Function Behavior Differences

1.  **Displaying Transfer Functions (`systf`)**
    *   **Problem:** Used non-existent `systf()`.
    *   **Scilab Solution:** Use `disp(my_syslin_object);`.

2.  **Checking Numeric Type (`isnumeric`)**
    *   **Problem:** Used non-existent `isnumeric()`.
    *   **Scilab Solution:** Use `type(var) == 1`.

3.  **Checking All Elements (`all`)**
    *   **Problem:** Used non-existent `all()`.
    *   **Scilab Solution:** Use `and(boolean_vector)`.

4.  **Not-a-Number Constant (`nan`)**
    *   **Problem:** Used `nan`.
    *   **Scilab Solution:** Use `%nan`.

5.  **`length()` Function on String Arrays**
    *   **Problem:** In Scilab 2024.0.0, `length(string_column_vector)` returned a *vector* of character lengths, not the scalar element count.
    *   **Scilab Solution:** Use `size(string_vector, "*")` or `size(string_vector, 1)` to get the element count.

6.  **`syslin()` Constructor for Constants**
    *   **Problem:** In Scilab 2024.0.0, `syslin('c', gain_constant)` failed.
    *   **Scilab 2024.0.0 Solution:** Must provide explicit numerator/denominator or rational polynomial. Use `syslin('c', gain_constant, 1)`.

7.  **`dscr()` Discretization Methods**
    *   **Problem:** In Scilab 2024.0.0, specifying methods using strings (e.g., `'tustin'`) failed with "Undefined operation" errors (`%s_c_c`).
    *   **Scilab 2024.0.0 Solution:** Use the corresponding **numeric method codes**. For Tustin, use `dscr(sys, Ts, 2)`. This appears to be a bug/regression. Note: `dscr` returns state-space; use `ss2tf()` if TF is needed.

8.  **Margin Functions (`p_margin`, `g_margin`)**
    *   **Problem:** Assumed `p_margin` returned multiple values like MATLAB.
    *   **Scilab Behavior:** `p_margin(sys)` returns *only* the phase margin (deg). `g_margin(sys)` returns *only* the gain margin (linear).
    *   **Solution:** Call both functions separately to get both margins. Handle empty/Inf results appropriately.

## GUI Development Quirks (Scilab 2024.0.0)

1.  **Grid Display (`grid()`, `a.grid`)**
    *   **Problem:** Calling `xgrid()` or setting `axes_handle.grid = [color("gray") color("gray")]` or `axes_handle.grid = [1 1]` did not reliably render grid lines on axes embedded within GUI frames, although it worked in standalone figures or direct console calls.
    *   **Status:** **Unresolved.** Needs further investigation, possibly related to graphics drivers, renderers, or specific interactions with layout managers.

2.  **`createConstraints` Arguments (`gridbag`)**
    *   **Problem:** Confusion between `padding` (6th arg, expects `[ix, iy]`) and `margins` (7th arg, expects `[t, l, b, r]`). Providing 4 values for `padding` caused errors. Later, providing valid `margins` also seemed to cause errors initially. Invalid `anchor` values ("east"/"west") also caused errors.
    *   **Solution:** Correctly provide `padding=[0 0]` and `margins=[t l b r]` (if needed, removing margins worked). Use valid Scilab `anchor` keywords ("right", "left", "center", etc.).

3.  **Built-in Function Scope in Callbacks (`ishandle`)**
    *   **Problem:** Standard function `ishandle` was "Undefined variable" when called from within a GUI callback function defined in a separate file.
    *   **Diagnosis:** Likely a bug/limitation in the callback execution scope in Scilab 2024.0.0.
    *   **Workaround:** Use `typeof(handle_var) == "handle"` as a less strict but functional check for handle validity within callbacks.

4.  **Graphics Handle Scope in Callbacks (`app.handles` vs. `global gh...`)**
    *   **Problem:** Storing axes handles within a nested global structure (`app.handles`) led to the structure (or just the handles field) being inaccessible/undefined within callbacks.
    *   **Workaround:** Store critical graphics handles needed by multiple callbacks in *separate, top-level* global variables (e.g., `global ghAxMag;`). Access these directly in callbacks. Keep non-handle state data in the main `global app` struct.

5.  **Plotting/Title Updates (`plot2d`, `semilogx`, `xtitle`)**
    *   **Problem:** Using `plot2d` with `style=...` and `axesflag=5` (semilogx) failed. Also, calling `xtitle(handle, ...)` immediately after plotting (`semilogx`) or clearing (`delete(handle.children)`) on the same axes handle failed with "Wrong type for argument #1".
    *   **Solution:**
        *   Use the dedicated `semilogx(x, y, style)` function instead of `plot2d` for Bode plots.
        *   Use object-oriented property access `handle.title.text = "My Title"` instead of `xtitle(handle, "My Title")`. This seems more robust after graphics operations.
        *   Use `delete(handle.children)` to clear axes content. Add `if ~isempty(handle.children)` check before deleting.
        *   Use `drawnow()` after plotting or changing titles/properties within callbacks to force the GUI to refresh visually.

## General Advice

*   **Assume Differences:** Don't assume MATLAB functions or syntax work directly in Scilab.
*   **Use `help`:** Scilab's built-in `help function_name` is essential, but verify behavior, especially for GUI and newer/changed functions.
*   **Test Incrementally & Isolate:** When debugging, simplify code drastically (MWEs) to isolate the exact point of failure. Test GUI interactions step-by-step.
*   **Be Aware of Version Changes:** Function behavior can change significantly between Scilab versions. Note the specific version (2024.0.0 here).
*   **Scope Matters:** Pay close attention to variable and function scope, especially between the main environment, loaded scripts (`exec`), and GUI callbacks. Global variables are accessible if declared, but function visibility and built-in access might be inconsistent in callbacks.
