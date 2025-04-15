// Test script for plant-related functions

clear; // Clear workspace variables
mode(0); // Display commands executed from script

// Load all SciLoopShaper functions
exec(fullfile(get_absolute_file_path('test_plant_functions.sce'), '../../main.sce'), -1);


// --- Test create_example_plant ---
disp("--> Testing create_example_plant:");
try
    plant_mass = create_example_plant('mass');
    disp("Mass Plant TF:");
    //tf_mass = systf(plant_mass); // Remove or change
    disp(plant_mass); // Display directly

    plant_2m_c = create_example_plant('2 mass collocated');
    disp("2 Mass Collocated Plant TF:");
    //tf_2m_c = systf(plant_2m_c); // Remove or change
    disp(plant_2m_c); // Display directly

    plant_2m_nc = create_example_plant('2 mass non-collocated');
    disp("2 Mass Non-Collocated Plant TF:");
    //tf_2m_nc = systf(plant_2m_nc); // Remove or change
    disp(plant_2m_nc); // Display directly

catch
    disp("Error creating example plant:");
    disp(lasterror());
end

// --- Test load_plant_from_workspace ---
disp(" ");
disp("--> Testing load_plant_from_workspace:");
s = poly(0,'s');
mySimplePlant = syslin('c', 1/(s+1)); // Create a plant in workspace
workspacePlantName = 'mySimplePlant';
try
    loaded_plant = load_plant_from_workspace(workspacePlantName);
    disp("Loaded Plant from Workspace TF:");
    //tf_loaded = systf(loaded_plant); // Remove or change
    disp(loaded_plant); // Display directly

    // Test error case (variable doesn't exist)
    disp("Testing non-existent variable (expect error):");
    load_plant_from_workspace('nonExistentVar');

catch
    disp("Caught expected error:");
    disp(lasterror());
end


// --- Test calculate_frequency_response ---
disp(" ");
disp("--> Testing calculate_frequency_response (visual check):");
try
    // Use a simple integrator: 1/s
    s = poly(0,'s'); // Make sure s is defined
    integrator_plant = syslin('c', 1/s);
    w_min = 0.1;
    w_max = 100;
    n_points = 500;

    [mag, phase, w] = calculate_frequency_response(integrator_plant, w_min, w_max, n_points);

    // --- Debug: Inspect returned data ---
    disp("Data returned from calculate_frequency_response:");
    disp("Size of w:    " + string(size(w)));
    disp("Size of mag:  " + string(size(mag)));
    disp("Size of phase:" + string(size(phase)));
    if ~isempty(w) then disp("First few w values: " + string(w(1:min(5, length(w))))); end
    if ~isempty(mag) then disp("First few mag values: " + string(mag(1:min(5, length(mag))))); end
    if ~isempty(phase) then disp("First few phase values: " + string(phase(1:min(5, length(phase))))); end
    disp("Checking for NaN/Inf in results:");
    disp("NaNs in w: " + string(sum(isnan(w))));
    disp("Infs in w: " + string(sum(isinf(w))));
    disp("NaNs in mag: " + string(sum(isnan(mag))));
    disp("Infs in mag: " + string(sum(isinf(mag))));
    disp("NaNs in phase: " + string(sum(isnan(phase))));
    disp("Infs in phase: " + string(sum(isinf(phase))));
    // --- End Debug ---

    // Check if results are valid before plotting
    if isempty(mag) | isempty(phase) | isempty(w) then
        error("Frequency response calculation returned empty arrays.");
    end
    // No need for isreal check here, as we expect complex rep internally
    // if ~isreal(mag) | ~isreal(phase) | ~isreal(w) then
    //     error("Frequency response calculation returned non-real data.");
    // end

    // Plot for visual verification
    figure('figure_name', 'Integrator Bode Test');

    // Magnitude plot
    disp("--> Plotting Magnitude..."); // Debug marker
    subplot(2,1,1);
    loglog(w, mag); // Plot first
    // grid();         // Call grid from the main plot function now
    title('Magnitude (Should be -20dB/dec slope)');
    ylabel('Magnitude');

    // Phase plot
    disp("--> Plotting Phase..."); // Debug marker
    subplot(2,1,2);
    semilogx(w, phase); // Plot first
    // grid();           // Call grid from the main plot function now
    title('Phase (Should be -90 deg)');
    ylabel('Phase [deg]'); xlabel('Frequency [Hz]');

    disp("Check the ''Integrator Bode Test'' figure for correctness.");

catch
    disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"); // Make error standout
    disp("Error during frequency response test/plot:");
    // Use lasterror(%t) to get the stack trace if available
    lasterror(%t);
    disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
end

disp(" ");
disp("Plant function tests complete.");
