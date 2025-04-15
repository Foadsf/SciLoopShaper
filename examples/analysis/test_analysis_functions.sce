// Test script for analysis functions (FIXED SYSLIN CALLS)

clear;
mode(0);

// Load all SciLoopShaper functions
exec(fullfile(get_absolute_file_path('test_analysis_functions.sce'), '../../main.sce'), -1);

s = poly(0, 's'); // Define Laplace variable

// --- Test analyze_stability ---
disp("--> Testing analyze_stability:");

// Stable system: P = 1/(s+1), C = 10
plant_stable = syslin('c', 1/(s+1));
// Fix: Use explicit num/den for constant gain
controller_stable = syslin('c', 10, 1); // Changed from syslin('c', 10)
disp("Testing stable system P=1/(s+1), C=10");
try
    results_stable = analyze_stability(plant_stable, controller_stable);
    disp(results_stable); // Expect stable=True, positive margins
catch
    disp(lasterror());
end

// Marginally stable system: P = 1/s^2, C = 1
plant_marg = syslin('c', 1/s^2);
// Fix: Use explicit num/den for constant gain
controller_marg = syslin('c', 1, 1); // Changed from syslin('c', 1)
disp("Testing marginally stable system P=1/s^2, C=1");
try
    results_marg = analyze_stability(plant_marg, controller_marg);
    disp(results_marg); // Expect GM=Inf, PM=0
catch
    disp(lasterror());
end

// Unstable system: P = 1/(s-1), C = 1
plant_unstable = syslin('c', 1/(s-1));
// Fix: Use explicit num/den for constant gain
controller_unstable = syslin('c', 1, 1); // Changed from syslin('c', 1)
disp("Testing unstable system P=1/(s-1), C=1");
try
    results_unstable = analyze_stability(plant_unstable, controller_unstable);
    disp(results_unstable); // Expect stable=False, check margins
catch
    disp(lasterror());
end


// --- Test calculate_time_response ---
disp(" ");
disp("--> Testing calculate_time_response (visual check):");
try
    // Use the stable plant P=1/(s+1), C=10/1
    t_final = 5;
    n_points = 501;
    time_vector = linspace(0, t_final, n_points);

    // Step Response
    resp_step = calculate_time_response(plant_stable, controller_stable, "step", time_vector);
    figure('figure_name', 'Time Response Test');
    plot(time_vector, resp_step);
    title('Step Response of 10/(s+11)');
    xlabel('Time [s]'); ylabel('Output');
    a=gca(); a.grid=[1 1]; // Add grid explicitly

    // Fix: Corrected string escaping
    disp("Check the ''Time Response Test'' figure for correctness (should approach 10/11).");

catch
    disp("Error calculating time response:");
    disp(lasterror());
end

disp(" ");
disp("Analysis function tests complete.");
