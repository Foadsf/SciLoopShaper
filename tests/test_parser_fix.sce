// Minimal test for parser error fix
clear;
mode(0);

disp("Testing parser error fix...");

try
    exec('src/cli/cli_parser.sce', 0);
    disp("✓ cli_parser.sce loaded successfully");

    // Test parser with simple input
    test_args = ["plant", "load-example", "mass"];

    result = cli_parse_arguments(test_args);
    disp("✓ Parser executed without error");
    disp("  Command: " + result.command);
    disp("  Subcommand: " + result.subcommand);

catch
    disp("✗ Parser error: " + lasterror());
end
