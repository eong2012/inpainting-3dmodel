function [ varargout ] = inpaintingGuiCallbacks( varargin )
% callabacks for inpainting GUI
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


% --- Executes on threshold text change
function scale_text_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of threshold_text as text
    %        str2double(get(hObject,'String')) returns contents of threshold_text as a double

    %get the string for the editText component
    scale_value = get(handles.edit_inpainting_scale,'String');

    %convert from string to number if possible, otherwise returns empty
    scale_value = str2double(scale_value);

    %if user inputs something is not a number, or if the input is less than equal to 0
    %or greater than 1, then the slider value defaults to 1
    if (isempty(scale_value) || isnan(scale_value) || scale_value <= get(handles.edit_inpainting_scale,'Min') || scale_value > get(handles.edit_inpainting_scale,'Max'))
        set(handles.edit_inpainting_scale, 'String', num2str(get(handles.edit_inpainting_scale,'Max')));
    end
end


% --- Executes during object creation, after setting all properties.
function scale_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function pushbutton_inpainting_exec_Callback(hObject, eventdata, handles)
% executes inpainting in image space

    % deactive save button
    set(handles.pushbutton_save_inpainting, 'Enable','off');
    
    %get the string for the editText component
    scale_value = get(handles.edit_inpainting_scale,'String');

    %convert from string to number if possible, otherwise returns empty
    scale_value = str2double(scale_value);
    
    % rescale the images
    input_im = imresize(handles.user_data.input_im, scale_value);
    inpaint_mask = imresize(handles.user_data.input_mask, scale_value);
    
    if strcmp(handles.user_data.inpainting_exec_type, 'MATLAB')
        exec_cmd = handles.user_data.inpainting_exec;
        exec_cmd = regexprep(exec_cmd, '\[inpainted_im\]', 'inpainted_im');
        exec_cmd = regexprep(exec_cmd, '\[input_im\]', 'input_im');
        exec_cmd = regexprep(exec_cmd, '\[inpaint_mask\]', 'inpaint_mask');
        
        params_list = '';
        for idx = 1:length(handles.user_data.inpainting_params)
            params_list = [params_list ', ' handles.user_data.inpainting_params{idx}];
        end
        exec_cmd = regexprep(exec_cmd, '\[params\]', params_list);
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
    eval(exec_cmd);
    
    % delete the dialog box
    delete(dlg);
    
    % run post-exec cmds
    for idx = 1:length(handles.user_data.inpainting_postrun_cmds)
        eval(handles.user_data.inpainting_postrun_cmds{idx})
    end
    
    cd(curr_path);
    
    % store the output
    handles.user_data.inpainting_output = inpainted_im;

    % Update handles structure
    guidata(hObject, handles);
    
    fig_h = figure('Name','Inpainting Output'); imshow(handles.user_data.inpainting_output);
    set(fig_h, 'units', 'pixels', 'position', [100 100 size(handles.user_data.inpainting_output,2) size(handles.user_data.inpainting_output,1)], 'paperpositionmode', 'auto');
    set(get(fig_h,'CurrentAxes'), 'position', [0 0 1 1], 'visible', 'off');
    %print('-depsc', out_filename, '-r0');
    
    % active save button
    set(handles.pushbutton_save_inpainting, 'Enable','on');
end


function pushbutton_inpainting_save_Callback(hObject, eventdata, handles)
% called for saving the output inpainting
    not_done = 1;
    msg_prefix = '[unknown action]';

    % loop until either user gives up (cancels) or tells where to save the image
    while not_done
        try
            % check if it has all the necessary files are there and readable
            msg_prefix = ['saving file'];
            [file_name folder_name] = uiputfile('*.eps;*.bmp;*.jpg;*.png;*.tiff', 'Indicate where to save the image', handles.gui_data.curr_dir);

            if isscalar(file_name) && file_name == 0
                return;
            end
            
            not_done = 0;
        catch exception
            uiwait(errordlg([exception.identifier ' - Error while ' msg_prefix ': ' exception.message], 'Invalid file', 'modal'));
        end
    end
    
    % write the inpainted output
    imwrite(handles.user_data.inpainting_output, fullfile(folder_name, file_name));
end
