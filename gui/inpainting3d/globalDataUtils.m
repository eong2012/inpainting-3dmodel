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

%     user_data = struct;
    
    % reset image data (filenames and mat for im and FG)
    [ handles ] = reInitImageData(handles);
    [ handles ] = reInitMaskData(handles);
    
    % put in any user data which needs to go into handles
    if isfield(handles, 'user_data')
        user_data = handles.user_data;
    end
    
    root_path = fileparts(fileparts(fileparts(which(mfilename))));
    
    user_data.viewer3d_exec = '/usr/local/bin/view3dscene/view3dscene [params] [filepath]';
    user_data.viewer3d_exec_type = 'SYSTEM';
    user_data.viewer3d_params = {'--help'};
    
    user_data.inpainting_exec = '[[inpainted_im],[input_im],[inpaint_mask]] = inpaint([input_im],[inpaint_mask] [params]);';
    user_data.inpainting_exec_type = 'MATLAB';
    user_data.inpainting_params = {'[0,0,0]'};
    user_data.inpainting_run_dir = fullfile(root_path, 'criminisi_inpainting');
    user_data.inpainting_prerun_cmds = {};
    user_data.inpainting_postrun_cmds = {'inpainted_im = uint8(inpainted_im);'};
    
    user_data.temp_dir = 'sfsd';
    
    handles.user_data = user_data;
end


function [ handles ] = guiDataDefaults( handles )
% set the default values required by the GUI

    gui_data = struct;
    
    % put in any user data which needs to go into handles
    if isfield(handles, 'gui_data')
        gui_data = handles.gui_data;
    end
    
    % used to set the position of the axes
    pos = get(handles.inpainting3d_gui, 'Position');
    pos2 = get(handles.pushbutton_loadim,'Position');
    gui_data.axes_loc = [30 30 pos2(1)-60 pos(4)-60];
    
    % file extensions available during file open 
    gui_data.im_ext_allowed = {'*.png;*.jpg;*.bmp;*.pgm;*.tif', 'All Image Files'; '*.*','All Files'};
    
    % tags used for axes and images
    gui_data.axes_tag_prefix = 'inp3d_axes_';
    gui_data.axes_txt_prefix = 'inp3d_txt_axes_';
    gui_data.im_tag_prefix = 'inp3d_im_';
    gui_data.mask_tag_prefix = 'inp3d_mask_';
    
    % regexp used for searching for gui objects
    gui_data.axes_search_re = ['^' gui_data.axes_tag_prefix '(\d+)$'];
    
    % store all icons used for message boxes
    gui_data.icons_dir = fullfile(fileparts(which(mfilename)), 'icons');
    [ gui_data ] = getAllMsgIcons( gui_data );
    
    gui_data.curr_dir = pwd;
    
    handles.gui_data = gui_data;
end


function [ gui_data ] = getAllMsgIcons( gui_data )
    % get the background clr of dialog box
    h = dialog('Visible','off'); clr=get(h,'Color'); delete(h);
    
    % convert success and failed icon into a format usable by msgbox
    succ_icon = imread(fullfile(gui_data.icons_dir,'success.png'));
    bg = succ_icon(:,:,1) == 0 & succ_icon(:,:,2) == 0 & succ_icon(:,:,3) == 0;
    succ_icon(cat(3, bg,false(size(bg)),false(size(bg)))) = clr(1)*255;
    succ_icon(cat(3, false(size(bg)),bg,false(size(bg)))) = clr(2)*255;
    succ_icon(cat(3, false(size(bg)),false(size(bg)),bg)) = clr(3)*255;
    [gui_data.icons.succ_icon, gui_data.icons.succ_icon_map] = rgb2ind(succ_icon,65536);
    
    info_icon = imread(fullfile(gui_data.icons_dir,'info.png'));
    bg = info_icon(:,:,1) == 0 & info_icon(:,:,2) == 0 & info_icon(:,:,3) == 0;
    info_icon(cat(3, bg,false(size(bg)),false(size(bg)))) = clr(1)*255;
    info_icon(cat(3, false(size(bg)),bg,false(size(bg)))) = clr(2)*255;
    info_icon(cat(3, false(size(bg)),false(size(bg)),bg)) = clr(3)*255;
    [gui_data.icons.info_icon, gui_data.icons.info_icon_map] = rgb2ind(info_icon,65536);
end


function [ handles ] = reInitImageData( handles )
% resets all the data for all the axes'

    % get the current no. of axes
%     no_axes = length(findall(handles.inpainting3d_gui, '-regexp', 'Tag', handles.gui_data.axes_search_re));

    % store the axes image
    handles.user_data.filepath_input_im = '';
    handles.user_data.input_im = [];
end


function [ handles ] = reInitMaskData( handles )
% resets all the data for all the axes'

    % get the current no. of axes
%     no_axes = length(findall(handles.inpainting3d_gui, '-regexp', 'Tag', handles.gui_data.axes_search_re));

    % store the mask image
    handles.user_data.filepath_input_mask = '';
    handles.user_data.input_mask = [];
    handles.user_data.display_mask = [];
end


function [ handles ] = reInitOutputs( handles )
% resets all the data for all the axes'

    % get the current no. of axes
%     no_axes = length(findall(handles.inpainting3d_gui, '-regexp', 'Tag', handles.gui_data.axes_search_re));

    % store the outputs
    handles.user_data.inpainting_output = [];
    handles.user_data.reconstr3d_vrml_output = [];
    handles.user_data.reconstr3d_inpaint_vrml_output = [];
    handles.user_data.reconstr3d_inpaint_output = [];
end