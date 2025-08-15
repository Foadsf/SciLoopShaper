// File: tests/test_cli.sce
// Test script for the SciLoopShaper CLI

// --- Test Setup ---
disp("--- Running CLI Test Suite ---");

// The project root is the current working directory.
currentPath = pwd();
disp("Calculated project root: " + currentPath);

// --- Load all source files ---
// This is similar to what cli.sce does
errored = %F;
files_to_load = [
    // Core functions
    fullfile(currentPath, 'src', 'core', 'plant.sce');
    fullfile(currentPath, 'src', 'core', 'controller.sce');
    fullfile(currentPath, 'src', 'core', 'analysis.sce');
    // Plotting functions
    fullfile(currentPath, 'src', 'plots', 'bode_plots.sce');
    // CLI functions
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
            disp("ERROR loading file for test: " + file_path);
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
    error("Test suite failed to load necessary files. Aborting.");
end


// --- Test Runner ---
function assert_true(condition, test_name)
    if condition then
        disp("  [PASS] " + test_name);
    else
        disp("  [FAIL] " + test_name);
    end
end

// --- Test Cases ---

disp(" ");
disp("--> Testing plant commands...");

// Test Case 1: Load an example plant
disp("  Running test: plant load-example mass");
cli_main(["plant", "load-example", "mass"]);
assert_true(~isempty(CLI_STATE.plant) & typeof(CLI_STATE.plant) == "rational", "Plant should be loaded after load-example");

// Test Case 2: Use 'plant info'
disp("  Running test: plant info");
// We just check if this runs without error
cli_main(["plant", "info"]);
assert_true(%T, "plant info should run without error");


// Test Case 3: Load a plant from the workspace
disp("  Running test: plant load-workspace my_test_plant");
s = poly(0,'s');
my_test_plant = syslin('c', 1/(s+1));
// Call the CLI main function with the arguments
cli_main(["plant", "load-workspace", "my_test_plant"]);
// Check if the plant was loaded correctly
assert_true(~isempty(CLI_STATE.plant) & isequal(CLI_STATE.plant, my_test_plant), "Plant should be loaded from workspace");


// Test Case 4: Invalid example name
disp("  Running test: plant load-example invalid_name");
// This should produce an error. We can use try/catch to verify this.
should_error = %F;
try
    cli_main(["plant", "load-example", "invalid_name"]);
catch
    should_error = %T;
end
assert_true(should_error, "Should error on invalid example name");


disp(" ");
disp("--- CLI Test Suite Finished ---");
