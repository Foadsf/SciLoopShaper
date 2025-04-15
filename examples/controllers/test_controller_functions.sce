// Test script for controller-related functions (FINAL CORRECTED VERSION)

clear;
mode(0);

// Load all SciLoopShaper functions
exec(fullfile(get_absolute_file_path('test_controller_functions.sce'), '../../main.sce'), -1);

s = poly(0, 's'); // Define Laplace variable

// --- Test create_controller_block ---
disp("--> Testing create_controller_block for each type:");

// Define blockTypes as a COLUMN VECTOR of strings
blockTypes = [
    "Gain";
    "Integrator";
    "Lead/lag";
    "Low pass 1st order";
    "Low pass 2nd order";
    "Notch";
    "PD";
    "Second-order Damped Integrator"
];

// Define paramsList using list() and appends
paramsList = list();
paramsList($+1) = struct('gain', 10); // Gain
paramsList($+1) = struct('gain', 5); // Integrator
paramsList($+1) = struct('gain', 1, 'zeros', 1, 'poles', 10); // Lead/lag
paramsList($+1) = struct('gain', 1, 'poles', 5); // Low pass 1st
paramsList($+1) = struct('gain', 1, 'wn', 10, 'damp', 0.7); // Low pass 2nd
paramsList($+1) = struct('gain', 1, 'zeros', 20, 'damp_zeros', 0.05, 'poles', 20, 'damp_poles', 0.5); // Notch
paramsList($+1) = struct('kp', 2, 'kd', 0.1); // PD
paramsList($+1) = struct('gain', 1, 'wn', 3, 'damp', 0.8); // Second-order Damped Integrator

controller_blocks = list();

// --- Calculate length using size() ---
numBlockTypes = size(blockTypes, "*"); // Use size() for element count
disp("Number of block types determined: " + string(numBlockTypes));
// ------------------------------------

// Use the correct count in the loop
for i = 1:numBlockTypes // <-- Use the variable here
    try
        disp(" ");
        current_block_type = blockTypes(i);
        disp("Creating block: " + current_block_type);
        clear block;
        current_params = paramsList(i);
        block = create_controller_block(current_block_type, current_params);
        controller_blocks($+1) = block;
        disp("Block TF:");
        disp(block.tf);
    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error creating block " + current_block_type + ":");
        lasterror(%t);
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end
end

// --- Test calculate_controller ---
disp(" ");
disp("--> Testing calculate_controller:");
try
    if length(controller_blocks) >= 2 then
         blocks_to_cascade = list(controller_blocks(1), controller_blocks(2));
         combined_controller = calculate_controller(blocks_to_cascade);
         disp("Combined Controller (Gain * Integrator) TF:");
         disp(combined_controller);
    else
        disp("Skipping cascade test - not enough blocks created.");
    end
    disp("Testing with empty block list:");
    empty_controller = calculate_controller(list());
    disp(empty_controller);
catch
    disp("Error calculating controller:");
    disp(lasterror());
end

// --- Test discretize_controller (basic Tustin) ---
disp(" ");
disp("--> Testing discretize_controller (Tustin):");
try
    // Use Lead/lag block (index 3)
    if length(controller_blocks) >= 3 then
         leadlag_block = controller_blocks(3); // Test with Lead/lag
         Ts = 0.01;
         disp("Discretizing Lead/lag block:"); disp(leadlag_block.tf);
         // Call with "tustin" method string (function now uses code 2 internally)
         discrete_leadlag_controller = discretize_controller(leadlag_block.tf, Ts, "tustin");

         disp("Discrete Lead/lag Controller (Ts=" + string(Ts) + ") TF:");
         disp(discrete_leadlag_controller); // Should now display the discrete TF

         // Test prewarp (expect error for now)
         disp("Testing Tustin with prewarping (expect error):");
         discretize_controller(leadlag_block.tf, Ts, "tustin_prewarp");
    else
         disp("Skipping discretize test - Lead/lag block not available.");
    end

catch
    // This catch block should now ONLY catch the unimplemented prewarp error
    disp("Caught expected error (likely prewarp unimplemented):");
    disp(lasterror());
end

disp(" ");
disp("Controller function tests complete.");

