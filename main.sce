// File: main.sce (SIMPLIFIED DEBUG VERSION)

clear; // Start fresh
mode(0); // Verbose mode

disp("SIMPLIFIED main.sce: Starting execution...");

currentPath = get_absolute_file_path('main.sce');
errored = %F;

// --- Define files to load MANUALLY and in ORDER ---
// List core dependencies first, then GUI elements that depend on them
files_to_load = [
    // Core functions (assuming no inter-dependencies between these for now)
    fullfile(currentPath, 'src', 'core', 'plant.sce');
    fullfile(currentPath, 'src', 'core', 'controller.sce');
    fullfile(currentPath, 'src', 'core', 'analysis.sce');

    // Plotting functions (might depend on core)
    fullfile(currentPath, 'src', 'plots', 'bode_plots.sce');

    // GUI Callbacks (might depend on core/plotting)
    fullfile(currentPath, 'src', 'gui', 'callbacks.sce');

    // Main GUI definition (depends on callbacks being defined if assigned directly)
    fullfile(currentPath, 'src', 'gui', 'main_gui.sce')
];
disp("Files to load:"); disp(files_to_load);
// ------------------------------------------------

for i = 1:size(files_to_load, "*") // Use size with "*" for robustness
    file_path = files_to_load(i);
    disp(" "); // Blank line
    disp("--> Attempting to exec: " + file_path);

    if isfile(file_path) then
        try
            exec(file_path, 0); // Verbose execution
            disp("--- Successfully executed: " + file_path);
        catch
            disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            disp("ERROR executing file: " + file_path);
            disp(lasterror());
            errored = %T;
            disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            break; // Stop on first error
        end
    else
        disp("!!! WARNING: File not found, skipping: " + file_path);
        // Decide if missing file is critical
        // errored = %T; break;
    end
end

// --- Final Check ---
disp(" ");
if errored then
    error("Simplified main.sce failed due to errors during exec.");
else
    disp("Simplified main.sce finished execution.");
    // Check IMMEDIATELY if main_gui exists NOW
    if exists('main_gui') == 1 then
        disp(">>> SUCCESS: ''main_gui'' function IS DEFINED after loading.");
        disp(">>> You should be able to call main_gui() manually.");
    else
        disp(">>> FAILURE: ''main_gui'' function IS UNDEFINED after loading!");
        disp(">>> Problem likely within the exec process or one of the loaded files.");
    end
end
