function plot_bode(sys, w_min, w_max, n_points, line_style, line_color, axMagHandle, axPhaseHandle)
    // Plot Bode diagram for the given system
    // Can optionally plot onto existing axes provided by axMagHandle and axPhaseHandle

    disp("plot_bode called with axes handles:");
    disp("axMagHandle type: " + typeof(axMagHandle));
    disp("axPhaseHandle type: " + typeof(axPhaseHandle));

    is_gui_mode = %F; // Flag to track if plotting to GUI axes
    if exists('axMagHandle','local') & exists('axPhaseHandle','local') then
        // Check if the provided arguments are valid handles
        if ~isempty(axMagHandle) & ~isempty(axPhaseHandle) then
            is_gui_mode = %T;
            disp("plot_bode: Plotting in GUI mode."); // Debug
        else
            disp("plot_bode: One or both axes handles are empty.");
        end
    else
        disp("plot_bode: Missing axes handle arguments.");
    end

    // Calculate frequency response
    [mag, phase_deg, w_hz] = calculate_frequency_response(sys, w_min, w_max, n_points);

    // Check if calculation returned valid data
    if isempty(mag) | isempty(phase_deg) | isempty(w_hz) then
        warning("calculate_frequency_response returned empty data. Cannot plot Bode.");
        // If in GUI mode, maybe display a message on the axes?
        if is_gui_mode then
            try
                xtitle(axMagHandle, "Frequency Response Calculation Failed");
                xtitle(axPhaseHandle, "");
            catch
                disp("Error setting title on axes: " + lasterror());
            end
        end
        return;
    end

    // Convert magnitude to dB
    epsilon = 1e-200; // Avoid log10(0)
    mag_db = 20*log10(mag + epsilon);

    // --- Plot Magnitude ---
    if is_gui_mode then
        try
            disp("Setting current axes to axMagHandle...");
            sca(axMagHandle); // Set current axes to the provided handle
            disp("Successfully set current axes");
        catch
            disp("Error setting current axes to axMagHandle: " + lasterror());
            is_gui_mode = %F; // Fall back to standard plotting
        end
    else
        disp("Creating new subplot for magnitude");
        subplot(2, 1, 1); // Create subplot in a new figure
    end

    try
        disp("Plotting magnitude data...");
        plot2d(w_hz, mag_db, style=color(line_color), logflag="ln"); // Use plot2d with logflag="ln" for semilogx
        disp("Successfully plotted magnitude data");
    catch
        disp("Error plotting magnitude data: " + lasterror());
    end

    // Set labels and title using handle properties if in GUI mode
    if is_gui_mode then
        try
            axMagHandle.x_label.text = ""; // X label only on bottom plot
            axMagHandle.y_label.text = "Magnitude [dB]";
            axMagHandle.title.text = "Bode Plot"; // Title on top plot only
            // axMagHandle.grid = [color("light gray") color("light gray")]; // Set grid from update_plots
            disp("Successfully set magnitude axes properties");
        catch
            disp("Error setting magnitude axes properties: " + lasterror());
        end
    else
        xlabel("Frequency [Hz]"); // Global labels for standalone figure
        ylabel("Magnitude [dB]");
        title("Bode Plot - Magnitude");
        xgrid(); // Use basic grid for standalone figure
    end

    // --- Plot Phase ---
    if is_gui_mode then
        try
            disp("Setting current axes to axPhaseHandle...");
            sca(axPhaseHandle); // Set current axes
            disp("Successfully set current axes to phase");
        catch
            disp("Error setting current axes to axPhaseHandle: " + lasterror());
            is_gui_mode = %F; // Fall back to standard plotting
        end
    else
        disp("Creating new subplot for phase");
        subplot(2, 1, 2);
    end

    try
        disp("Plotting phase data...");
        plot2d(w_hz, phase_deg, style=color(line_color), logflag="ln");
        disp("Successfully plotted phase data");
    catch
        disp("Error plotting phase data: " + lasterror());
    end

    if is_gui_mode then
        try
            axPhaseHandle.x_label.text = "Frequency [Hz]";
            axPhaseHandle.y_label.text = "Phase [deg]";
            axPhaseHandle.title.text = ""; // No title on phase plot
            // axPhaseHandle.grid = [color("light gray") color("light gray")]; // Set grid from update_plots
            disp("Successfully set phase axes properties");
        catch
            disp("Error setting phase axes properties: " + lasterror());
        end
    else
        xlabel("Frequency [Hz]");
        ylabel("Phase [deg]");
        title("Bode Plot - Phase");
        xgrid();
    end

    disp("plot_bode completed successfully");
endfunction

// --- Keep plot_nyquist and plot_nichols as they were for now ---
// They will need similar modifications later to accept axes handles

function plot_nyquist(sys, w_min, w_max, n_points, line_style, line_color)
    // Plot Nyquist diagram for the given system (ORIGINAL - New Figure)

    [frq, rep] = repfreq(sys, logspace(log10(w_min), log10(w_max), n_points) * 2 * %pi); // Ensure conversion to rad/s
    re = real(rep);
    im = imag(rep);

    // Plot Nyquist diagram
    plot(re, im, line_style, 'color', line_color);
    plot(-1, 0, 'ro');
    xlabel('Real');
    ylabel('Imaginary');
    title('Nyquist');   // Add title
    a = gca();          // Get current axes handle
    a.grid = [1 1];     // << Set grid LAST

endfunction

function plot_nichols(sys, w_min, w_max, n_points, line_style, line_color)
    // Plot Nichols chart for the given system (ORIGINAL - New Figure)

    [mag, phase_deg, w_hz] = calculate_frequency_response(sys, w_min, w_max, n_points);

    if isempty(mag) | isempty(phase_deg) | isempty(w_hz) then
        warning("calculate_frequency_response returned empty data. Cannot plot Nichols.");
        return;
    end

    epsilon = 1e-200;
    mag_db = 20*log10(mag + epsilon);

    // Plot Nichols chart
    plot(phase_deg, mag_db, line_style, 'color', line_color);
    xlabel('Phase [deg]');
    ylabel('Magnitude [dB]');
    title('Nichols');   // Add title
    a = gca();          // Get current axes handle
    a.grid = [1 1];     // << Set grid LAST

endfunction

disp("--- src/plots/bode_plots.sce finished execution. plot_bode should be defined. ---");
