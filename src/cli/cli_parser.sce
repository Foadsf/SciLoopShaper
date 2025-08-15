// File: src/cli/cli_parser.sce

function [parsed_command] = cli_parse_arguments(args)
    // Initialize the structure to hold the parsed command
    parsed_command = struct(..
        "global_options", struct("verbose", %F, "quiet", %F, "output_dir", "", "config", ""), ..
        "command", "", ..
        "sub_command", "", ..
        "args", [], ..
        "command_options", struct() ..
    );

    if isempty(args) then
        return;
    end

    // --- Parsing Logic ---
    i = 1;
    while i <= length(args)
        arg = args(i);

        // Check for global options
        idx_double = strindex(arg, "--");
        idx_single = strindex(arg, "-");

        if ~isempty(idx_double) && idx_double(1) == 1 then
            select arg
            case "--verbose"
                parsed_command.global_options.verbose = %T;
            case "--quiet"
                parsed_command.global_options.quiet = %T;
            case "--output-dir"
                if i + 1 <= length(args) then
                    i = i + 1;
                    parsed_command.global_options.output_dir = args(i);
                else
                    error("The --output-dir option requires a value.");
                end
            case "--config"
                if i + 1 <= length(args) then
                    i = i + 1;
                    parsed_command.global_options.config = args(i);
                else
                    error("The --config option requires a value.");
                end
            case "--help"
                parsed_command.command = "help";
                return;
             case "--version"
                parsed_command.command = "version";
                return;
            else
                error("Unknown global option: " + arg);
            end
        elseif ~isempty(idx_single) && idx_single(1) == 1 then
             select arg
                case "-v"
                    parsed_command.global_options.verbose = %T;
                case "-q"
                    parsed_command.global_options.quiet = %T;
                case "-o"
                     if i + 1 <= length(args) then
                        i = i + 1;
                        parsed_command.global_options.output_dir = args(i);
                    else
                        error("The -o option requires a value.");
                    end
                case "-h"
                    parsed_command.command = "help";
                    return;
                else
                    error("Unknown global option: " + arg);
             end
        else
            // Not an option, must be command, sub-command or argument
            if parsed_command.command == "" then
                parsed_command.command = arg;
            elseif parsed_command.sub_command == "" then
                parsed_command.sub_command = arg;
            else
                parsed_command.args(length(parsed_command.args) + 1) = arg;
            end
        end
        i = i + 1;
    end
endfunction
