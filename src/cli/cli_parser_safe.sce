function [parsed_command] = cli_parse_arguments_safe(args)
    // Safe argument parser for Scilab 2024.0.0

    // Initialize return structure
    parsed_command = struct();
    parsed_command.command = "";
    parsed_command.subcommand = "";
    parsed_command.arguments = [];
    parsed_command.options = struct();
    parsed_command.valid = %F;

    // Input validation
    if ~exists('args', 'local') then
        disp("ERROR: No arguments parameter provided to parser");
        return;
    end

    // Convert args to proper format if needed
    if typeof(args) ~= "string" then
        disp("ERROR: Arguments must be string array, got: " + typeof(args));
        return;
    end

    args_size = size(args, "*");
    if args_size == 0 then
        disp("DEBUG: Empty arguments array");
        parsed_command.valid = %T;
        return;
    end

    disp("DEBUG: Processing " + string(args_size) + " arguments");

    // Safe processing loop
    try
        i = 1;
        arg_index = 1;

        while i <= args_size
            // Defensive bounds checking
            if i > size(args, "*") then
                disp("WARNING: Index exceeded array bounds, breaking");
                break;
            end

            current_arg = args(i);
            disp("DEBUG: arg[" + string(i) + "] = '" + current_arg + "'");

            // Process first argument as command
            if arg_index == 1 then
                parsed_command.command = current_arg;
                arg_index = arg_index + 1;

            // Process second argument as subcommand (if not an option)
            elseif arg_index == 2 & part(current_arg, 1:1) ~= "-" then
                parsed_command.subcommand = current_arg;
                arg_index = arg_index + 1;

            // Process options (start with -)
            elseif part(current_arg, 1:1) == "-" then
                if part(current_arg, 1:2) == "--" then
                    // Long option
                    option_name = part(current_arg, 3:$);
                    // Check if next arg is the value
                    if i + 1 <= args_size then
                        next_arg = args(i + 1);
                        if part(next_arg, 1:1) ~= "-" then
                            // Next arg is the value
                            parsed_command.options(option_name) = next_arg;
                            i = i + 1; // Skip next arg
                        else
                            // Flag option (no value)
                            parsed_command.options(option_name) = "true";
                        end
                    else
                        // Flag option (no more args)
                        parsed_command.options(option_name) = "true";
                    end
                else
                    // Short option
                    option_name = part(current_arg, 2:$);
                    parsed_command.options(option_name) = "true";
                end

            // Process regular arguments
            else
                parsed_command.arguments = [parsed_command.arguments; current_arg];
            end

            i = i + 1;
        end

        parsed_command.valid = %T;
        disp("DEBUG: Parsing completed successfully");

    catch
        disp("ERROR in parser: " + lasterror());
        parsed_command.valid = %F;
    end

endfunction
