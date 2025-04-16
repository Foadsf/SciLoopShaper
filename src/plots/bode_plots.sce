// File: src/plots/bode_plots.sce

function plot_bode(sys, w_min, w_max, n_points, line_style_str, line_color_str, axMagHandle, axPhaseHandle)
    // Plot Bode diagram using semilogx for clarity

    scilab_style_code = line_style_str; // e.g., 'b-'

    is_gui_mode = %F;
    if isdef('axMagHandle','local') & isdef('axPhaseHandle','local') then
        if typeof(axMagHandle) == "handle" & typeof(axPhaseHandle) == "handle" then
             if axMagHandle.type == "Axes" & axPhaseHandle.type == "Axes" then
                 is_gui_mode = %T;
             end
        end
    end

    [mag, phase_deg, w_hz] = calculate_frequency_response(sys, w_min, w_max, n_points);

    if isempty(mag) | isempty(phase_deg) | isempty(w_hz) then
        warning("calculate_frequency_response returned empty data. Cannot plot Bode.");
        if is_gui_mode then /* Display error on axes */ end
        return;
    end

    epsilon = 1e-200;
    mag_db = 20*log10(mag + epsilon);

    // --- Plot Magnitude ---
    if is_gui_mode then sca(axMagHandle); else subplot(2, 1, 1); end
    try
        // Fix: Use semilogx directly with style string
        semilogx(w_hz, mag_db, scilab_style_code);
        // disp("Successfully plotted magnitude data using semilogx"); // Optional Debug
    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error plotting magnitude data with semilogx:");
        disp(lasterror());
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end
    if is_gui_mode then // Set properties on handle
        axMagHandle.x_label.visible = "off";
        axMagHandle.y_label.text = "Magnitude [dB]";
        axMagHandle.title.text = "Bode Plot";
    else // Use global functions for standalone figure
        ylabel("Magnitude [dB]");
        title("Bode Plot - Magnitude");
        xgrid();
    end

    // --- Plot Phase ---
    if is_gui_mode then sca(axPhaseHandle); else subplot(2, 1, 2); end
    try
        // Fix: Use semilogx directly with style string
        semilogx(w_hz, phase_deg, scilab_style_code);
        // disp("Successfully plotted phase data using semilogx"); // Optional Debug
    catch
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        disp("Error plotting phase data with semilogx:");
        disp(lasterror());
        disp("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    end
     if is_gui_mode then // Set properties on handle
        axPhaseHandle.x_label.text = "Frequency [Hz]";
        axPhaseHandle.y_label.text = "Phase [deg]";
        axPhaseHandle.title.text = "";
    else // Use global functions for standalone figure
        xlabel("Frequency [Hz]");
        ylabel("Phase [deg]");
        xgrid();
    end

endfunction // End of plot_bode function


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
