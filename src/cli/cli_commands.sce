// File: src/cli/cli_commands.sce (SIMPLIFIED FOR DEBUGGING)

function cli_execute_command(parsed_command)
    // This function is the main command dispatcher.
    global CLI_STATE;

    select parsed_command.command
    case "plant"
        cli_handle_plant_command(parsed_command);
    case "controller"
        cli_handle_controller_command(parsed_command);
    case "analyze"
        cli_handle_analysis_command(parsed_command);
    else
        error("Unknown command: " + parsed_command.command);
    end
endfunction


function cli_handle_plant_command(parsed_command)
    // This function handles all sub-commands for the 'plant' command.
    global CLI_STATE;
    global CLI_ERROR_STATE;

    select parsed_command.subcommand
    case "load-workspace"
        if size(parsed_command.args, "*") <> 1 then
            error("Usage: plant load-workspace <VARIABLE_NAME>");
        end
        var_name = parsed_command.args(1);
        try
            CLI_STATE.plant = load_plant_from_workspace(var_name);
            disp("Plant loaded successfully.");
        catch
            error("Failed to load plant from workspace: " + lasterror());
        end

    case "load-example"
        if size(parsed_command.args, "*") <> 1 then
            error("Usage: plant load-example {mass|2-mass-collocated|2-mass-non-collocated}");
        end
        example_name = parsed_command.args(1);
        valid_examples = ["mass", "2-mass-collocated", "2-mass-non-collocated"];
        if ~or(valid_examples == example_name) then
            valid_examples_str = "";
            for i = 1:size(valid_examples, "*")
                valid_examples_str = valid_examples_str + valid_examples(i) + ", ";
            end
            disp("Setting error state for invalid example name.");
            CLI_ERROR_STATE.has_error = %T;
            CLI_ERROR_STATE.message = "Invalid example name. Must be one of: " + valid_examples_str;
            return;
        end
        try
            CLI_STATE.plant = create_example_plant(example_name);
            disp("Example plant loaded successfully.");
        catch
            error("Failed to create example plant: " + lasterror());
        end

    case "info"
        if isempty(CLI_STATE.plant) then
            disp("No plant loaded.");
        else
            disp("Current Plant Information:");
            disp(CLI_STATE.plant);
        end

    else
        error("Unknown plant command: " + parsed_command.subcommand);
    end
endfunction


function cli_handle_controller_command(parsed_command)
    global CLI_STATE;
    global CLI_ERROR_STATE;

    select parsed_command.subcommand
    case "list"
        if isempty(CLI_STATE.controller) then
            disp("No controller blocks have been added.");
            return;
        end
        disp("Current Controller Blocks:");
        disp("Type of controller list: " + typeof(CLI_STATE.controller));
        for i = 1:length(CLI_STATE.controller)
            block = CLI_STATE.controller(i);
            disp("  Block " + string(i) + ":");
            disp("    Type: " + block.type);
            disp("    Parameters:");
            disp(block.params);
        end

    case "add"
        if size(parsed_command.args, "*") < 2 then
            error("Usage: controller add <BLOCK_TYPE> [PARAMETERS...]");
        end
        blockType = parsed_command.args(1);
        params = struct();

        select blockType
        case "Gain"
            if size(parsed_command.args, "*") <> 2 then
                error("Usage: controller add Gain <gain_value>");
            end
            params.gain = evstr(parsed_command.args(2));
        case "Integrator"
            if size(parsed_command.args, "*") <> 2 then
                error("Usage: controller add Integrator <gain_value>");
            end
            params.gain = evstr(parsed_command.args(2));
        else
            error("Unsupported block type for ''add'' command: " + blockType);
        end

        try
            new_block = create_controller_block(blockType, params);
            if isempty(CLI_STATE.controller) then
                CLI_STATE.controller = list(new_block);
            else
                CLI_STATE.controller($+1) = new_block;
            end
            disp("Added new block: " + blockType);
        catch
            error("Failed to add controller block: " + lasterror());
        end

    case "remove"
        if size(parsed_command.args, "*") <> 1 then
            error("Usage: controller remove <BLOCK_INDEX>");
        end
        index_str = parsed_command.args(1);
        index = evstr(index_str);

        if isempty(index) | type(index) <> 1 | index < 1 | length(CLI_STATE.controller) == 0 | index > length(CLI_STATE.controller) then
            CLI_ERROR_STATE.has_error = %T;
            CLI_ERROR_STATE.message = "Invalid block index.";
            return;
        end

        CLI_STATE.controller(index) = null();
        disp("Removed block at index: " + index_str);

    else
        error("Unknown controller command: " + parsed_command.subcommand);
    end
endfunction


function cli_handle_analysis_command(parsed_command)
    global CLI_STATE;

    select parsed_command.subcommand
    case "stability"
        handle_analyze_stability(parsed_command.args, parsed_command.options);
    case "frequency-response"
        handle_analyze_frequency_response(parsed_command.args, parsed_command.options);
    case "time-response"
        handle_analyze_time_response(parsed_command.args, parsed_command.options);
    case "margins"
        handle_analyze_margins(parsed_command.args, parsed_command.options);
    else
        error("Unknown analyze subcommand: " + parsed_command.subcommand);
    end
endfunction


