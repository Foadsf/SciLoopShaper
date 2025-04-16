function plot_bode(sys, w_min, w_max, n_points, line_style, line_color, axMagHandle, axPhaseHandle)
    // Plot Bode diagram for the given system
    // Can optionally plot onto existing axes provided by axMagHandle and axPhaseHandle

    is_gui_mode = %F; // Flag to track if plotting to GUI axes
    if isdef('axMagHandle','l') & ishandle(axMagHandle) & isdef('axPhaseHandle','l') & ishandle(axPhaseHandle) then
        // Check if the provided arguments are valid graphics handles
        if typeof(axMagHandle) == "handle" & typeof(axPhaseHandle) == "handle" then
             if axMagHandle.type == "Axes" & axPhaseHandle.type == "Axes" then
                 is_gui_mode = %T;
                 disp("plot_bode: Plotting in GUI mode."); // Debug
             end
        end
    end

    // Calculate frequency response
    [mag, phase_deg, w_hz] = calculate_frequency_response(sys, w_min, w_max, n_points);

    // Check if calculation returned valid data
    if isempty(mag) | isempty(phase_deg) | isempty(w_hz) then
        warning("calculate_frequency_response returned empty data. Cannot plot Bode.");
        // If in GUI mode, maybe display a message on the axes?
        if is_gui_mode then
            xtitle(axMagHandle, "Frequency Response Calculation Failed");
            xtitle(axPhaseHandle, "");
        end
        return;
    end

    // Convert magnitude to dB
    epsilon = 1e-200; // Avoid log10(0)
    mag_db = 20*log10(mag + epsilon);

    // --- Plot Magnitude ---
    if is_gui_mode then
        sca(axMagHandle); // Set current axes to the provided handle
    else
        subplot(2, 1, 1); // Create subplot in a new figure
    end
    plot2d(w_hz, mag_db, style=color(line_color), logflag="ln"); // Use plot2d with logflag="ln" for semilogx
    // Handling potential invalid data in plot2d might require checks or try/catch

    // Set labels and title using handle properties if in GUI mode
    if is_gui_mode then
        axMagHandle.x_label.text = ""; // X label only on bottom plot
        axMagHandle.y_label.text = "Magnitude [dB]";
        axMagHandle.title.text = "Bode Plot"; // Title on top plot only
        // axMagHandle.grid = [color("light gray") color("light gray")]; // Set grid from update_plots
    else
        xlabel("Frequency [Hz]"); // Global labels for standalone figure
        ylabel("Magnitude [dB]");
        title("Bode Plot - Magnitude");
        xgrid(); // Use basic grid for standalone figure
    end

    // --- Plot Phase ---
    if is_gui_mode then
        sca(axPhaseHandle); // Set current axes
    else
        subplot(2, 1, 2);
    end
    plot2d(w_hz, phase_deg, style=color(line_color), logflag="ln");
    // Handling potential NaNs: plot2d usually skips them.

    if is_gui_mode then
        axPhaseHandle.x_label.text = "Frequency [Hz]";
        axPhaseHandle.y_label.text = "Phase [deg]";
        axPhaseHandle.title.text = ""; // No title on phase plot
        // axPhaseHandle.grid = [color("light gray") color("light gray")]; // Set grid from update_plots
    else
        xlabel("Frequency [Hz]");
        ylabel("Phase [deg]");
        title("Bode Plot - Phase");
        xgrid();
    end

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
