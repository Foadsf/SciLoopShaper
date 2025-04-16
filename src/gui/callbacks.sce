// File: src/gui/callbacks.sce
// SciLoopShaper - GUI Callback Functions
// Released under GPL - see LICENSE file for details

// Declare ALL globals needed by the callback functions
global app;
global ghAxMag ghAxPhase ghAxTime; // Handles stored separately

function handle_plant_selection()
    global app; // Ensure access to global app state
    global ghAxMag ghAxPhase ghAxTime; // Ensure access to global axes handles
    disp("Callback: handle_plant_selection triggered."); // Debug

    try
        // Find the popup menu handle using its Tag
        h = findobj('Tag', 'plantExamplesPopup');
        if isempty(h) then // Use isempty for checking findobj result
            error("Could not find plantExamplesPopup handle.");
        end

        // Get selected index and the list of strings
        idx = get(h, 'value');
        strList = get(h, 'string');

        // Handle the string list properly
        items = []; // Initialize
        if type(strList) == 10 then // It's a string or string matrix
            if size(strList, '*') == 1 then // Single string with delimiters
                items = tokens(strList, '|');
            else // Already a vector/matrix of strings
                items = matrix(strList, -1, 1); // Ensure it's a column vector
            end
        else
            error("Unexpected type for popup menu string list");
        end
        disp("Popup Items:"); disp(items);
        disp("Selected Index: " + string(idx));

        if idx > 1 & idx <= size(items, '*') then // Index 1 is placeholder, check upper bound
            selectedName = items(idx);
            disp("Selected example plant: " + string(selectedName));

            // Create the plant model
            // Ensure create_example_plant is loaded (main.sce should handle this)
            if ~exists('create_example_plant') then error("Function create_example_plant not loaded!"); end
            app.plant = create_example_plant(selectedName);
            disp("Plant model created/updated.");

        else
            // User selected the "-- examples --" placeholder or index out of bounds
            disp("No valid example plant selected.");
            app.plant = []; // Clear the current plant
        end

        // Update the plots regardless of selection
        update_plots();

    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error in handle_plant_selection:");
        disp(lasterror());
        // messagebox might interfere with GUI updates, use console msg for now
        disp("Error loading example plant: " + lasterror());
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end

endfunction

