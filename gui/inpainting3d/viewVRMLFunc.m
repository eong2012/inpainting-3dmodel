function [ varargout ] = viewVRMLFunc( varargin )
% VRML viewing function
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function viewVRML(vrml_filepath, handles)

    if strcmp(handles.user_data.viewer3d_exec_type, 'SYSTEM')
        exec_cmd = handles.user_data.viewer3d_exec;
        exec_cmd = regexprep(exec_cmd, '\[filepath\]', vrml_filepath);;
        
        params_list = '';
        for idx = 1:length(handles.user_data.viewer3d_params)
            params_list = [params_list ' ' handles.user_data.viewer3d_params{idx}];
        end
        exec_cmd = regexprep(exec_cmd, '\[params\]', params_list);
        
        % run the external VRML viewer
        [status, result] = system(exec_cmd);
        
        % throw error if the status was not 0
        if status ~= 0
            errordlg(result, 'Couldn''t run VRML program', 'modal');
        end
    else
        errordlg('Execution style other than SYSTEM not implemented', 'viewVRMLFunc:NotImpl', 'modal');
        return;
    end
end