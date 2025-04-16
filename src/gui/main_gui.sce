function main_gui()
    // Creates the main SciLoopShaper GUI window and layout

    // --- Declare Globals ---
    global app; // For state data
    global ghAxMag ghAxPhase ghAxTime; // Separate globals for critical axes handles

    // Initialize global app state (if needed) - keep previous logic
    app_initialized = %F; // Flag to track if we initialized it here
    try
        temp_app = getglobal('app');
        if typeof(temp_app) == "struct" then
            disp("Global app structure already exists.");
            app = temp_app;
            // Ensure handles SUB-STRUCT doesn't exist from previous runs if we aren't using it
            if isfield(app, 'handles') then
                 app = rmfield(app, 'handles'); // Remove old handles struct if present
            end
        else
            error("Global ''app'' exists but is not a struct. Re-initializing.");
        end
    catch
        disp("Initializing global app structure (without .handles)...");
        app = struct();
        app.plant = [];
        app.controllers = list();
        app.activeController = 1;
        app.showController = [%T, %F, %F];
        app.freq = struct('min', 0.1, 'max', 1000, 'points', 2000);
        app.sampleTime = 0.001;
        app.showDiscrete = %F;
        app.plotType = 'bode';
        // app.handles = struct(); // << DO NOT Initialize handles sub-struct
        app_initialized = %T;
    end
    // --- End Initialization ---


    // Prevent re-execution issues (using tag is probably best)
    h = findobj("Tag", "SciLoopShaper_mainFig");
    if ~isempty(h) then
        disp("SciLoopShaper window tag found. Closing existing one.");
        delete(h);
    end


    // --- Main Figure Creation ---
    fig = figure();
    fig.tag = "SciLoopShaper_mainFig"; // Use tag for finding later

    // Set figure properties (use 'fig' handle)
    fig.figure_name     = 'SciLoopShaper';
    fig.figure_position = [100, 100];
    fig.figure_size     = [950, 700];
    fig.dockable        = 'off';
    fig.infobar_visible = 'off';
    fig.toolbar_visible = 'off';
    fig.menubar_visible = 'off';
    fig.default_axes    = 'off';
    fig.resize          = 'on';

    // Set main layout: Border
    fig.layout          = 'border';
    // fig.layout_options = createLayoutOptions("border", [5, 5]); // Optional padding

    // --- Create Main Panels (Frames) ---
    // Store handles locally if needed or maybe in app struct if non-axes handles are safe
    cLeft = createConstraints("border", "left", [350, 0]);
    hLeftPanel = uicontrol(fig, 'style', 'frame', 'constraints', cLeft, 'backgroundcolor', [0.9 0.9 0.9], 'layout', 'gridbag');

    cRight = createConstraints("border", "center");
    hRightPanel = uicontrol(fig, 'style', 'frame', 'constraints', cRight, 'backgroundcolor', [0.85 0.85 0.85], 'layout', 'gridbag');

    // --- Create Sub-Panels within Left Panel ---
    cPlant = createConstraints("gridbag", [1, 1, 1, 1], [1, 0.3], "both");
    hPlantFrame = uicontrol(hLeftPanel, 'style', 'frame', 'constraints', cPlant, 'border', createBorder("titled", createBorder("line", "lightGray", 1), "PLANT", "left", "above_top"), 'layout', 'gridbag');

    cCtrl = createConstraints("gridbag", [1, 2, 1, 1], [1, 0.5], "both");
    hCtrlFrame = uicontrol(hLeftPanel, 'style', 'frame', 'constraints', cCtrl, 'border', createBorder("titled", createBorder("line", "lightGray", 1), "CONTROLLER", "left", "above_top"), 'layout', 'gridbag');

    cPerf = createConstraints("gridbag", [1, 3, 1, 1], [1, 0.2], "both");
    hPerfFrame = uicontrol(hLeftPanel, 'style', 'frame', 'constraints', cPerf, 'border', createBorder("titled", createBorder("line", "lightGray", 1), "PERFORMANCE", "left", "above_top"), 'layout', 'gridbag');

    // --- Create Sub-Panels within Right Panel ---
    cFreq = createConstraints("gridbag", [1, 1, 1, 1], [1, 0.65], "both");
    hFreqFrame = uicontrol(hRightPanel, 'style', 'frame', 'constraints', cFreq, 'border', createBorder("titled", createBorder("line", "lightGray", 1), "FREQUENCY RESPONSE", "left", "above_top"), 'layout', 'gridbag');

    cTime = createConstraints("gridbag", [1, 2, 1, 1], [1, 0.35], "both");
    hTimeFrame = uicontrol(hRightPanel, 'style', 'frame', 'constraints', cTime, 'border', createBorder("titled", createBorder("line", "lightGray", 1), "TIME RESPONSE", "left", "above_top"), 'layout', 'gridbag');

    // --- Create Plot Axes and assign to SEPARATE GLOBALS ---
    cAxMag = createConstraints("gridbag", [1, 1, 1, 1], [1, 1], "both");
    ghAxMag = newaxes(hFreqFrame); // Assign to global ghAxMag
    ghAxMag.tag = "bode_mag_axes";
    ghAxMag.constraints = cAxMag;
    ghAxMag.axes_bounds = [0.1, 0.1, 0.85, 0.8]; // Adjust bounds slightly
    ghAxMag.margins = [0.12, 0.1, 0.1, 0.1];
    ghAxMag.visible = "on";
    ghAxMag.y_label.text = "Magnitude [dB]";
    // ghAxMag.x_label.text = "Frequency [Hz]"; // Label on bottom plot
    ghAxMag.grid = [color("lightGray") color("lightGray")];
    ghAxMag.auto_clear = "off"; // Prevent auto clear if needed
    disp("Created Magnitude axes (global ghAxMag).");

    cAxPhase = createConstraints("gridbag", [1, 2, 1, 1], [1, 1], "both");
    ghAxPhase = newaxes(hFreqFrame); // Assign to global ghAxPhase
    ghAxPhase.tag = "bode_phase_axes";
    ghAxPhase.constraints = cAxPhase;
    ghAxPhase.axes_bounds = [0.1, 0.1, 0.85, 0.8];
    ghAxPhase.margins = [0.12, 0.1, 0.1, 0.1];
    ghAxPhase.visible = "on";
    ghAxPhase.y_label.text = "Phase [deg]";
    ghAxPhase.x_label.text = "Frequency [Hz]";
    ghAxPhase.grid = [color("lightGray") color("lightGray")];
     ghAxPhase.auto_clear = "off";
    disp("Created Phase axes (global ghAxPhase).");

    cAxTime = createConstraints("gridbag", [1, 1, 1, 1], [1, 1], "both");
    ghAxTime = newaxes(hTimeFrame); // Assign to global ghAxTime
    ghAxTime.tag = "time_response_axes";
    ghAxTime.constraints = cAxTime;
    ghAxTime.axes_bounds = [0.1, 0.1, 0.85, 0.8];
    ghAxTime.margins = [0.12, 0.1, 0.1, 0.1];
    ghAxTime.visible = "on";
    ghAxTime.y_label.text = "Output";
    ghAxTime.x_label.text = "Time [s]";
    ghAxTime.grid = [color("lightGray") color("lightGray")];
     ghAxTime.auto_clear = "off";
    disp("Created Time axes (global ghAxTime).");

    // --- Populate Panels with Controls ---
    createPlantPanelControls(hPlantFrame); // Pass local handle to parent frame
    // Call other panel population functions (still placeholders)
    createControllerPanelControls(hCtrlFrame);
    createPerformancePanelControls(hPerfFrame);
    // createFrequencyResponsePanelControls(hFreqFrame);
    // createTimeResponsePanelControls(hTimeFrame);


    // --- Make the main figure visible LAST ---
    fig.visible = 'on';
    disp("SciLoopShaper GUI created and visible.");

