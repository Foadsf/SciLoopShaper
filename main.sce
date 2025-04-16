// SciLoopShaper - A SISO Loop-Shaping Tool for Scilab
// Released under GPL - see LICENSE file for details

// Execute files containing function definitions to load them

disp("Loading SciLoopShaper functions...");

currentPath = get_absolute_file_path('main.sce');
errored = %F; // Flag to track errors

// List of function definition files relative to src/
// Ensure all function files are listed here as they are created
func_files = [
    "core/analysis.sce";
    "core/controller.sce";
    "core/plant.sce";
    "gui/callbacks.sce";      // Will be created next
    "gui/main_gui.sce";       // This file itself
    "plots/bode_plots.sce"    // Bode plotting function
    // Add other files from src/io, src/utils, other plot types etc. as they are created
];

// --- Dynamically add subdirectories to the list of files to exec ---
// This is more robust if files are added/removed
subdirs_to_scan = ["core", "gui", "io", "plotting", "utils", "xcos_interface"];
func_files_dynamic = [];
for subdir = subdirs_to_scan
    dir_path = fullfile(currentPath, 'src', subdir);
    if isdir(dir_path) then
        // Find all .sce and .sci files in the subdirectory
        sce_files = listfiles(fullfile(dir_path, '*.sce'));
        sci_files = listfiles(fullfile(dir_path, '*.sci'));
        // Add relative paths to the list
        for f = sce_files', func_files_dynamic = [func_files_dynamic; fullfile(subdir, f)]; end
        for f = sci_files', func_files_dynamic = [func_files_dynamic; fullfile(subdir, f)]; end
    end
end
// Remove duplicates if any file was listed manually and found dynamically
func_files = unique(func_files_dynamic);
disp("Found function files to load:"); disp(func_files);
// --- End dynamic loading ---


for i = 1:size(func_files, 1)
    // Construct full path relative to main.sce location
    file_path = fullfile(currentPath, 'src', func_files(i));
    if isfile(file_path) then
        try
            exec(file_path, 0); // Execute silently (-1) or verbosely (0)
            disp("--- Successfully executed: " + func_files(i)); // Add explicit success message
        catch
            disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            disp("Error executing file: " + file_path);
            disp(lasterror());
            disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            errored = %T;
            break; // Stop if one file fails
        end
    else
        // Allow skipping non-existent files if planned directories are empty
        // disp("Function file not found (skipping): " + file_path);
        // errored = %T;
        // break; // Stop if file is missing
    end
end

if errored then
    error("SciLoopShaper failed to load necessary function files.");
else
    disp("SciLoopShaper functions loaded successfully.");

    // Force a global redefinition of main_gui if it exists in the file
    main_gui_path = fullfile(currentPath, 'src', 'gui', 'main_gui.sce');
    if isfile(main_gui_path) then
        disp("Reloading main_gui function to ensure global scope...");
        exec(main_gui_path, 0);

        if exists('main_gui') then
            disp("Found main_gui function, launching GUI...");
            main_gui();
        else
            disp("Warning: Could not find main_gui function after reload.");
        end
    else
        disp("Warning: Could not find main_gui.sce file.");
    end
end
