// File: src/cli/cli_main.sce

// Initialize a global state for the CLI session
global CLI_STATE;
CLI_STATE = struct(..
    "plant", [], ..
    "controller", list(), ..
    "config", struct(), ..
    "freq", struct("min", 0.01, "max", 1000, "points", 1000) ..
);

global CLI_ERROR_STATE;
CLI_ERROR_STATE = struct("has_error", %F, "message", "");


function cli_main(args)
    // This is the main entry point for the CLI logic.
    // It receives the command-line arguments and orchestrates the actions.

    disp("Welcome to SciLoopShaper CLI!");
    disp("---------------------------------");

    if isempty(args) then
        disp("No command-line arguments provided. Use --help for usage information.");
        // TODO: Call cli_show_help('main');
        return;
    end

    // 1. Call the parser from cli_parser.sce
    try
        parsed_command = cli_parse_arguments(args);
    catch
        disp("Error parsing arguments: " + lasterror());
        return;
    end

    // For debugging: Display the parsed command structure
    // disp("Parsed Command Structure:");
    // disp(parsed_command);


    // 2. Execute the command based on the parser's output
    try
        cli_execute_command(parsed_command);
    catch
        disp("Error executing command: " + lasterror());
        return;
    end

endfunction
