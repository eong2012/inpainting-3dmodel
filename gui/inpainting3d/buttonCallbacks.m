function [ varargout ] = buttonCallbacks( varargin )
% callbacks to all button clicks
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    % evaluate function according to the number of inputs and outputs
    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function btn_load_im_Callback(hObject, evendata, handles)
    not_done = 1;
    msg_prefix = '[unknown action]';

    while not_done
        try
            % check if it has all the necessary files are there and readable
            msg_prefix = ['choosing input image'];
            [file_name, folder_name] = uigetfile(handles.gui_data.im_ext_allowed, 'Choose input image', handles.gui_data.curr_dir);

            if isscalar(file_name) && file_name == 0
                return;
            end
            
            input_im = imread(fullfile(folder_name, file_name));
            
            not_done = 0;
        catch exception
            uiwait(errordlg([exception.identifier ' - Error while ' msg_prefix ': ' exception.message], 'Invalid file', 'modal'));
        end
    end

    % change to latest directory
    handles.gui_data.curr_dir = folder_name;
    
    % change to the latest file
    handles.user_data.filepath_input_im = fullfile(folder_name, file_name);
    handles.user_data.input_im = input_im;
    
    % enable FG button
    set(handles.pushbutton_fgmask, 'Enable','on');
    
    % update handles structure
    guidata(hObject, handles);
end


function btn_load_mask_Callback(hObject, evendata, handles)
not_done = 1;
    msg_prefix = '[unknown action]';

    while not_done
        try
            % check if it has all the necessary files are there and readable
            msg_prefix = ['choosing foreground mask'];
            [file_name, folder_name] = uigetfile(handles.gui_data.im_ext_allowed, 'Choose foreground mask', handles.gui_data.curr_dir);

            if isscalar(file_name) && file_name == 0
                return;
            end
            
            input_mask = imread(fullfile(folder_name, file_name));
            input_mask = logical(input_mask);
            
            not_done = 0;
        catch exception
            uiwait(errordlg([exception.identifier ' - Error while ' msg_prefix ': ' exception.message], 'Invalid file', 'modal'));
        end
    end

    % change to latest directory
    handles.gui_data.curr_dir = folder_name;
    
    % change to the latest file
    handles.user_data.filepath_input_mask = fullfile(folder_name, file_name);
    handles.user_data.input_mask = input_mask;
    
    % update handles structure
    guidata(hObject, handles);
end
