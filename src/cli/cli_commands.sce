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
        // TODO: cli_handle_controller_command(parsed_command);
        disp("Controller commands not implemented yet.");
    case "analyze"
        // TODO: cli_handle_analysis_command(parsed_command);
        disp("Analysis commands not implemented yet.");
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
