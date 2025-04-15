function handle_plant_selection(plant_type)
    // Handle plant selection from dropdown
    global app;

    if plant_type == "from workspace" then
        // Show dialog to select variable from workspace
        // TBD: Implement workspace variable selection
    elseif plant_type == "from file" then
        // Show file selection dialog
        // TBD: Implement file loading
    else
        // Create example plant
        app.plant = create_example_plant(plant_type);

        // Update plots
        update_plots();
    end
endfunction

function handle_controller_block_add(block_type)
    // Add a new controller block
    global app;

    // Create default parameters for the block
    select block_type
    case "Gain" then
        params = struct('gain', 1);
    case "Integrator" then
        params = struct('gain', 1);
    case "Lead/lag" then
        params = struct('gain', 1, 'zeros', 10, 'poles', 100);
    // TBD: Add other controller types
    else
        error("Unknown block type: " + block_type);
    end

    // Create the block
    block = create_controller_block(block_type, params);

    // Add to the active controller
    if length(app.controllers) < app.activeController then
        // Create empty list for this controller
        for i = length(app.controllers)+1:app.activeController
            app.controllers(i) = list();
        end
    end

    // Add the block to the active controller
    app.controllers(app.activeController)($+1) = block;

    // Update controller list display
    update_controller_list();

    // Update plots
    update_plots();
endfunction

function handle_controller_block_remove()
    // Remove the selected controller block
    global app;

    // Get the selected block index
    selected = get_selected_controller_block();

    if selected > 0 && selected <= length(app.controllers(app.activeController)) then
        // Remove the block
        app.controllers(app.activeController)(selected) = null();

        // Update controller list display
        update_controller_list();

        // Update plots
        update_plots();
    end
endfunction

function handle_controller_parameter_change(block_index, param_name, param_value)
    // Update a controller block parameter
    global app;

    if block_index > 0 && block_index <= length(app.controllers(app.activeController)) then
        // Get the block
        block = app.controllers(app.activeController)(block_index);

        // Update the parameter
        block.params(param_name) = param_value;

        // Recreate the block with new parameters
        block = create_controller_block(block.type, block.params);

        // Update the block in the controller
        app.controllers(app.activeController)(block_index) = block;

        // Update plots
        update_plots();
    end
endfunction

function update_plots()
    // Update all plots based on current state
    global app;

    // Clear plots
    clf();

    // TBD: Implement actual plotting based on app.plotType
    // (bode, nyquist, nichols, time response)
endfunction
