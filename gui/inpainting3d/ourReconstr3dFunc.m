function [ varargout ] = ourReconstr3dFunc( varargin )
% Inpainting function
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function [ vrml_filepath output_filepath medsup_filepath ] = reconstr3d( input_im, mask_im, params, handles )
% main function that calls 3D reconstruction code

    % expand params back to variables
    %
    
    curr_path = pwd;
    cd(handles.user_data.ourreconstr3d_run_dir);
    
    % write input file temp path
    [temp filename] = fileparts(handles.user_data.filepath_input_im);
    filename = [filename '.png'];
    imwrite(input_im, filename);
    
    [temp filename_mask] = fileparts(handles.user_data.filepath_input_im);
    filename_mask = [filename_mask '_fg_mask.png'];
    imwrite(mask_im, filename_mask);
    
    run_id = sprintf('gui_test_%s', sprintf('_%.0f',clock));
    
    if strcmp(handles.user_data.ourreconstr3d_exec_type, 'MATLAB')
        exec_cmd = handles.user_data.ourreconstr3d_exec;
        
        params_list = '';
        for idx = 1:length(handles.user_data.ourreconstr3d_params)
            params_list = [params_list ', ' handles.user_data.ourreconstr3d_params{idx}];
        end
        exec_cmd = regexprep(exec_cmd, '\[params\]', params_list);
        exec_cmd = regexprep(exec_cmd, '\[input_filepath\]', ['''' filename '''']);
        exec_cmd = regexprep(exec_cmd, '\[output_path\]', '''''');
        exec_cmd = regexprep(exec_cmd, '\[mask_filepath\]', ['''' filename_mask '''']);
        exec_cmd = regexprep(exec_cmd, '\[output_id\]', run_id);
    else
        errordlg('Execution style other than MATLAB not implemented', 'ourReconstr3dFunc:NotImpl', 'modal');
        return;
    end
    
    % run pre-exec cmds
    for idx = 1:length(handles.user_data.ourreconstr3d_prerun_cmds)
        eval(handles.user_data.ourreconstr3d_prerun_cmds{idx})
    end
    
    % wait dialog box
    [ dlg ] = waitMessage( 'Running 3D reconstruction', 'Running 3D reconstruction code ... please wait ...', handles.gui_data.icons.info_icon, handles.gui_data.icons.info_icon_map );
    
    % run 3D reconstruction code
    if strcmp(handles.user_data.inpainting_exec_type, 'MATLAB')
        eval(exec_cmd);
    end
    
    % delete the dialog box
    delete(dlg);
    
    % run post-exec cmds
    for idx = 1:length(handles.user_data.ourreconstr3d_postrun_cmds)
        eval(handles.user_data.ourreconstr3d_postrun_cmds{idx})
    end
    
    % store the output filepaths
    vrml_filepath = fullfile(pwd, ['_' run_id '.wrl']);
    medsup_filepath = fullfile(pwd, ['_' run_id '.ppm']);
    output_filepath = fullfile(pwd, ['_' run_id '.jpg']);

    % somethings wrong with the jpg file written (rewrite it)
%     [path filename] = fileparts(vrml_filepath);
%     imwrite(input_im, fullfile(path, [filename '.jpg']));
    
    cd(curr_path);
end



function [ params ] = createInputParamsCell()
% creates a cell array containing all the parameter values for 3D reconstr

    params = {};
end