function handle_freq_change()
    global app; // Ensure access to global app state
    global ghAxMag ghAxPhase ghAxTime; // Ensure access to global axes handles
    disp("Callback: handle_freq_change triggered."); // Debug
    needs_update = %F; // Flag to replot only if values change and are valid
    current_min = app.freq.min; // Store initial values for comparison
    current_max = app.freq.max;
    current_pts = app.freq.points;

    try
        valid_min = %F; valid_max = %F; valid_pts = %F;
        new_min = current_min; new_max = current_max; new_pts = current_pts;

        // --- Get Min Frequency ---
        hMin = findobj('Tag', 'freqMinEdit');
        if ~isempty(hMin) then
            minStr = get(hMin, 'string');
            minVal = evstr(minStr);
            // Validation (must be number > 0)
            if typeof(minVal) == 1 & size(minVal,"*")==1 & minVal > 0 then
                new_min = minVal;
                valid_min = %T;
                set(hMin, 'foregroundcolor', [0 0 0]); // Black text for potentially valid
            else
                set(hMin, 'foregroundcolor', [1 0 0]); // Red text for invalid syntax/type
                disp("Invalid Min Frequency value entered (syntax/type).");
            end
        end

        // --- Get Max Frequency ---
        hMax = findobj('Tag', 'freqMaxEdit');
        if ~isempty(hMax) then
            maxStr = get(hMax, 'string');
            maxVal = evstr(maxStr);
            // Validation (must be number > 0)
            if typeof(maxVal) == 1 & size(maxVal,"*")==1 & maxVal > 0 then
                 new_max = maxVal;
                 valid_max = %T;
                 set(hMax, 'foregroundcolor', [0 0 0]);
            else
                set(hMax, 'foregroundcolor', [1 0 0]);
                disp("Invalid Max Frequency value entered (syntax/type).");
            end
        end

        // --- Get Points ---
        hPts = findobj('Tag', 'freqPointsEdit');
        if ~isempty(hPts) then
            ptsStr = get(hPts, 'string');
            ptsVal = evstr(ptsStr);
            // Validation (ensure integer, positive, reasonable range)
            if typeof(ptsVal)==1 & size(ptsVal,"*")==1 & ptsVal > 0 & ptsVal == round(ptsVal) & ptsVal < 50000 then
                new_pts = ptsVal;
                valid_pts = %T;
                set(hPts, 'foregroundcolor', [0 0 0]);
            else
                set(hPts, 'foregroundcolor', [1 0 0]);
                disp("Invalid Points value entered (must be positive integer).");
            end
        end

        // --- Cross-Validation and Update ---
        if valid_min & valid_max & valid_pts then
            // Check min < max
            if new_min >= new_max then
                disp("Validation Error: Min Frequency must be less than Max Frequency.");
                // Optionally set both back to red
                if ishandle(hMin) then set(hMin, 'foregroundcolor', [1 0 0]); end
                if ishandle(hMax) then set(hMax, 'foregroundcolor', [1 0 0]); end
            else
                 // All valid, check if any value actually changed
                if app.freq.min <> new_min | app.freq.max <> new_max | app.freq.points <> new_pts then
                    app.freq.min = new_min;
                    app.freq.max = new_max;
                    app.freq.points = new_pts;
                    needs_update = %T;
                    disp("Frequency range updated.");
                end
                 // Set color back to black if valid but unchanged (user might just press Enter)
                if ishandle(hMin) then set(hMin, 'foregroundcolor', [0 0 0]); end
                if ishandle(hMax) then set(hMax, 'foregroundcolor', [0 0 0]); end
                if ishandle(hPts) then set(hPts, 'foregroundcolor', [0 0 0]); end
            end
        end


        // --- Update Plots if necessary ---
        if needs_update then
            disp("Calling update_plots() due to frequency change.");
            update_plots();
        end

    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error in handle_freq_change:");
        // This catch might grab errors from evstr if input is totally invalid
        disp(lasterror());
        // Maybe indicate which field had the error?
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end

endfunction


