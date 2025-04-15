function plot_bode(sys, w_min, w_max, n_points, line_style, line_color)
    // Plot Bode diagram for the given system

    [mag, phase_deg, w_hz] = calculate_frequency_response(sys, w_min, w_max, n_points);

    if isempty(mag) | isempty(phase_deg) | isempty(w_hz) then
        warning("calculate_frequency_response returned empty data. Cannot plot Bode.");
        return;
    end

    epsilon = 1e-200;
    mag_db = 20*log10(mag + epsilon);

    // Plot magnitude
    subplot(2, 1, 1);
    semilogx(w_hz, mag_db, line_style, 'color', line_color);
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    title('Magnitude'); // Add title
    a = gca();          // Get current axes handle
    a.grid = [1 1];     // << Set grid LAST for this subplot

    // Plot phase
    subplot(2, 1, 2);
    semilogx(w_hz, phase_deg, line_style, 'color', line_color);
    xlabel('Frequency [Hz]');
    ylabel('Phase [deg]');
    title('Phase');     // Add title
    a = gca();          // Get current axes handle
    a.grid = [1 1];     // << Set grid LAST for this subplot

endfunction

function plot_nyquist(sys, w_min, w_max, n_points, line_style, line_color)
    // Plot Nyquist diagram for the given system

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
    // Plot Nichols chart for the given system

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
