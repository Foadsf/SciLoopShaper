function main_gui()
    // Creates the main SciLoopShaper GUI window and layout

    // Prevent potential re-execution issues if already open
    h = findobj("figure_name", "SciLoopShaper");
    if ~isempty(h) then
        disp("SciLoopShaper window already open. Closing existing one.");
        delete(h); // or close(h);
    end

    // Initialize global data structure to store application state
    global app;
    if ~isdef('app','l') | typeof(app) <> "struct" then // Initialize if not exists
        app = struct();
        app.plant = [];             // Current plant model (syslin or FRD struct)
        app.controllers = list();   // List containing controller definition lists (list of lists of block structs)
        app.activeController = 1;   // Currently active controller (1, 2, or 3)
        app.showController = [%T, %F, %F]; // Which controllers to display
        app.freq = struct('min', 0.1, 'max', 1000, 'points', 2000); // Frequency range defaults
        app.sampleTime = 0.001;     // Default sample time
        app.showDiscrete = %F;      // Show discrete controller flag
        app.plotType = 'bode';      // Current plot type (bode, nyquist, nichols, time)
        app.handles = struct();     // Sub-struct to store GUI element handles
    end

    // --- Main Figure Creation ---
    fig = figure(); // Create a new figure window
    app.handles.fig = fig; // Store figure handle

    // Set figure properties
    fig.figure_name     = 'SciLoopShaper';
    fig.figure_position = [100, 100]; // Just position, not size
    fig.figure_size     = [950, 700]; // Size as separate property
    fig.dockable        = 'off';
    fig.infobar_visible = 'off';
    fig.toolbar_visible = 'off'; // Disable default toolbar
    fig.menubar_visible = 'off'; // Disable default menubar
    fig.default_axes    = 'off'; // Don't create default axes automatically
    fig.resize          = 'on';  // Allow resizing

    // Set main layout: Border allows North/South/East/West/Center placement
    fig.layout          = 'border';
    // Optional padding between regions [width, height]
    // fig.layout_options = createLayoutOptions("border", [5, 5]);

    // --- Create Main Panels (Frames) ---

    // Left Panel (for Controls)
    // Takes a fixed width on the left, fills vertically
    cLeft = createConstraints("border", "left", [350, 0]); // Width=350
    hLeftPanel = uicontrol(fig, 'style', 'frame', ...
                           'constraints', cLeft, ...
                           'backgroundcolor', [0.9 0.9 0.9], ... // Light gray
                           'layout', 'gridbag'); // Use gridbag for contents
    app.handles.leftPanel = hLeftPanel;

    // Right Panel (for Plots)
    // Takes the remaining central space
    cRight = createConstraints("border", "center");
    hRightPanel = uicontrol(fig, 'style', 'frame', ...
                            'constraints', cRight, ...
                            'backgroundcolor', [0.85 0.85 0.85], ... // Slightly darker gray
                            'layout', 'gridbag'); // Use gridbag for contents
    app.handles.rightPanel = hRightPanel;

    // --- Create Sub-Panels within Left Panel ---
    // Plant Panel (Top)
    cPlant = createConstraints("gridbag", [1, 1, 1, 1], [1, 0.3], "both"); // Grid 1,1 ; Weight Y=0.3; Fill both
    hPlantFrame = uicontrol(hLeftPanel, 'style', 'frame', ...
                             'constraints', cPlant, ...
                             'border', createBorder("titled", createBorder("line", "lightGray", 1), "PLANT", "left", "above_top"), ...
                             'layout', 'gridbag'); // Gridbag for controls inside
    app.handles.plantFrame = hPlantFrame;

    // Controller Panel (Middle)
    cCtrl = createConstraints("gridbag", [1, 2, 1, 1], [1, 0.5], "both"); // Grid 1,2 ; Weight Y=0.5; Fill both
    hCtrlFrame = uicontrol(hLeftPanel, 'style', 'frame', ...
                            'constraints', cCtrl, ...
                            'border', createBorder("titled", createBorder("line", "lightGray", 1), "CONTROLLER", "left", "above_top"), ...
                            'layout', 'gridbag');
    app.handles.ctrlFrame = hCtrlFrame;

    // Performance Panel (Bottom)
    cPerf = createConstraints("gridbag", [1, 3, 1, 1], [1, 0.2], "both"); // Grid 1,3 ; Weight Y=0.2; Fill both
    hPerfFrame = uicontrol(hLeftPanel, 'style', 'frame', ...
                           'constraints', cPerf, ...
                           'border', createBorder("titled", createBorder("line", "lightGray", 1), "PERFORMANCE", "left", "above_top"), ...
                           'layout', 'gridbag');
    app.handles.perfFrame = hPerfFrame;

    // --- Create Sub-Panels within Right Panel ---
    // Frequency Response Panel (Top)
    cFreq = createConstraints("gridbag", [1, 1, 1, 1], [1, 0.65], "both"); // Grid 1,1 ; Weight Y=0.65; Fill both
    hFreqFrame = uicontrol(hRightPanel, 'style', 'frame', ...
                            'constraints', cFreq, ...
                            'border', createBorder("titled", createBorder("line", "lightGray", 1), "FREQUENCY RESPONSE", "left", "above_top"), ...
                            'layout', 'gridbag');
    app.handles.freqFrame = hFreqFrame;

    // Time Response Panel (Bottom)
    cTime = createConstraints("gridbag", [1, 2, 1, 1], [1, 0.35], "both"); // Grid 1,2 ; Weight Y=0.35; Fill both
    hTimeFrame = uicontrol(hRightPanel, 'style', 'frame', ...
                           'constraints', cTime, ...
                           'border', createBorder("titled", createBorder("line", "lightGray", 1), "TIME RESPONSE", "left", "above_top"), ...
                           'layout', 'gridbag');
    app.handles.timeFrame = hTimeFrame;

    // --- Create Plot Axes ---
    // Inside Frequency Panel
    cAxMag = createConstraints("gridbag", [1, 1, 1, 1], [1, 1], "both"); // Fill cell 1,1
    axMag = newaxes(hFreqFrame); // Create axes with freqFrame as parent
    axMag.axes_bounds = [0.1, 0.1, 0.85, 0.85]; // Relative position within parent (adjust as needed)
    axMag.margins = [0.1, 0.1, 0.1, 0.1]; // Margins within the axes bounds
    axMag.constraints = cAxMag; // Apply gridbag constraints
    axMag.visible = "on";
    axMag.y_label.text = "Magnitude [dB]";
    axMag.x_label.text = "Frequency [Hz]"; // Initially hidden by lower plot
    axMag.grid = [color("lightGray") color("lightGray")]; // Set grid color
    app.handles.axMag = axMag; // Store handle

    cAxPhase = createConstraints("gridbag", [1, 2, 1, 1], [1, 1], "both"); // Fill cell 1,2
    axPhase = newaxes(hFreqFrame);
    axPhase.axes_bounds = [0.1, 0.1, 0.85, 0.85];
    axPhase.margins = [0.1, 0.1, 0.1, 0.1];
    axPhase.constraints = cAxPhase;
    axPhase.visible = "on";
    axPhase.y_label.text = "Phase [deg]";
    axPhase.x_label.text = "Frequency [Hz]";
    axPhase.grid = [color("lightGray") color("lightGray")];
    app.handles.axPhase = axPhase;

    // Inside Time Panel
    cAxTime = createConstraints("gridbag", [1, 1, 1, 1], [1, 1], "both"); // Fill cell 1,1
    axTime = newaxes(hTimeFrame);
    axTime.axes_bounds = [0.1, 0.1, 0.85, 0.85];
    axTime.margins = [0.1, 0.1, 0.1, 0.1];
    axTime.constraints = cAxTime;
    axTime.visible = "on";
    axTime.y_label.text = "Output";
    axTime.x_label.text = "Time [s]";
    axTime.grid = [color("lightGray") color("lightGray")];
    app.handles.axTime = axTime;

    // --- Populate Panels with Controls (Example for Plant Panel) ---
    // This part will involve calling functions like createPlantPanel defined below
    // or directly placing controls here. Let's add the example popup now.
    createPlantPanelControls(app.handles.plantFrame); // Call function to add controls

    // --- Make the main figure visible ---
    fig.visible = 'on';
    disp("SciLoopShaper GUI created.");
