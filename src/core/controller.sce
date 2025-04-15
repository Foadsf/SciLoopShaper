function [block] = create_controller_block(blockType, params)
    // Create a controller block with the specified type and parameters
    s = poly(0, 's');
    local_tf = []; // Initialize transfer function variable

    // disp("ENTERING create_controller_block. Type: " + blockType); // Optional Debug

    select blockType
    case "Gain" then
        gain = params.gain;
        // Fix: Use explicit numerator (gain) and denominator (1)
        local_tf = syslin('c', gain, 1); // Represents gain/1

    case "Integrator" then
        gain = params.gain;
        // Fix: Use rational form gain/s
        local_tf = syslin('c', gain / s);

    case "Lead/lag" then
        gain = params.gain;
        zeros_val = params.zeros;
        poles_val = params.poles;
        // Fix: Ensure rational form is used (already was)
        local_tf = syslin('c', gain * (s + zeros_val) / (s + poles_val));

    case "Low pass 1st order" then
        gain = params.gain;
        poles_val = params.poles;
        // Fix: Ensure rational form is used (already was)
        local_tf = syslin('c', gain * poles_val / (s + poles_val));

    case "Low pass 2nd order" then
        gain = params.gain;
        wn = params.wn;
        damp = params.damp;
        // Fix: Ensure rational form is used (already was)
        local_tf = syslin('c', gain * wn^2 / (s^2 + 2*damp*wn*s + wn^2));

    case "Notch" then
        gain = params.gain;
        zeros_val = params.zeros;
        damp_zeros = params.damp_zeros;
        poles_val = params.poles;
        damp_poles = params.damp_poles;
        num = s^2 + 2*damp_zeros*zeros_val*s + zeros_val^2;
        den = s^2 + 2*damp_poles*poles_val*s + poles_val^2;
        // Fix: Ensure rational form is used (already was)
        local_tf = syslin('c', gain * num / den);

    case "PD" then
        kp = params.kp;
        kd = params.kd;
        // Fix: Use explicit numerator (kp+kd*s) and denominator (1)
        // Need to create polynomial kp explicitly if kd=0 is possible
        num = poly([kp], 's', 'coeff') + poly([kd 0], 's', 'coeff'); // Represents kp + kd*s
        local_tf = syslin('c', num, 1);

    case "Second-order Damped Integrator" then
        gain = params.gain;
        wn = params.wn;
        damp = params.damp;
        num = s^2 + 2*damp*wn*s + wn^2;
        den = s^2;
        // Fix: Ensure rational form is used (already was)
        local_tf = syslin('c', gain * num / den);

    else
        error("Unknown controller block type: " + blockType);
    end

    // --- Create the output structure ---
    try
        block = struct('type', blockType, 'params', params, 'tf', local_tf);
    catch
        disp("!!! Error creating structure AFTER select block !!!");
        lasterror(%t);
        error("Structure creation failed");
    end

    // disp("EXITING create_controller_block"); // Optional Debug
endfunction

function [controller] = calculate_controller(blocks)
    // Cascade all controller blocks to form the complete controller
    if or(blocks == list()) | isempty(blocks) then // More robust check for empty
        // Fix: Use explicit numerator/denominator for unity gain
        controller = syslin('c', 1, 1);
        return;
    end

    // Start with the first block
    controller = blocks(1).tf;

    // Cascade the remaining blocks
    for i = 2:length(blocks)
        controller = controller * blocks(i).tf;
    end
endfunction

function [sys_d] = discretize_controller(sys, Ts, method)
    // Discretize a controller using specified method
    // NOTE: Uses numeric codes for dscr methods due to Scilab 2024.0.0 bug/change

    if typeof(sys) ~= "rational" then
        error("System must be a transfer function (syslin rational).");
    end

    sys_d = []; // Initialize output

    select method
    case "tustin" then
        // Fix: Use numeric code 2 for Tustin method in dscr
        disp("--> Attempting Tustin discretization using numeric code 2...");
        try
            // Method 2 corresponds to Tustin/Bilinear Transform
            sys_d = dscr(sys, Ts, 2);
            // dscr returns state-space by default, convert back to TF if needed
            // Although keeping it as state-space internally might be fine
             if typeof(sys_d) == "state-space" then
                 sys_d = ss2tf(sys_d);
             end
            disp("--> Tustin discretization successful.");
        catch
            disp("!!! Tustin discretization failed with dscr (Method 2).");
            error(lasterror()); // Re-throw original error
        end

    case "tustin_prewarp" then
        // TBD: Implement prewarping
        // Prewarping requires calculating warped frequency and likely
        // applying Tustin manually or using a dedicated function if available.
        // dscr itself might not directly support prewarp frequency input easily.
        error("Tustin with prewarping not implemented yet");

    // Add case for ZOH if needed, checking its numeric code
    // case "zoh" then
    //    numeric_code_zoh = 0; // Check dscr documentation for ZOH code (likely 0)
    //    disp("--> Attempting ZOH discretization using numeric code " + string(numeric_code_zoh) + "...");
    //    try
    //        sys_d = dscr(sys, Ts, numeric_code_zoh);
    //         if typeof(sys_d) == "state-space" then sys_d = ss2tf(sys_d); end
    //        disp("--> ZOH discretization successful.");
    //    catch
    //        disp("!!! ZOH discretization failed with dscr (Method " + string(numeric_code_zoh) + ").");
    //        error(lasterror());
    //    end

    else
         error("Unsupported discretization method specified: " + method);
        // Or default to one method?
        // disp("--> Using default discretization method (Numeric Code ?)...");
        // try
        //     sys_d = dscr(sys, Ts); // Default might be ZOH (code 0?)
        //      if typeof(sys_d) == "state-space" then sys_d = ss2tf(sys_d); end
        //     disp("--> Default discretization successful.");
        // catch
        //     disp("!!! Default discretization failed with dscr.");
        //     error(lasterror());
        // end
    end
endfunction
