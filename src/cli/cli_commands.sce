// File: src/cli/cli_commands.sce

function cli_execute_command(parsed_command)
    // This function is the main command dispatcher.
    // It takes the parsed command and calls the appropriate handler.

    // Use a global state to store plant, controller, etc.
    global CLI_STATE;

    // Dispatch based on the main command
    select parsed_command.command
    case "plant"
        cli_handle_plant_command(parsed_command);
    case "controller"
        cli_handle_controller_command(parsed_command);
    case "analyze"
        cli_handle_analysis_command(parsed_command);
    // ... other commands
    else
        error("Unknown command: " + parsed_command.command);
    end
endfunction


function cli_handle_plant_command(parsed_command)
    // This function handles all sub-commands for the 'plant' command.
    global CLI_STATE;

    select parsed_command.sub_command
    case "load-workspace"
        if length(parsed_command.args) <> 1 then
            error("Usage: plant load-workspace <VARIABLE_NAME>");
        end
        var_name = parsed_command.args(1);
        disp("Loading plant from workspace variable: " + var_name);
        try
            CLI_STATE.plant = load_plant_from_workspace(var_name);
            disp("Plant loaded successfully.");
        catch
            error("Failed to load plant from workspace: " + lasterror());
        end

    case "load-example"
        if length(parsed_command.args) <> 1 then
            error("Usage: plant load-example {mass|2-mass-collocated|2-mass-non-collocated}");
        end
        example_name = parsed_command.args(1);
        valid_examples = ["mass", "2-mass-collocated", "2-mass-non-collocated"];
        if ~or(valid_examples == example_name) then
             error("Invalid example name. Must be one of: " + strjoin(valid_examples, ", "));
        end

        disp("Loading example plant: " + example_name);
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
        error("Unknown plant command: " + parsed_command.sub_command);
    end
endfunction


function cli_handle_controller_command(parsed_command)
    global CLI_STATE;

    select parsed_command.sub_command
    case "list"
        if isempty(CLI_STATE.controller) then
            disp("No controller blocks have been added.");
            return;
        end
        disp("Current Controller Blocks:");
        for i = 1:length(CLI_STATE.controller)
            block = CLI_STATE.controller(i);
            param_str = "";
            fields = fieldnames(block.params);
            for j = 1:length(fields)
                param_str = param_str + fields(j) + "=" + string(block.params(fields(j))) + " ";
            end
            disp(string(i) + ": " + block.type + " (" + param_str + ")");
        end

    case "add"
        if length(parsed_command.args) < 2 then
            error("Usage: controller add <BLOCK_TYPE> [param=value...]");
        end
        blockType = parsed_command.args(1);
        params = struct();

        for i = 2:length(parsed_command.args)
            parts = strsplit(parsed_command.args(i), '=');
            if length(parts) <> 2 then
                error("Invalid parameter format. Use param=value.");
            end
            key = parts(1);
            value = evstr(parts(2));
            params(key) = value;
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
        if length(parsed_command.args) <> 1 then
            error("Usage: controller remove <BLOCK_INDEX>");
        end
        index_str = parsed_command.args(1);
        index = evstr(index_str);

        if isempty(index) | type(index) <> 1 | index < 1 | index > length(CLI_STATE.controller) then
            error("Invalid block index.");
        end

        CLI_STATE.controller(index) = [];
        disp("Removed block at index: " + index_str);

    else
        error("Unknown controller command: " + parsed_command.sub_command);
    end
endfunction


function cli_handle_analysis_command(parsed_command)
    global CLI_STATE;

    select parsed_command.sub_command
    case "stability"
        handle_analyze_stability(parsed_command.args, parsed_command.command_options);
    case "frequency-response"
        handle_analyze_frequency_response(parsed_command.args, parsed_command.command_options);
    case "time-response"
        handle_analyze_time_response(parsed_command.args, parsed_command.command_options);
    case "margins"
        handle_analyze_margins(parsed_command.args, parsed_command.command_options);
    else
        error("Unknown analyze subcommand: " + parsed_command.sub_command);
    end
endfunction


function handle_analyze_stability(args, options)
    global CLI_STATE;

    if isempty(CLI_STATE.plant) then
        cli_error("No plant loaded. Use 'plant load-*' commands first.");
        return;
    end

    if isempty(CLI_STATE.controller) then
        cli_warning("No controller loaded. Analyzing plant only.");
        controller = syslin('c', 1, 1);
    else
        controller = CLI_STATE.controller(1).tf;
    end

    try
        results = analyze_stability(CLI_STATE.plant, controller);
        format = get_option(options, 'output-format', 'text');
        output_file = get_option(options, 'output-file', '');

        select format
        case 'text' then
            output = format_stability_text(results);
        case 'json' then
            output = format_stability_json(results);
        case 'csv' then
            output = format_stability_csv(results);
        else
            cli_error("Unknown output format: " + format);
            return;
        end

        if output_file == '' then
            disp(output);
        else
            write_output_file(output_file, output);
            cli_info("Stability analysis saved to: " + output_file);
        end

    catch
        cli_error("Stability analysis failed: " + lasterror());
    end
endfunction

function handle_analyze_frequency_response(args, options)
    global CLI_STATE;

    if isempty(CLI_STATE.plant) then
        cli_error("No plant loaded. Use 'plant load-*' commands first.");
        return;
    end

    sys = get_combined_system();

    w_min = CLI_STATE.freq.min;
    w_max = CLI_STATE.freq.max;
    n_points = CLI_STATE.freq.points;

    plot_type = get_option(options, 'plot-type', 'bode');
    save_plot = get_option(options, 'save-plot', '');
    show_data = get_option_flag(options, 'show-data', %F);

    try
        [mag, phase, w] = calculate_frequency_response(sys, w_min, w_max, n_points);
        display_frequency_response_summary(mag, phase, w);

        if plot_type <> 'none' then
            generate_frequency_plot(sys, plot_type, w_min, w_max, n_points, save_plot);
        end

    catch
        cli_error("Frequency response analysis failed: " + lasterror());
    end
endfunction

function handle_analyze_time_response(args, options)
    global CLI_STATE;
    disp("--- handle_analyze_time_response ---");
endfunction

function handle_analyze_margins(args, options)
    global CLI_STATE;
    disp("--- handle_analyze_margins ---");
endfunction
