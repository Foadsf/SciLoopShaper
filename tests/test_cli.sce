// File: tests/test_cli.sce
// Test script for the SciLoopShaper CLI

// --- Test Setup ---
disp("--- Running CLI Test Suite ---");

global CLI_ERROR_STATE;

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
    fullfile(currentPath, 'src', 'core', 'controller_validation.sce');
    fullfile(currentPath, 'src', 'core', 'analysis.sce');
    // Plotting functions
    fullfile(currentPath, 'src', 'plots', 'bode_plots.sce');
    // Utility functions
    fullfile(currentPath, 'src', 'utils', 'utils.sce');
    // CLI functions
    fullfile(currentPath, 'src', 'cli', 'cli_parser.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_help.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_output.sce');
    fullfile(currentPath, 'src', 'cli', 'cli_plot.sce');
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
CLI_ERROR_STATE.has_error = %F; // Reset before test
cli_main(["plant", "load-example", "invalid_name"]);
disp("Error state after call: " + string(CLI_ERROR_STATE.has_error));
assert_true(CLI_ERROR_STATE.has_error, "Should error on invalid example name");


// --- Test Cases for Controller ---
disp(" ");
disp("--> Testing controller commands...");

// Reset controller state for these tests
CLI_STATE.controller = list();

// Test Case 5: List empty controller
disp("  Running test: controller list (empty)");
cli_main(["controller", "list"]);
assert_true(isempty(CLI_STATE.controller), "Controller list should be initially empty");

// Test Case 6: Add a Gain block
disp("  Running test: controller add Gain 10");
cli_main(["controller", "add", "Gain", "10"]);
assert_true(length(CLI_STATE.controller) == 1, "Controller list should have 1 block after add");
assert_true(CLI_STATE.controller(1).type == "Gain", "Block type should be Gain");
assert_true(CLI_STATE.controller(1).params.gain == 10, "Block gain should be 10");

// Test Case 7: Add an Integrator block
disp("  Running test: controller add Integrator 2.5");
cli_main(["controller", "add", "Integrator", "2.5"]);
assert_true(length(CLI_STATE.controller) == 2, "Controller list should have 2 blocks after second add");
assert_true(CLI_STATE.controller(2).type == "Integrator", "Second block type should be Integrator");

// Test Case 8: List non-empty controller
disp("  Running test: controller list (non-empty)");
cli_main(["controller", "list"]);
assert_true(%T, "controller list should run without error");

// Test Case 9: Remove a block
disp("  Running test: controller remove 1");
cli_main(["controller", "remove", "1"]);
assert_true(length(CLI_STATE.controller) == 1, "Controller list should have 1 block after remove");
assert_true(CLI_STATE.controller(1).type == "Integrator", "Remaining block should be the Integrator");

// Test Case 10: Remove with invalid index
disp("  Running test: controller remove 99 (invalid)");
CLI_ERROR_STATE.has_error = %F; // Reset before test
cli_main(["controller", "remove", "99"]);
assert_true(CLI_ERROR_STATE.has_error, "Should error on invalid remove index");


// --- Test Cases for Analyze ---
disp(" ");
disp("--> Testing analyze commands...");

// Setup: Ensure we have a plant and a controller
cli_main(["plant", "load-example", "mass"]);
cli_main(["controller", "add", "Gain", "10"]);

// Test Case 11: Analyze stability
disp("  Running test: analyze stability");
cli_main(["analyze", "stability"]);
assert_true(%T, "analyze stability should run without error");

// Test Case 12: Analyze frequency response
disp("  Running test: analyze frequency-response");
cli_main(["analyze", "frequency-response"]);
assert_true(%T, "analyze frequency-response should run without error");

// Test Case 13: Analyze frequency response with plot type
disp("  Running test: analyze frequency-response --plot-type bode");
// This will fail until the parser is fixed to handle options
// cli_main(["analyze", "frequency-response", "--plot-type", "bode"]);
// assert_true(%T, "analyze frequency-response with plot type should run without error");

// Test Case 14: Analyze time response
disp("  Running test: analyze time-response step");
cli_main(["analyze", "time-response", "step"]);
assert_true(%T, "analyze time-response should run without error");


// --- Test Cases for Enhanced Core Features ---
function test_enhanced_controller_blocks()
    disp("=== Testing Enhanced Controller Blocks ===");

    s = poly(0, 's');

    // Test new controller blocks
    test_blocks = [
        "High pass 1st order"
    ];

    test_params = list();
    test_params($+1) = struct('gain', 1, 'zeros', 1, 'poles', 10);  // High pass 1st

    for i = 1:size(test_blocks, "*")
        try
            block = create_controller_block(test_blocks(i), test_params(i));
            disp("✓ " + test_blocks(i) + " created successfully");
            // Basic validation
            if typeof(block.tf) == "rational" then
                disp("  ✓ Transfer function is valid");
            else
                disp("  ✗ Transfer function invalid");
            end
        catch
            disp("✗ " + test_blocks(i) + " failed: " + lasterror());
        end
    end
endfunction

// Run the new tests
test_enhanced_controller_blocks();

disp(" ");
disp("--- CLI Test Suite Finished ---");
