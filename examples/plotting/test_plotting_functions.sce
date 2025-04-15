// Test script for plotting functions (visual check) - FIXED SYSLIN

clear;
mode(0);

// Load all SciLoopShaper functions
exec(fullfile(get_absolute_file_path('test_plotting_functions.sce'), '../../main.sce'), -1);

// Define a simple plant and controller
s = poly(0, 's');
plant = syslin('c', 1/(s*(s+1))); // Plant TF is okay (rational)
// Fix: Use explicit num/den for constant gain controller
controller = syslin('c', 10, 1); // Changed from syslin('c', 10)
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
    // Titles/labels are now set inside plot_bode
    disp("Check ''Bode Plot Test'' figure.");
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
     // Titles/labels are now set inside plot_nyquist
    disp("Check ''Nyquist Plot Test'' figure.");
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
     // Titles/labels are now set inside plot_nichols
     disp("Check ''Nichols Plot Test'' figure.");
catch
    disp("Error plotting Nichols:");
    disp(lasterror());
end

disp(" ");
disp("Plotting function tests complete (require visual inspection).");
// Optional: Add pause here if running interactively and plots close too fast
// pause;
