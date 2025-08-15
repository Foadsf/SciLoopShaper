function [valid, error_msg] = validate_controller_params(blockType, params)
    // Comprehensive parameter validation for controller blocks
    valid = %T;
    error_msg = "";

    select blockType
    case "Gain" then
        if ~isfield(params, 'gain') then
            valid = %F; error_msg = "Missing required parameter: gain";
        elseif ~isreal(params.gain) | isnan(params.gain) then
            valid = %F; error_msg = "Gain must be a real number";
        end

    case "Lead/lag" then
        required_fields = ['gain', 'zeros', 'poles'];
        for field = required_fields'
            if ~isfield(params, field) then
                valid = %F; error_msg = "Missing required parameter: " + field;
                return;
            end
        end

        if params.zeros <= 0 | params.poles <= 0 then
            valid = %F; error_msg = "Poles and zeros must be positive";
        end

    // TODO: Add validation for all other block types...

    end
endfunction
