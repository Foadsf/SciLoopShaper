// SciLoopShaper - GUI Callback Functions
// Released under GPL - see LICENSE file for details

function handle_plant_selection()
    // Callback for the plant examples popup menu
    disp("Callback: handle_plant_selection triggered."); // Debug
    global app; // Use the global application state

    try
        // Ensure the create_example_plant function is available
        if ~exists('create_example_plant') then
            disp("Loading plant functions...");
            // Directly execute the plant.sce file
            currentPath = get_absolute_file_path('callbacks.sce');
            plant_path = fullfile(currentPath, '..', 'core', 'plant.sce');
            if isfile(plant_path) then
                exec(plant_path, 0);
                disp("Plant functions loaded.");
            else
                error("Could not find plant.sce file at: " + plant_path);
            end
        end

        // Find the popup menu handle using its Tag
        h = findobj('Tag', 'plantExamplesPopup');
        if isempty(h) then
            error("Could not find plantExamplesPopup handle.");
        end

        // Get selected index and the list of strings
        idx = get(h, 'value');
        strList = get(h, 'string');

        // Debug info
        disp("Popup menu selected index: " + string(idx));
        disp("String list type: " + typeof(strList));
        disp("String list size: " + string(size(strList)));
        disp("String list content: ");
        disp(strList);

        // Handle the string list properly - it might be a vector or a single string with delimiters
        if type(strList) == 10 then // It's a string or string matrix
            if size(strList, '*') == 1 then // Single string with delimiters
                items = tokens(strList, '|'); // Split the string by '|'
                disp("Tokenized items:");
                disp(items);
            else // Already a vector of strings
                items = strList;
                disp("Using string vector directly:");
                disp(items);
            end
        else
            error("Unexpected type for popup menu string list");
        end

        if idx > 1 then // Index 1 is the "-- examples --" placeholder
            selectedName = items(idx);
            disp("Selected example plant: " + string(selectedName));

            // Create the plant model
            app.plant = create_example_plant(selectedName);
            disp("Plant model created/updated.");

            // Reset frequency range to defaults maybe? Or keep user values?
            // Let's keep user values for now unless plant explicitly loaded

        else
            // User selected the "-- examples --" placeholder or list is empty
            disp("No example plant selected.");
            app.plant = []; // Clear the current plant
        end

        // Update the plots regardless of selection
        update_plots();

    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error in handle_plant_selection:");
        disp(lasterror());
        // Use a simpler error notification since messagebox might cause issues
        disp("Error loading example plant: " + lasterror());
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end
endfunction

function handle_freq_change()
    // Callback for frequency range edit boxes
    disp("Callback: handle_freq_change triggered."); // Debug
    global app;
    needs_update = %F; // Flag to replot only if values change and are valid

    try
        // --- Get Min Frequency ---
        hMin = findobj('Tag', 'freqMinEdit');
        if ~isempty(hMin) then
            minStr = get(hMin, 'string');
            minVal = evstr(minStr); // Convert string to number
            // Validation
            if typeof(minVal) == 1 & size(minVal,"*")==1 & minVal > 0 & minVal < app.freq.max then
                if app.freq.min <> minVal then // Check if value actually changed
                    app.freq.min = minVal;
                    set(hMin, 'foregroundcolor', [0 0 0]); // Black text for valid
                     needs_update = %T;
                end
            else
                set(hMin, 'foregroundcolor', [1 0 0]); // Red text for invalid
                disp("Invalid Min Frequency value entered.");
            end
        end

        // --- Get Max Frequency ---
        hMax = findobj('Tag', 'freqMaxEdit');
        if ~isempty(hMax) then
            maxStr = get(hMax, 'string');
            maxVal = evstr(maxStr);
            // Validation
            if typeof(maxVal) == 1 & size(maxVal,"*")==1 & maxVal > 0 & maxVal > app.freq.min then
                 if app.freq.max <> maxVal then
                    app.freq.max = maxVal;
                    set(hMax, 'foregroundcolor', [0 0 0]);
                    needs_update = %T;
                end
            else
                set(hMax, 'foregroundcolor', [1 0 0]);
                 disp("Invalid Max Frequency value entered.");
            end
        end

        // --- Get Points ---
        hPts = findobj('Tag', 'freqPointsEdit');
        if ~isempty(hPts) then
            ptsStr = get(hPts, 'string');
            ptsVal = evstr(ptsStr);
            // Validation (ensure integer, positive, reasonable range)
            if typeof(ptsVal)==1 & size(ptsVal,"*")==1 & ptsVal > 0 & ptsVal == round(ptsVal) & ptsVal < 50000 then
                 if app.freq.points <> ptsVal then
                    app.freq.points = ptsVal;
                    set(hPts, 'foregroundcolor', [0 0 0]);
                     needs_update = %T;
                end
            else
                set(hPts, 'foregroundcolor', [1 0 0]);
                disp("Invalid Points value entered (must be positive integer).");
            end
        end

        // --- Update Plots if necessary ---
        if needs_update then
            disp("Frequency range updated. Calling update_plots().");
            update_plots();
        end

    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error in handle_freq_change:");
        disp(lasterror());
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end
endfunction

