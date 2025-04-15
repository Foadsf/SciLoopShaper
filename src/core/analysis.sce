function [results] = analyze_stability(plant, controller)
    // Analyze the stability of the control system
    results = struct();
    s = poly(0,'s');

    try
        open_loop = plant * controller;
    catch
        error("Could not compute open loop P*C: " + lasterror());
    end

    // --- Calculate bandwidth (0dB crossover frequency) MANUALLY ---
    results.bandwidth = -1;
    try
        w_min_bw = 0.001;
        w_max_bw = 10000;
        n_points_bw = 4000;
        w_hz_bw = logspace(log10(w_min_bw), log10(w_max_bw), n_points_bw);
        w_rads_bw = w_hz_bw * 2 * %pi;

        [frq_rads_out, rep] = repfreq(open_loop, w_rads_bw);
        mag_lin = abs(rep);

        indices = find( (mag_lin(1:$-1) > 1 & mag_lin(2:$) <= 1) | (mag_lin(1:$-1) < 1 & mag_lin(2:$) >= 1) );

        if ~isempty(indices) then
            bw_hz = w_hz_bw(indices(1));
             if indices(1) == 1 & mag_lin(1) >= 1 then
                 results.bandwidth = 0;
             else
                results.bandwidth = bw_hz;
             end
        else
            // Fix: Use and() instead of all()
            if and(mag_lin > 1) then
                results.bandwidth = w_max_bw;
            elseif and(mag_lin < 1) then
                 results.bandwidth = 0;
            else
                 results.bandwidth = -1;
            end
        end
    catch
        disp("Warning: Error during manual bandwidth calculation: " + lasterror());
        results.bandwidth = -1;
    end
    // --- End Bandwidth Calculation ---


    // --- Calculate stability margins using p_margin and g_margin ---
    results.gain_margin = %nan;
    results.phase_margin = %nan;

    // Get Phase Margin using p_margin
    try
        pm_deg = p_margin(open_loop); // Only returns phase margin
        if isempty(pm_deg) then
            results.phase_margin = %inf;
        else
            // p_margin can return multiple values if gain crosses 0dB multiple times
            results.phase_margin = pm_deg(1); // Use the first one
        end
    catch
        disp("Warning: Error during phase margin calculation using p_margin: " + lasterror());
        // Keep phase_margin as %nan
    end

    // Get Gain Margin using g_margin
    try
        gm_lin = g_margin(open_loop); // Only returns gain margin (linear)
        if isempty(gm_lin) then
            // If stable phase never crosses -180, gm is infinite
            results.gain_margin = %inf;
        elseif isinf(gm_lin) then
             results.gain_margin = %inf;
        elseif gm_lin == 0 then // Marginally stable
            results.gain_margin = 0; // 0 dB
        elseif gm_lin > 0 then // Stable
            results.gain_margin = 20*log10(gm_lin); // Convert to dB
        else // gm_lin < 0 (unstable)
            results.gain_margin = -%inf; // Or 20*log10(abs(gm_lin)) depending on convention? Use -Inf for unstable.
        end
    catch
        disp("Warning: Error during gain margin calculation using g_margin: " + lasterror());
        // Keep gain_margin as %nan
    end
    // --- End Margin Calculation ---


    // Modulus margin (TBD)
    results.modulus_margin = 0;

    // Check stability based on calculated margins (handle %nan/%inf)
    is_pm_stable = ~isnan(results.phase_margin) & results.phase_margin > 0;
    is_gm_stable = ~isnan(results.gain_margin) & results.gain_margin > 0;

    if results.phase_margin == %inf then is_pm_stable = %T; end
    if results.gain_margin == %inf then is_gm_stable = %T; end

    // Handle marginal stability (GM=0dB or PM=0deg exactly) -> unstable
    if results.phase_margin == 0 then is_pm_stable = %F; end
    if results.gain_margin == 0 then is_gm_stable = %F; end

    results.stable = is_pm_stable & is_gm_stable;

endfunction

function [resp] = calculate_time_response(plant, controller, input_type, time_vector)
    // Calculate time domain response

    // Form closed loop transfer function
    open_loop = plant * controller;
    closed_loop = open_loop / (1 + open_loop);  // T = PC/(1+PC)

    // Create input signal
    select input_type
    case "step" then
        u = ones(time_vector);
    case "sine" then
        u = sin(time_vector);
    case "3rd order setpoint" then
        // TBD: Implement 3rd order setpoint
        u = ones(time_vector);
    else
        error("Unknown input type: " + input_type);
    end

    // Simulate time response
    resp = csim(u, time_vector, closed_loop);
endfunction
