// File: src/utils/utils.sce

function [val] = get_option(options, option_name, default_value)
    // Searches the 'options' struct for 'option_name' and returns its value.
    // If not found, it returns 'default_value'.
    if isfield(options, option_name) then
        val = options(option_name);
    else
        val = default_value;
    end
endfunction

function cli_error(message)
    global CLI_ERROR_STATE;
    CLI_ERROR_STATE.has_error = %T;
    CLI_ERROR_STATE.message = message;
    disp("ERROR: " + message);
endfunction

function cli_warning(message)
    // Placeholder for warning message formatting
    disp("WARNING: " + message);
endfunction

function cli_info(message)
    // Placeholder for info message formatting
    disp("INFO: " + message);
endfunction

function [sys] = get_combined_system()
    global CLI_STATE;

    if isempty(CLI_STATE.controller) then
        sys = CLI_STATE.plant;
    else
        // Combine all controller blocks first
        controller_tf = CLI_STATE.controller(1).tf;
        for i = 2:length(CLI_STATE.controller)
            controller_tf = controller_tf * CLI_STATE.controller(i).tf;
        end
        sys = CLI_STATE.plant * controller_tf;
    end
endfunction

function [flag] = get_option_flag(options, flag_name, default_value)
    // Checks for the presence of a flag-like option.
    if isfield(options, flag_name) then
        flag = %T;
    else
        flag = default_value;
    end
endfunction