function update_plots()
    // Main function to update all plot areas based on current app state
    disp("Callback: update_plots triggered."); // Debug
    global app;

    // --- Get Handles ---
    // Check if handles exist and are valid before using them
    axM = []; axP = []; axT = [];
    if isdef('app.handles.axMag','l') then axM = app.handles.axMag; end
    if isdef('app.handles.axPhase','l') then axP = app.handles.axPhase; end
    if isdef('app.handles.axTime','l') then axT = app.handles.axTime; end

    // --- Update Frequency Domain Plot (Bode for now) ---
    if ~isempty(axM) & ~isempty(axP) then // Check if axes handles are valid
        // Clear previous plots on these specific axes
        cla(axM);
        cla(axP);

        // Check if a valid plant exists
        if isdef('app.plant','l') & ~isempty(app.plant) & typeof(app.plant) == "rational" then
            disp("Plotting Bode for current plant...");
            try
                // Call the modified plot_bode function, passing axes handles
                plot_bode(app.plant, app.freq.min, app.freq.max, app.freq.points, '-', 'b', axM, axP);

                // Try setting grid again AFTER plotting
                axM.grid = [color("lightGray") color("lightGray")];
                axP.grid = [color("lightGray") color("lightGray")];

                // Add title
                xtitle(axM, "Plant Frequency Response");

                disp("Bode plot updated.");
            catch
                disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                disp("Error calling plot_bode:");
                disp(lasterror());
                xtitle(axM, "Error plotting Bode!"); // Display error on plot
                axM.grid = [color("lightGray") color("lightGray")]; // Still add grid
                axP.grid = [color("lightGray") color("lightGray")];
                disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            end
        else
            disp("No valid plant loaded, clearing Bode plot.");
            // Optional: Add text to indicate no plot
            xtitle(axM, "No Plant Loaded");
            axM.grid = [color("lightGray") color("lightGray")]; // Still add grid
            axP.grid = [color("lightGray") color("lightGray")];
        end
    else
        disp("Warning: Magnitude/Phase axes handles not found or invalid.");
    end

    // --- Update Time Domain Plot (Placeholder for now) ---
     if ~isempty(axT) then // Check if axes handle is valid
         cla(axT); // Clear previous plot
         disp("Time plot cleared (implementation TBD).");
         xtitle(axT, "Time Response (TBD)");
         axT.grid = [color("lightGray") color("lightGray")];
     else
        disp("Warning: Time axis handle not found or invalid.");
     end
endfunction

function handle_load_plant_ws()
    // Callback for the "From Workspace" button
    disp("Callback: handle_load_plant_ws triggered."); // Debug
    global app;

    try
        // Show input dialog to get variable name
        variableName = x_dialog("Enter the name of the plant variable in the Scilab workspace:", "");

        if variableName <> [] & variableName <> "" then
            disp("Loading plant from workspace: " + variableName);

            // Try to load the plant from workspace
            app.plant = load_plant_from_workspace(variableName);

            // Update the plots
            update_plots();
        else
            disp("Load from workspace canceled.");
        end
    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error in handle_load_plant_ws:");
        disp(lasterror());
        messagebox("Error loading plant from workspace: " + lasterror(), "Load Error", "error");
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end
endfunction


// --- Add other callbacks below as needed ---
// function handle_load_plant_file() ... endfunction
// function handle_controller_add() ... endfunction
// function handle_controller_remove() ... endfunction
// function handle_controller_param_change() ... endfunction
// function handle_frf_plot_selection() ... endfunction
// function handle_time_plot_selection() ... endfunction
// function handle_save_controller() ... endfunction
// function handle_load_controller() ... endfunction
// etc.