endfunction


// --- Implementation function for populating Plant panel ---
function createPlantPanelControls(parentHandle)
    // Adds controls to the Plant panel frame
    disp("Populating Plant Panel..."); // Debug

    // Define grid constraints specific to this panel's gridbag layout
    // createConstraints("gridbag", grid, weight, fill, anchor, padding)

    // Row 1: Example Label + Popup
    cLabelEx = createConstraints("gridbag", [1, 1, 1, 1], [0, 0], "none", "right", [0 0]);
    cPopupEx = createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "left", [0 0]);

    // Row 2: Buttons
    cBtnWs   = createConstraints("gridbag", [1, 2, 1, 1], [0.5, 0], "horizontal", "left", [0 0]);
    cBtnFile = createConstraints("gridbag", [2, 2, 1, 1], [0.5, 0], "horizontal", "left", [0 0]);

    // Row 3: Freq Min
    cLabelMin = createConstraints("gridbag", [1, 3, 1, 1], [0, 0], "none", "right", [0 0]);
    cEditMin  = createConstraints("gridbag", [2, 3, 1, 1], [1, 0], "horizontal", "left", [0 0]);

    // Row 4: Freq Max
    cLabelMax = createConstraints("gridbag", [1, 4, 1, 1], [0, 0], "none", "right", [0 0]);
    cEditMax  = createConstraints("gridbag", [2, 4, 1, 1], [1, 0], "horizontal", "left", [0 0]);

    // Row 5: Points
    cLabelPts = createConstraints("gridbag", [1, 5, 1, 1], [0, 0], "none", "right", [0 0]);
    cEditPts  = createConstraints("gridbag", [2, 5, 1, 1], [1, 0], "horizontal", "left", [0 0]);

    global app; // Access global app structure for default freq values

    // Create uicontrols using these constraints...
    uicontrol(parentHandle, 'style', 'text', 'string', 'Example:', 'constraints', cLabelEx, 'horizontalalignment', 'right');
    uicontrol(parentHandle, 'style', 'popupmenu', ...
                         'string', '-- examples --|mass|2 mass collocated|2 mass non-collocated', ...
                         'Tag', 'plantExamplesPopup', ...
                         'callback', 'handle_plant_selection()', ...
                         'constraints', cPopupEx);
    uicontrol(parentHandle, 'style', 'pushbutton', 'string', 'From Workspace', 'Tag', 'plantWsButton', 'constraints', cBtnWs, 'callback', 'handle_load_plant_ws()');
    uicontrol(parentHandle, 'style', 'pushbutton', 'string', 'From File', 'Tag', 'plantFileButton', 'constraints', cBtnFile);
    uicontrol(parentHandle, 'style', 'text', 'string', 'Freq Min [Hz]:', 'constraints', cLabelMin, 'horizontalalignment', 'right');
    uicontrol(parentHandle, 'style', 'edit', 'string', string(app.freq.min), 'Tag', 'freqMinEdit', 'constraints', cEditMin, 'callback', 'handle_freq_change()');
    uicontrol(parentHandle, 'style', 'text', 'string', 'Freq Max [Hz]:', 'constraints', cLabelMax, 'horizontalalignment', 'right');
    uicontrol(parentHandle, 'style', 'edit', 'string', string(app.freq.max), 'Tag', 'freqMaxEdit', 'constraints', cEditMax, 'callback', 'handle_freq_change()');
    uicontrol(parentHandle, 'style', 'text', 'string', 'Points:', 'constraints', cLabelPts, 'horizontalalignment', 'right');
    uicontrol(parentHandle, 'style', 'edit', 'string', string(app.freq.points), 'Tag', 'freqPointsEdit', 'constraints', cEditPts, 'callback', 'handle_freq_change()');

endfunction


// --- Placeholder functions for populating other panels ---
function createControllerPanelControls(parentHandle)
    disp("Populating Controller Panel... (TBD)");
     uicontrol(parentHandle, 'style','text', 'string','Controller Controls Placeholder', 'constraints', createConstraints("gridbag", [1,1,1,1],[1,1],"both"));
endfunction

function createPerformancePanelControls(parentHandle)
    disp("Populating Performance Panel... (TBD)");
     uicontrol(parentHandle, 'style','text', 'string','Performance Display Placeholder', 'constraints', createConstraints("gridbag", [1,1,1,1],[1,1],"both"));
endfunction
// No controls needed yet for Freq/Time panels, only axes
// function createFrequencyResponsePanelControls(parentHandle) ... endfunction
// function createTimeResponsePanelControls(parentHandle) ... endfunction