function handle_analyze_stability(args, options)
    global CLI_STATE;

    // Existing safety checks (keep these)
    if ~isdef('CLI_STATE', 'n') then
        cli_error("CLI system not initialized");
        return;
    end

    if ~isfield(CLI_STATE, 'plant') then
        cli_error("Plant field not initialized");
        return;
    end

    if CLI_STATE.plant == [] then
        cli_error("No plant loaded. Use ''plant load-*'' commands first.");
        return;
    end

    // NEW: Real stability analysis
    try
        // Get controller or use unity gain if none
        if length(CLI_STATE.controller) > 0 then
            controller = calculate_controller(CLI_STATE.controller);
        else
            controller = syslin('c', 1, 1); // Unity gain
        end

        // Perform stability analysis using existing core function
        results = analyze_stability(CLI_STATE.plant, controller);

        // Display results
        disp("=== Stability Analysis Results ===");
        disp("System Stable: " + string(results.stable));
        disp("Gain Margin: " + string(results.gain_margin) + " dB");
        disp("Phase Margin: " + string(results.phase_margin) + " deg");
        disp("Bandwidth: " + string(results.bandwidth) + " Hz");

    catch
        disp("Error during stability analysis: " + lasterror());
    end
endfunction


function handle_analyze_frequency_response(args, options)
    global CLI_STATE;

    // Safety checks (same pattern as stability)
    if ~isdef('CLI_STATE', 'n') then
        cli_error("CLI system not initialized");
        return;
    end

    if CLI_STATE.plant == [] then
        cli_error("No plant loaded. Use ''plant load-*'' commands first.");
        return;
    end

    try
        // Get system for analysis
        if length(CLI_STATE.controller) > 0 then
            sys = CLI_STATE.plant * calculate_controller(CLI_STATE.controller);
        else
            sys = CLI_STATE.plant;
        end

        // Calculate frequency response
        [mag, phase, w] = calculate_frequency_response(sys, CLI_STATE.freq.min, CLI_STATE.freq.max, CLI_STATE.freq.points);

        // Display summary
        disp("=== Frequency Response Analysis ===");
        disp("Frequency range: " + string(w(1)) + " to " + string(w($)) + " Hz");
        disp("Number of points: " + string(length(w)));

        // Find key characteristics
        mag_db = 20*log10(mag + 1e-12);
        max_mag = max(mag_db);
        min_mag = min(mag_db);

        disp("Magnitude range: " + string(min_mag) + " to " + string(max_mag) + " dB");

    catch
        disp("Error during frequency response analysis: " + lasterror());
    end
endfunction


function handle_analyze_time_response(args, options)
    global CLI_STATE;

    // Safety checks
    if ~isdef('CLI_STATE', 'n') then
        cli_error("CLI system not initialized");
        return;
    end

    if CLI_STATE.plant == [] then
        cli_error("No plant loaded. Use ''plant load-*'' commands first.");
        return;
    end

    // Parse input type argument
    if length(args) < 1 then
        disp("Error: time-response requires input type: {step|impulse|sine}");
        return;
    end

    input_type = args(1);
    valid_inputs = ["step", "impulse", "sine"];
    if ~or(input_type == valid_inputs) then
        disp("Error: Invalid input type. Use: step, impulse, or sine");
        return;
    end

    try
        // Get controller or use unity gain
        if length(CLI_STATE.controller) > 0 then
            controller = calculate_controller(CLI_STATE.controller);
        else
            controller = syslin('c', 1, 1);
        end

        // Create time vector
        duration = 5.0;  // Default 5 seconds
        points = 500;    // Default 500 points
        time_vector = linspace(0, duration, points);

        // Calculate time response
        if input_type == "step" then
            resp = calculate_time_response(CLI_STATE.plant, controller, "step", time_vector);

            // Calculate step response metrics
            final_value = resp($);
            max_value = max(resp);
            overshoot = (max_value - final_value) / abs(final_value) * 100;

            disp("=== Step Response Analysis ===");
            disp("Final value: " + string(final_value));
            disp("Peak value: " + string(max_value));
            disp("Overshoot: " + string(overshoot) + "%");

        elseif input_type == "impulse" then
            // For impulse response, use derivative of step
            resp = calculate_time_response(CLI_STATE.plant, controller, "step", time_vector);
            // Simple numerical derivative
            impulse_resp = [0; diff(resp)];

            disp("=== Impulse Response Analysis ===");
            disp("Peak impulse response: " + string(max(abs(impulse_resp))));

        else  // sine
            disp("=== Sine Response Analysis ===");
            disp("Sine response analysis not yet implemented");
        end

    catch
        disp("Error during time response analysis: " + lasterror());
    end
endfunction


function handle_analyze_margins(args, options)
    global CLI_STATE;

    // Safety checks (same pattern)
    if ~isdef('CLI_STATE', 'n') then
        cli_error("CLI system not initialized");
        return;
    end

    if CLI_STATE.plant == [] then
        cli_error("No plant loaded. Use ''plant load-*'' commands first.");
        return;
    end

    try
        // Get controller or use unity gain
        if length(CLI_STATE.controller) > 0 then
            controller = calculate_controller(CLI_STATE.controller);
        else
            controller = syslin('c', 1, 1);
        end

        // Reuse stability analysis
        results = analyze_stability(CLI_STATE.plant, controller);

        // Display only margins (focused output)
        disp("=== Stability Margins ===");
        disp("Gain Margin: " + string(results.gain_margin) + " dB");
        disp("Phase Margin: " + string(results.phase_margin) + " deg");
        disp("Bandwidth: " + string(results.bandwidth) + " Hz");

    catch
        disp("Error during margin analysis: " + lasterror());
    end
endfunction
