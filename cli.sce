// File: cli.sce
// Main entry point for the SciLoopShaper Command-Line Interface (CLI)

// --- Basic Setup ---
clear;
mode(0); // Set mode for less verbose output from Scilab functions

// --- Path and File Loading ---
currentPath = get_absolute_file_path('cli.sce');
errored = %F;

// --- Load all source files ---
// This ensures that all functions from core, plots, and the new cli
// are available in the environment.
files_to_load = [
    // Core functions
    fullfile(currentPath, 'src', 'core', 'plant.sce');
    fullfile(currentPath, 'src', 'core', 'controller.sce');
    fullfile(currentPath, 'src', 'core', 'analysis.sce');

    // Plotting functions
    fullfile(currentPath, 'src', 'plots', 'bode_plots.sce');

    // CLI functions (in order of dependency)
    fullfile(currentPath, 'src', 'cli', 'cli_parser.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_help.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_output.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_commands.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_main.sce');
];

for i = 1:size(files_to_load, "*")
    file_path = files_to_load(i);
    if isfile(file_path) then
        try
            exec(file_path, 0);
        catch
            disp("ERROR executing file: " + file_path);
            disp(lasterror());
            errored = %T;
            break;
        end
    else
        disp("WARNING: File not found, skipping: " + file_path);
        errored = %T;
        break;
    end
end

if errored then
    error("CLI failed to load necessary files. Aborting.");
end

// --- Argument Parsing ---
// Get all command-line arguments provided to Scilab
all_args = sciargs();
user_args = [];

// Find the '-args' flag to isolate the arguments meant for our script
args_start_index = find(all_args == "-args");

if ~isempty(args_start_index) then
    // If '-args' is found, take all subsequent arguments
    user_args = all_args(args_start_index + 1 : $);
else
    // If '-args' is not found, we might be in an interactive session
    // or the script was called without arguments. For now, we assume no args.
    user_args = [];
end

// --- Execute Main CLI Logic ---
// Check if the main function exists before calling it
if exists('cli_main') <> 1 then
    error("The 'cli_main' function is not defined. Check src/cli/cli_main.sce");
else
    // Call the main function with the user arguments
    cli_main(user_args);
end

// --- Clean Exit ---
// Use 'quit' for non-interactive sessions to ensure Scilab terminates.
// We might add a flag later to control this behavior.
// quit();
