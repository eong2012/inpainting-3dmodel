function [ varargout ] = inpaintingFunc( varargin )
% Inpainting function
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function [ inpainted_im input_im inpaint_mask ] = inpainting( input_im, input_mask, params, handles )
% main function that calls inpainting code

    % expand params back to variables
    scale_value = params{1};

    % rescale the images
    input_im = imresize(input_im, scale_value);
    inpaint_mask = imresize(input_mask, scale_value);
    
    if strcmp(handles.user_data.ourreconstr3d_exec_type, 'MATLAB')
        exec_cmd = handles.user_data.inpainting_exec;
        exec_cmd = regexprep(exec_cmd, '\[inpainted_im\]', 'inpainted_im');
        exec_cmd = regexprep(exec_cmd, '\[input_im\]', 'input_im');
        exec_cmd = regexprep(exec_cmd, '\[inpaint_mask\]', 'inpaint_mask');
        
        params_list = '';
        for idx = 1:length(handles.user_data.inpainting_params)
            params_list = [params_list ', ' handles.user_data.inpainting_params{idx}];
        end
        exec_cmd = regexprep(exec_cmd, '\[params\]', params_list);
    else
        errordlg('Execution style other than MATLAB not implemented', 'inpaintingFunc:NotImpl', 'modal');
        return;
    end
    
    curr_path = pwd;
    cd(handles.user_data.inpainting_run_dir);
    
    % run pre-exec cmds
    for idx = 1:length(handles.user_data.inpainting_prerun_cmds)
        eval(handles.user_data.inpainting_prerun_cmds{idx})
    end
    
    % wait dialog box
    [ dlg ] = waitMessage( 'Running inpainting', 'Running inpainting code ... please wait ...', handles.gui_data.icons.info_icon, handles.gui_data.icons.info_icon_map );
    
    % run inpainting code
    if strcmp(handles.user_data.inpainting_exec_type, 'MATLAB')
        eval(exec_cmd);
    end
    
    % delete the dialog box
    delete(dlg);
    
    % run post-exec cmds
    for idx = 1:length(handles.user_data.inpainting_postrun_cmds)
        eval(handles.user_data.inpainting_postrun_cmds{idx})
    end
    
    cd(curr_path);
end



function [ params ] = createInputParamsCell(scale_value)
% creates a cell array containing all the parameter values for inpainting

    params = {scale_value};
end