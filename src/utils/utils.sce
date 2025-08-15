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
    // Placeholder for error message formatting
    error(message);
endfunction

function cli_warning(message)
    // Placeholder for warning message formatting
    disp("WARNING: " + message);
endfunction

function cli_info(message)
    // Placeholder for info message formatting
    disp("INFO: " + message);
endfunction
