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
            error("Invalid example name. Must be one of: " + valid_examples_str);
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
            param_str = "";
            fields = getfield(1, block.params);
            for j = 1:size(fields, "*")
                param_str = param_str + fields(j) + "=" + string(block.params.(fields(j))) + " ";
            end
            disp(string(i) + ": " + block.type + " (" + param_str + ")");
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
            error("Invalid block index.");
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
    // Working on fixing this function
    // FIXED VERSION - Safe global variable access
    global CLI_STATE;

    // Method 1: Check if global exists
    if ~isdef('CLI_STATE', 'n') then
        cli_error("CLI system not initialized");
        return;
    end

    // Method 2: Check if field exists
    if ~isfield(CLI_STATE, 'plant') then
        cli_error("Plant field not initialized");
        return;
    end

    // Method 3: Safe empty check - use explicit comparison instead of isempty()
    if CLI_STATE.plant == [] then
        cli_error("No plant loaded. Use ''plant load-*'' commands first.");
        return;
    end

    // Rest of your function logic here...
    disp("Analyze stability: Plant is loaded, proceeding with analysis");
endfunction


function handle_analyze_frequency_response(args, options)
    global CLI_STATE;
    disp("--- handle_analyze_frequency_response ---");
endfunction


function handle_analyze_time_response(args, options)
    global CLI_STATE;
    disp("--- handle_analyze_time_response ---");
endfunction


function handle_analyze_margins(args, options)
    global CLI_STATE;
    disp("--- handle_analyze_margins ---");
endfunction