function update_plots()
    // Main function to update all plot areas based on current app state
    global app; // Need app for state
    global ghAxMag ghAxPhase ghAxTime; // Access handles directly
    disp("Callback: update_plots triggered.");

    // --- Get Handles ---
    axM = []; axP = []; axT = [];
    // Check if globals exist and retrieve handles
    if isdef('ghAxMag') then axM = ghAxMag; end
    if isdef('ghAxPhase') then axP = ghAxPhase; end
    if isdef('ghAxTime') then axT = ghAxTime; end

    // --- Update Frequency Domain Plot (Bode for now) ---
    // Check if axes handles seem valid using typeof
    if typeof(axM) == "handle" & typeof(axP) == "handle" then
        disp("Mag/Phase global axes handles seem valid (type check), attempting to update...");
        try
            // Clear previous plots using delete(children)
            if ~isempty(axM.children) then delete(axM.children); end
            if ~isempty(axP.children) then delete(axP.children); end
            disp("Successfully cleared freq axes content (if any).");

            // --- DEBUG: Simple plot test ---
            disp("Attempting simple plot on ghAxMag...");
            plot(ghAxMag, 1:10, (1:10).^2); // Simple parabola
            ghAxMag.title.text = "Simple Test Plot"; // Set title for test plot
            drawnow(); // Force redraw to see test plot
            disp("Simple plot attempted. Check GUI.");
            messagebox("Check if simple plot appeared on Magnitude Axes", "Debug Pause"); // Pause execution
            // --- End Debug Test ---

        catch
             disp("Warning: Error during axes clear or simple plot test: " + lasterror());
             // Decide if we should proceed or return
             // return;
        end

        // Check if a valid plant exists
        plant_exists_and_valid = %F; // Flag
        if isdef('app','l') & isfield(app,'plant') & ~isempty(app.plant) then
            disp("Type of app.plant: " + typeof(app.plant));
             if typeof(app.plant) == "rational" | typeof(app.plant) == "state-space" then // Allow SS too
                 plant_exists_and_valid = %T;
             end
        end

        // --- Clear the test plot before real plot ---
        try
            if typeof(axM)=="handle" & ~isempty(axM.children) then delete(axM.children); end
            if typeof(axP)=="handle" & ~isempty(axP.children) then delete(axP.children); end
             disp("Cleared test plot / axes before Bode plot.");
        catch
            disp("Warning: Error clearing axes before Bode plot: " + lasterror());
        end
        // -------------------------------------------


        if plant_exists_and_valid then
            disp("Plotting Bode for current plant...");
            try // Inner try for plot_bode call and subsequent actions
                 if ~exists('plot_bode') then error("Function plot_bode not loaded!"); end
                 // Pass global handles to plot_bode
                 plot_bode(app.plant, app.freq.min, app.freq.max, app.freq.points, 'b-', '', axM, axP);
                 disp("plot_bode call completed.");

                 // Set grid AFTER plotting
                 axM.grid = [color("lightGray") color("lightGray")];
                 axP.grid = [color("lightGray") color("lightGray")];

                 // Use property access for title
                 axM.title.text = "Plant Frequency Response";

                 drawnow(); // Force redraw after plot_bode
                 disp("Bode plot updated. Check GUI.");

            catch // Catch errors from plot_bode OR the subsequent lines (like xtitle)
                disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                disp("Error DURING/AFTER plot_bode call:"); // Clarify where error happens
                disp(lasterror());
                // Try setting error title, but guard with typeof check
                if typeof(axM)=="handle" then axM.title.text = "Error plotting Bode!"; drawnow(); end // Redraw after error title
                if typeof(axM)=="handle" then axM.grid = [color("lightGray") color("lightGray")]; end
                if typeof(axP)=="handle" then axP.grid = [color("lightGray") color("lightGray")]; end
                 disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            end
        else // No valid plant
            disp("No valid plant loaded, clearing Bode plot.");
             // Guard title and grid calls using typeof check
            if typeof(axM)=="handle" then
                axM.title.text = "No Plant Loaded"; // Use property access
                axM.grid = [color("lightGray") color("lightGray")];
                drawnow(); // Redraw
            end
            if typeof(axP)=="handle" then
                 axP.title.text = ""; // Clear title
                 axP.grid = [color("lightGray") color("lightGray")];
            end
        end
    else
        disp("Warning: Global Magnitude/Phase axes handles not found or invalid (type check failed) in update_plots.");
    end

    // --- Update Time Domain Plot ---
     // Use typeof() == "handle" check
     if isdef('axT') & typeof(axT) == "handle" then
         disp("Time axis handle seems valid (type check), clearing.");
         try
             if ~isempty(axT.children) then delete(axT.children); end // Check children before delete
             disp("Time plot cleared.");
             // Use property access for title
             axT.title.text = "Time Response (TBD)";
             axT.grid = [color("lightGray") color("lightGray")];
             drawnow(); // Force redraw
         catch
             disp("Warning: Error updating time plot: " + lasterror());
         end
     else
        disp("Warning: Global Time axis handle not found or invalid (type check failed) in update_plots.");
     end

endfunction // End of update_plots function


function handle_load_plant_ws()
    // Callback for the "From Workspace" button
    global app; // Ensure access to global app state
    global ghAxMag ghAxPhase ghAxTime; // Make sure handles are accessible if needed
    disp("Callback: handle_load_plant_ws triggered."); // Debug

    try
        // Ensure core function is loaded
        if ~exists('load_plant_from_workspace') then error("Function load_plant_from_workspace not loaded!"); end

        // Show input dialog to get variable name
        variableName = x_dialog("Enter the name of the plant variable in the Scilab workspace:", "");

        if variableName <> [] & variableName <> "" then
            disp("Loading plant from workspace: " + variableName);

            // Try to load the plant from workspace
            app.plant = load_plant_from_workspace(variableName);
            disp("Plant loaded from workspace.");

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
