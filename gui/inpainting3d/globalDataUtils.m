function [ varargout ] = globalDataUtils( varargin )
% utils to set parameters
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    % evaluate function according to the number of inputs and outputs
    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function [ handles ] = setUserDataDefaults( handles )
% set user data

    user_data = struct;
    
    % put in any user data which needs to go into handles
    if isfield(handles, 'user_data')
        user_data = handles.user_data;
    end
    
    user_data.viewer3d_exec = '/usr/local/bin/view3dscene/view3dscene [params] [filepath]';
    user_data.viewer3d_params = {'--help'};
    user_data.temp_dir = 'sfsd';
    
    user_data.filepath_input_im = '';
    user_data.input_im = [];
    user_data.filepath_input_mask = '';
    user_data.input_mask = [];
    
    handles.user_data = user_data;
end


function [ handles ] = guiDataDefaults( handles )
% set the default values required by the GUI

    gui_data = struct;
    
    % put in any user data which needs to go into handles
    if isfield(handles, 'gui_data')
        gui_data = handles.gui_data;
    end
    
    pos = get(handles.inpainting3d_gui, 'Position');
    pos2 = get(handles.pushbutton_loadim,'Position');
    gui_data.axes_loc = [30 30 pos2(1)-60 pos(4)-60];
    
    gui_data.im_ext_allowed = {'*.png;*.jpg;*.bmp;*.pgm;*.tif', 'All Image Files'; '*.*','All Files'};
    
    gui_data.axes_tag_prefix = 'inp3d_axes_';
    gui_data.axes_txt_prefix = 'inp3d_txt_axes_';
    
    
    gui_data.curr_dir = pwd;
    
    handles.gui_data = gui_data;
end
