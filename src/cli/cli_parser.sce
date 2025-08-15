function [parsed_command] = cli_parse_arguments(args)
    // FIXED VERSION - Safe argument parsing for Scilab 2024.0.0

    // Initialize with explicit field assignments
    parsed_command = struct();
    parsed_command.command = "";
    parsed_command.subcommand = "";
    parsed_command.args = [];
    parsed_command.options = struct();

    // Input validation
    if ~exists('args', 'local') then
        disp("Warning: No args parameter provided");
        return;
    end

    // Safe size calculation
    try
        args_count = size(args, "*");
    catch
        disp("Error: Cannot determine size of args");
        return;
    end

    if args_count == 0 then
        return;
    end

    // Safe parsing with explicit bounds checking
    i = 1;
    command_set = %F;
    subcommand_set = %F;

    while i <= args_count
        // CRITICAL: Explicit bounds check before access
        if i > size(args, "*") then
            break;
        end

        // Safe array access with error handling
        try
            current_arg = args(i);
        catch
            disp("Error accessing argument at index " + string(i));
            break;
        end

        // Parse logic with explicit flags
        if ~command_set then
            parsed_command.command = current_arg;
            command_set = %T;
        elseif ~subcommand_set & part(current_arg, 1:1) ~= "-" then
            parsed_command.subcommand = current_arg;
            subcommand_set = %T;
        elseif part(current_arg, 1:2) == "--" then
            // Handle long options
            option_name = part(current_arg, 3:$);
            parsed_command.options(option_name) = "true";
        elseif part(current_arg, 1:1) == "-" then
            // Handle short options
            option_name = part(current_arg, 2:$);
            parsed_command.options(option_name) = "true";
        else
            // Regular arguments
            if isempty(parsed_command.args) then
                parsed_command.args = [current_arg];
            else
                parsed_command.args = [parsed_command.args; current_arg];
            end
        end

        i = i + 1;
    end

    // Explicit return (this may help with the return value issue)
    return;
endfunction
