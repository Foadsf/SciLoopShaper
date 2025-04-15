// SciLoopShaper - A SISO Loop-Shaping Tool for Scilab
// Released under GPL - see LICENSE file for details

// Execute files containing function definitions to load them

disp("Loading SciLoopShaper functions...");

currentPath = get_absolute_file_path('main.sce');
errored = %F; // Flag to track errors

// List of function definition files relative to src/
func_files = [
    "core/analysis.sce";
    "core/controller.sce";
    "core/plant.sce";
    "gui/callbacks.sce";
    "gui/main_gui.sce"; // Contains the main GUI function itself
    "plots/bode_plots.sce"
    // Add other files from src/io, src/utils etc. as they are created
];

for i = 1:size(func_files, 1)
    file_path = fullfile(currentPath, 'src', func_files(i));
    if isfile(file_path) then
        try
            exec(file_path, -1); // Execute silently
            // disp("Loaded: " + func_files(i)); // Uncomment for verbose loading
        catch
            disp("Error executing file: " + file_path);
            disp(lasterror());
            errored = %T;
            break; // Stop if one file fails
        end
    else
        disp("Function file not found: " + file_path);
        errored = %T;
        break; // Stop if file is missing
    end
end

if errored then
    error("SciLoopShaper failed to load necessary function files.");
else
    disp("SciLoopShaper functions loaded successfully.");
    // Optional: If you want main.sce to immediately launch the GUI when executed directly
    // uncomment the next line. For testing, it's better to keep it commented.
    // main_gui();
end