endfunction

// --- Placeholder/Implementation functions for populating panels ---
// These will be filled in detail later or moved to separate files

function createPlantPanelControls(parentHandle)
    // Adds controls to the Plant panel frame
    disp("Populating Plant Panel..."); // Debug

    // Define grid constraints for controls within this panel
    cLabelEx = createConstraints("gridbag", [1, 1, 1, 1], [0, 0], "none", "right", [2 2]);
    cPopupEx = createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "left", [2 2]);
    cBtnWs   = createConstraints("gridbag", [1, 2, 1, 1], [0, 0], "horizontal", "center", [2 2]);
    cBtnFile = createConstraints("gridbag", [2, 2, 1, 1], [0, 0], "horizontal", "center", [2 2]);

    cLabelMin = createConstraints("gridbag", [1, 3, 1, 1], [0, 0], "none", "right", [2 2]);
    cEditMin  = createConstraints("gridbag", [2, 3, 1, 1], [1, 0], "horizontal", "left", [2 2]);
    cLabelMax = createConstraints("gridbag", [1, 4, 1, 1], [0, 0], "none", "right", [2 2]);
    cEditMax  = createConstraints("gridbag", [2, 4, 1, 1], [1, 0], "horizontal", "left", [2 2]);
    cLabelPts = createConstraints("gridbag", [1, 5, 1, 1], [0, 0], "none", "right", [2 2]);
    cEditPts  = createConstraints("gridbag", [2, 5, 1, 1], [1, 0], "horizontal", "left", [2 2]);

    global app; // Access global app structure for defaults

    // Example Plant Selection
    uicontrol(parentHandle, 'style', 'text', 'string', 'Example:', 'constraints', cLabelEx, 'horizontalalignment', 'right');
    hPlantEx = uicontrol(parentHandle, 'style', 'popupmenu', ...
                         'string', '-- examples --|mass|2 mass collocated|2 mass non-collocated', ...
                         'Tag', 'plantExamplesPopup', ...
                         'callback', 'handle_plant_selection()', ... // Connect to callback
                         'constraints', cPopupEx);
    app.handles.plantPopup = hPlantEx; // Store handle if needed later

    // Workspace/File Buttons
    hPlantWs = uicontrol(parentHandle, 'style', 'pushbutton', 'string', 'From Workspace', 'Tag', 'plantWsButton', 'constraints', cBtnWs, 'callback', 'handle_load_plant_ws()');
    hPlantFile = uicontrol(parentHandle, 'style', 'pushbutton', 'string', 'From File', 'Tag', 'plantFileButton', 'constraints', cBtnFile);
    app.handles.plantWsBtn = hPlantWs;
    app.handles.plantFileBtn = hPlantFile;

    // Frequency Range Inputs
    uicontrol(parentHandle, 'style', 'text', 'string', 'Freq Min [Hz]:', 'constraints', cLabelMin, 'horizontalalignment', 'right');
    hFmin = uicontrol(parentHandle, 'style', 'edit', 'string', string(app.freq.min), 'Tag', 'freqMinEdit', 'constraints', cEditMin, 'callback', 'handle_freq_change()');
    app.handles.freqMinEdit = hFmin;

    uicontrol(parentHandle, 'style', 'text', 'string', 'Freq Max [Hz]:', 'constraints', cLabelMax, 'horizontalalignment', 'right');
    hFmax = uicontrol(parentHandle, 'style', 'edit', 'string', string(app.freq.max), 'Tag', 'freqMaxEdit', 'constraints', cEditMax, 'callback', 'handle_freq_change()');
     app.handles.freqMaxEdit = hFmax;

    uicontrol(parentHandle, 'style', 'text', 'string', 'Points:', 'constraints', cLabelPts, 'horizontalalignment', 'right');
    hFpts = uicontrol(parentHandle, 'style', 'edit', 'string', string(app.freq.points), 'Tag', 'freqPointsEdit', 'constraints', cEditPts, 'callback', 'handle_freq_change()');
     app.handles.freqPointsEdit = hFpts;
endfunction

function createControllerPanelControls(parentHandle)
    // Placeholder: Add controls for controller section
    disp("Populating Controller Panel... (TBD)");
     uicontrol(parentHandle, 'style','text', 'string','Controller Controls Placeholder');
endfunction

function createPerformancePanelControls(parentHandle)
    // Placeholder: Add controls/text for performance section
    disp("Populating Performance Panel... (TBD)");
     uicontrol(parentHandle, 'style','text', 'string','Performance Display Placeholder');
endfunction

function createFrequencyResponsePanelControls(parentHandle)
    // Placeholder: Add radio buttons etc. for FRF selection
     disp("Populating FRF Panel... (TBD)");
     uicontrol(parentHandle, 'style','text', 'string','FRF Selection Placeholder');
endfunction

function createTimeResponsePanelControls(parentHandle)
    // Placeholder: Add radio buttons etc. for Time Resp selection
     disp("Populating Time Panel... (TBD)");
     uicontrol(parentHandle, 'style','text', 'string','Time Response Selection Placeholder');
endfunction
