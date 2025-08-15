// File: src/cli/cli_commands.sce (SIMPLIFIED FOR DEBUGGING)

function cli_execute_command(parsed_command)
    // This function is the main command dispatcher.
    global CLI_STATE;
    disp("--- cli_execute_command (simplified) ---");

    // select parsed_command.command
    case "plant"
        cli_handle_plant_command(parsed_command);
    case "controller"
        cli_handle_controller_command(parsed_command);
    case "analyze"
        cli_handle_analysis_command(parsed_command);
    else
    //     error("Unknown command: " + parsed_command.command);
    // end
endfunction

function cli_handle_plant_command(parsed_command)
    // This function handles all sub-commands for the 'plant' command.
    global CLI_STATE;

    disp("--- Inside plant command handler ---");
    disp("Type of args: " + typeof(parsed_command.args));
    disp("Length of args: " + string(length(parsed_command.args)));

    select parsed_command.sub_command
    case "load-workspace"
        // Check for correct number of arguments
        if size(parsed_command.args, "*") <> 1 then
            error("Usage: plant load-workspace <VARIABLE_NAME>");
        end
        var_name = parsed_command.args(1);
        disp("Loading plant from workspace variable: " + var_name);
        try
            // Call the core function
            CLI_STATE.plant = load_plant_from_workspace(var_name);
            disp("Plant loaded successfully.");
            disp(CLI_STATE.plant);
        catch
            error("Failed to load plant from workspace: " + lasterror());
        end

    case "load-example"
        if size(parsed_command.args, "*") <> 1 then
            error("Usage: plant load-example {mass|2-mass-collocated|2-mass-non-collocated}");
        end
        example_name = parsed_command.args(1);
        // Validate example name
        valid_examples = ["mass", "2-mass-collocated", "2-mass-non-collocated"];
        if ~or(valid_examples == example_name) then
             error("Invalid example name. Must be one of: " + strjoin(valid_examples, ", "));
        end

        disp("Loading example plant: " + example_name);
        try
            // Call the core function
            CLI_STATE.plant = create_example_plant(example_name);
            disp("Example plant loaded successfully.");
            disp(CLI_STATE.plant);
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

    // ... other plant sub-commands
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
        for i = 1:size(CLI_STATE.controller, "*")
            block = CLI_STATE.controller(i);
            param_str = "";
            fields = fieldnames(block.params);
            for j = 1:length(fields)
                param_str = param_str + fields(j) + "=" + string(block.params(fields(j))) + " ";
            end
            disp(string(i) + ": " + block.type + " (" + param_str + ")");
        end

    case "add"
        if size(parsed_command.args, "*") < 2 then
            error("Usage: controller add <BLOCK_TYPE> [param=value...]");
        end
        blockType = parsed_command.args(1);
        params = struct();

        for i = 2:size(parsed_command.args, "*")
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
        if size(parsed_command.args, "*") <> 1 then
            error("Usage: controller remove <BLOCK_INDEX>");
        end
        index_str = parsed_command.args(1);
        index = evstr(index_str);

        if isempty(index) | type(index) <> 1 | index < 1 | size(CLI_STATE.controller, "*") == 0 | index > size(CLI_STATE.controller, "*") then
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
    disp("--- handle_analyze_stability ---");
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
