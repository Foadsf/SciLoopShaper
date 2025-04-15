function [sys] = load_plant_from_workspace(name)
    // Load plant model from Scilab workspace
    try
        // Retrieve the variable from the workspace
        sys = evstr(name);

        // Verify it's a valid system representation
        if typeof(sys) == "rational" then
            if sys.dt == [] | sys.dt == 0 then
                // It's a continuous system
                return;
            else
                // It's a discrete system, convert sample time to seconds
                return;
            end
        elseif typeof(sys) == "state-space" then
            // Convert state-space to transfer function
            sys = ss2tf(sys);
            return;
        elseif typeof(sys) == "zpk" then
            // Convert zero-pole-gain to transfer function
            sys = zpk2tf(sys);
            return;
        else
            error("Variable is not a valid system representation");
        end
    catch
        error("Could not load plant from workspace: " + lasterror());
    end
endfunction

function [sys] = create_example_plant(example_name)
    // Create built-in example plant models
    s = poly(0, 's');

    select example_name
    case "mass" then
        // Simple mass system: 1/(m*s^2)
        m = 1;
        sys = syslin('c', 1/(m*s^2));
    case "2 mass collocated" then
        // Two-mass system with collocated sensor/actuator
        m1 = 1;
        m2 = 1;
        k = 100;
        b = 0.1;
        num = k;
        den = m1*m2*s^4 + b*s^3 + (m1+m2)*k*s^2;
        sys = syslin('c', num/den);
    case "2 mass non-collocated" then
        // Two-mass system with non-collocated sensor/actuator
        m1 = 1;
        m2 = 1;
        k = 100;
        b = 0.1;
        num = k;
        den = m1*m2*s^4 + b*s^3 + (m1+m2)*k*s^2;
        sys = syslin('c', num/den);
    else
        error("Unknown example: " + example_name);
    end
endfunction

function [mag, phase, w] = calculate_frequency_response(sys, w_min, w_max, n_points)
    // Calculate frequency response for a system (outputs w in Hz)

    if type(sys) <> 16 then // Check for syslin object
         error("Input system must be a syslin object (transfer function or state-space).");
    end

    // Create frequency vector in Hz
    w_hz = logspace(log10(w_min), log10(w_max), n_points);
    // Convert Hz to rad/s for repfreq
    w_rads = w_hz * 2 * %pi;

    // Calculate frequency response using repfreq
    disp("--> Calling repfreq with frequency range (rad/s): " + string(min(w_rads)) + " to " + string(max(w_rads))); // Debug
    try
        [frq_rads_out, rep] = repfreq(sys, w_rads);
        disp("--> repfreq call successful."); // Debug
    catch
        error("Error occurred during repfreq call: " + lasterror());
    end

    // --- Robustness Checks ---
    if isempty(rep) then
        disp("!!! repfreq returned an empty response array. !!!"); // Debug
        mag = []; phase = []; w = []; // Return empty to signal failure
        return;
    end
    // Check if 'rep' is a numeric matrix (type 1) and is a vector
    if type(rep) <> 1 | (size(rep, 1) <> 1 & size(rep, 2) <> 1) then
        disp("!!! repfreq did not return a numeric vector (type=" + string(type(rep)) + ", size=[" + string(size(rep,1)) + "," + string(size(rep,2)) + "])."); // More informative debug
        mag = []; phase = []; w = []; return;
    end
     if length(rep) <> n_points then
        disp("!!! repfreq returned vector of unexpected length: " + string(length(rep)) + " vs expected " + string(n_points)); // Debug
        // Attempt to use it anyway, but caution is advised
     end

    // Check for Inf/NaN in the complex response
    problem_indices = find(isinf(rep) | isnan(rep));
    if ~isempty(problem_indices) then
        disp("!!! Warning: repfreq returned Inf/NaN at " + string(length(problem_indices)) + " frequency points. Replacing with near-zero magnitude and phase=NaN.");
        // Replace Inf/NaN magnitude with a small number (e.g., -200 dB) to avoid plot issues
        // Replace corresponding phase with NaN
        small_mag_val = 10^(-10); // Approx -200 dB
        rep(problem_indices) = complex(small_mag_val, 0); // Replace complex value
    end
    // --- End Robustness Checks ---

    // Extract magnitude and phase
    mag = abs(rep);
    // Use atan with two arguments (atan(y, x)) for quadrant correctness
    phase_rad = atan(imag(rep), real(rep));
    // Unwrap the phase calculated in radians
    phase_rad_unwrapped = unwrap(phase_rad);
    // Convert unwrapped radians to degrees
    phase = phase_rad_unwrapped * 180 / %pi;

    // If we had Inf/NaN, ensure phase is NaN there
    if exists('problem_indices') then
         phase(problem_indices) = %nan;
    end

    // Return the original frequency vector in Hz
    w = w_hz;
    disp("--> calculate_frequency_response completed."); // Debug

endfunction
