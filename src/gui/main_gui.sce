function main_gui()
    // Create the main figure window
    // First, create the figure with a default state
    fig = figure();

    // Now, set the properties using the handle 'fig'
    fig.figure_name = 'SciLoopShaper';
    fig.figure_position = [100, 100, 900, 700];
    // fig.menubar = 'none'; // Menubar property might be set differently or unavailable
    // fig.toolbar = 'figure'; // Toolbar property might be set differently or managed via figure properties
    fig.dockable = 'off';
    fig.infobar_visible = 'off';
    // Background color needs to be set on the axes, not usually the figure itself,
    // or via figure entity properties if available. Let's skip for now.
    // fig.background = [0.9, 0.9, 0.9];

    // Initialize global data structure to store application state
    global app;
    app = struct();
    app.plant = [];
    app.controllers = list();
    app.activeController = 1;
    app.showController = [%T, %F, %F];
    app.freq = struct('min', 0.1, 'max', 1000, 'points', 2000);
    app.sampleTime = 0.001;
    app.showDiscrete = %F;
    app.plotType = 'bode';

    // --- Check available figure properties (optional debug) ---
    // disp(fig); // Display figure properties to see available names
    // ---

    // Create UI panels (These functions need implementation)
    // createPlantPanel(fig);
    // createControllerPanel(fig);
    // createFrequencyResponsePanel(fig);
    // createTimeResponsePanel(fig);
    // createPerformancePanel(fig);

    // Draw initial empty plots (This function needs implementation)
    // createEmptyPlots(fig);

    // Add logo (This function needs implementation)
    // createLogo(fig);
endfunction

// Function definitions for createPlantPanel, createControllerPanel, etc.
// need to be added below or in separate files and exec'd.
// For now, they are commented out.

function createPlantPanel(fig)
    // Placeholder
endfunction
function createControllerPanel(fig)
     // Placeholder
endfunction
function createFrequencyResponsePanel(fig)
     // Placeholder
endfunction
function createTimeResponsePanel(fig)
     // Placeholder
endfunction
function createPerformancePanel(fig)
     // Placeholder
endfunction
function createEmptyPlots(fig)
     // Placeholder
endfunction
