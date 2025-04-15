// Test script for plotting functions (visual check)

clear;
mode(0);

// Load all SciLoopShaper functions
exec(fullfile(get_absolute_file_path('test_plotting_functions.sce'), '../../main.sce'), -1);

// Define a simple plant and controller
s = poly(0, 's');
plant = syslin('c', 1/(s*(s+1))); // Plant with integrator and pole
controller = syslin('c', 10);     // Simple gain controller
open_loop = plant * controller;

// Define frequency range
w_min = 0.01;
w_max = 100;
n_points = 500;

// --- Test plot_bode ---
disp("--> Testing plot_bode (visual check):");
try
    figure('figure_name', 'Bode Plot Test');
    plot_bode(open_loop, w_min, w_max, n_points, '-', 'b');
    title('Bode Plot of 10 / (s*(s+1))');
    disp("Check 'Bode Plot Test' figure: -20dB/dec at low freq, -40dB/dec at high freq, phase starts -90 deg, ends -180 deg.");
catch
    disp("Error plotting Bode:");
    disp(lasterror());
end

// --- Test plot_nyquist ---
disp(" ");
disp("--> Testing plot_nyquist (visual check):");
try
    figure('figure_name', 'Nyquist Plot Test');
    plot_nyquist(open_loop, w_min, w_max, n_points, '-', 'r');
    title('Nyquist Plot of 10 / (s*(s+1))');
    disp("Check 'Nyquist Plot Test' figure: Should start along neg imaginary axis, curve around, not encircle -1.");
catch
    disp("Error plotting Nyquist:");
    disp(lasterror());
end

// --- Test plot_nichols ---
disp(" ");
disp("--> Testing plot_nichols (visual check):");
try
    figure('figure_name', 'Nichols Plot Test');
    plot_nichols(open_loop, w_min, w_max, n_points, '-', 'g');
    title('Nichols Plot of 10 / (s*(s+1))');
     disp("Check 'Nichols Plot Test' figure: Compare shape to known Nichols charts.");
catch
    disp("Error plotting Nichols:");
    disp(lasterror());
end

disp(" ");
disp("Plotting function tests complete (require visual inspection).");
