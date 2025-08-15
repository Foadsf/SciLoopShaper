// Minimal test for syntax error fix
clear;
mode(0);

disp("Testing syntax error fix...");

try
    exec('src/core/controller.sce', 0);
    exec('src/core/plant.sce', 0);
    exec('src/core/analysis.sce', 0);
    exec('src/utils/utils.sce', 0);
    exec('src/cli/cli_parser.sce', 0);
    exec('src/cli/cli_output.sce', 0);
    exec('src/cli/cli_plot.sce', 0);
    exec('src/cli/cli_commands.sce', 0);
    disp("✓ cli_commands.sce loaded successfully");

    // Test if function exists
    if exists('handle_analyze_stability') then
        disp("✓ handle_analyze_stability function is defined");
    else
        disp("✗ handle_analyze_stability function not found");
    end

catch
    disp("✗ Still have syntax error: " + lasterror());
end
