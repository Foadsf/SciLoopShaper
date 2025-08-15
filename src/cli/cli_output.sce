// Output formatting and file generation

function text_output = format_stability_text(results)
    // Format stability results as human-readable text
    text_output = [];
    text_output($+1) = "=== Stability Analysis Results ===";
    text_output($+1) = "Stable: " + string(results.stable);
    text_output($+1) = "Gain Margin: " + string(results.gain_margin) + " dB";
    text_output($+1) = "Phase Margin: " + string(results.phase_margin) + " deg";
    text_output($+1) = "Bandwidth: " + string(results.bandwidth) + " Hz";
endfunction

function json_output = format_stability_json(results)
    // Placeholder
    json_output = "{ ""stable"": true }";
endfunction

function csv_output = format_stability_csv(results)
    // Placeholder
    csv_output = "Parameter,Value\nStable,true";
endfunction

function write_output_file(filename, output)
    // Placeholder
    disp("Writing output to file: " + filename);
endfunction

function save_plot_to_file(filename, plot_type)
    // Placeholder
    disp("Saving " + plot_type + " plot to file: " + filename);
endfunction

function display_frequency_response_summary(mag, phase, w)
    // Find key frequency points
    [max_mag_val, max_mag_idx] = max(mag);
    [min_mag_val, min_mag_idx] = min(mag);

    // Convert to dB
    mag_db = 20*log10(mag + 1e-12);

    disp("=== Frequency Response Summary ===");
    disp("Frequency range: " + string(w(1)) + " to " + string(w($)) + " Hz");
    disp("Maximum magnitude: " + string(20*log10(max_mag_val)) + " dB at " + string(w(max_mag_idx)) + " Hz");
    disp("Minimum magnitude: " + string(20*log10(min_mag_val)) + " dB at " + string(w(min_mag_idx)) + " Hz");

    // Find approximate -3dB bandwidth
    target_mag = max_mag_val / sqrt(2); // -3dB point
    bw_indices = find(mag >= target_mag);
    if ~isempty(bw_indices) then
        disp("Approximate -3dB bandwidth: " + string(w(bw_indices($))) + " Hz");
    end
endfunction
