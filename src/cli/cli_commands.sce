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

    disp("--- Inside plant command handler ---");
    disp("Type of args: " + typeof(parsed_command.args));
    disp("Length of args: " + string(length(parsed_command.args)));

    select parsed_command.sub_command
    case "load-workspace"
        // Check for correct number of arguments
        if length(parsed_command.args) <> 1 then
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
        if length(parsed_command.args) <> 1 then
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
    // This function handles all sub-commands for the 'controller' command.
    global CLI_STATE;

    // disp("Controller command handler is temporarily disabled for debugging.");

    select parsed_command.sub_command
    case "list"
        if isempty(CLI_STATE.controller) then
            disp("No controller blocks have been added.");
            return;
        end
        disp("Current Controller Blocks:");
        for i = 1:length(CLI_STATE.controller)
            block = CLI_STATE.controller(i);
            // Convert params struct to a string for display
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

        // Simple parameter parsing for now (e.g., gain=10)
        for i = 2:length(parsed_command.args)
            parts = strsplit(parsed_command.args(i), '=');
            if length(parts) <> 2 then
                error("Invalid parameter format. Use param=value.");
            end
            key = parts(1);
            value = evstr(parts(2)); // Use evstr to convert string to number
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
        index = evstr(index_str); // Convert string to number

        if isempty(index) | type(index) <> 1 | index < 1 | index > length(CLI_STATE.controller) then
            error("Invalid block index.");
        end

        // Remove the block from the list
        CLI_STATE.controller(index) = [];
        disp("Removed block at index: " + index_str);

    // case "set-params"
    //     disp("'controller set-params' command called.");
    //     // TODO: Implement logic to set controller parameters.
    // case "calculate"
    //     disp("'controller calculate' command called.");
    //     // TODO: Implement logic to calculate the combined controller.
    else
        error("Unknown controller command: " + parsed_command.sub_command);
    end
endfunction


function cli_handle_analysis_command(parsed_command)
    // This function handles all sub-commands for the 'analyze' command.
    global CLI_STATE;

    select parsed_command.sub_command
    case "stability"
        handle_analyze_stability(parsed_command.args, parsed_command.command_options);
    case "frequency-response"
        disp("analyze frequency-response not implemented yet.");
    case "time-response"
        disp("analyze time-response not implemented yet.");
    case "margins"
        disp("analyze margins not implemented yet.");
    else
        error("Unknown analyze subcommand: " + parsed_command.sub_command);
    end
endfunction


function handle_analyze_stability(args, options)
    global CLI_STATE;
    disp("--- handle_analyze_stability ---");

    // Validate state
    if isempty(CLI_STATE.plant) then
        cli_error("No plant loaded. Use 'plant load-*' commands first.");
        return;
    end
endfunction
