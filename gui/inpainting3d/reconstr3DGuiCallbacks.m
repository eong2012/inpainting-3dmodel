function [ varargout ] = reconstr3DGuiCallbacks( varargin )
% callbacks for 3D-reconstruction GUI
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


% --- Executes on toggling checkbox
function inpainting_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % if checkbox enabled
    if get(handles.checkbox_3dreconstr_inp, 'Value')
        set(handles.text_3dreconstr_inp_scaling, 'Enable','on');
        set(handles.edit_3dreconstr_inp_scale, 'Enable','on');
    else
        set(handles.text_3dreconstr_inp_scaling, 'Enable','off');
        set(handles.edit_3dreconstr_inp_scale, 'Enable','off');
    end
end


% --- Executes on scale text change
function scale_text_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of threshold_text as text
    %        str2double(get(hObject,'String')) returns contents of threshold_text as a double

    %get the string for the editText component
    scale_value = get(handles.edit_3dreconstr_inp_scale,'String');

    %convert from string to number if possible, otherwise returns empty
    scale_value = str2double(scale_value);

    %if user inputs something is not a number, or if the input is less than equal to 0
    %or greater than 1, then the slider value defaults to 1
    if (isempty(scale_value) || isnan(scale_value) || scale_value <= get(handles.edit_3dreconstr_inp_scale,'Min') || scale_value > get(handles.edit_3dreconstr_inp_scale,'Max'))
        set(handles.edit_3dreconstr_inp_scale, 'String', num2str(get(handles.edit_3dreconstr_inp_scale,'Max')));
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


% --- Executes on 3D reconstruction button click
function pushbutton_3dreconstr_exec_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % deactive view VRML button
    set(handles.pushbutton_3dreconstr_vrml, 'Enable','off');
    
    reconstr_im = handles.user_data.input_im;
    
    preprocess_inpainting = get(handles.checkbox_3dreconstr_inp, 'Value');
    
    % if inpainting is activated
    if preprocess_inpainting
        % check if inpainting at current params was already performed and stored
        
        %get the string for the editText component
        scale_value = get(handles.edit_3dreconstr_inp_scale,'String');

        %convert from string to number if possible, otherwise returns empty
        scale_value = str2double(scale_value);
        
        params = inpaintingFunc('createInputParamsCell', scale_value);
        
        % if inpainting with exact parameters was done in inpainting GUI
        if length(handles.user_data.inpainting_output_params) == length(params) && ...
                all(cellfun(@(x,y) all(x==y), handles.user_data.inpainting_output_params, params))
            handles.user_data.reconstr3d_inpaint_output_params = params;
            handles.user_data.reconstr3d_inpaint_output = handles.user_data.inpainting_output;
            
        % NOT(if inpainting with exact parameters was done 3D reconstr GUI)
        elseif ~(~isempty(handles.user_data.reconstr3d_inpaint_output_params) && all(cellfun(@(x,y) all(x==y), handles.user_data.reconstr3d_inpaint_output_params, params)))
            
            % get parameters and run inpainting
            params = inpaintingFunc('createInputParamsCell', scale_value);
            [ inpainted_im input_im inpaint_mask ] = inpaintingFunc('inpainting', handles.user_data.input_im, handles.user_data.input_mask, params, handles );
            
            % store result
            handles.user_data.reconstr3d_inpaint_output_params = params;
            handles.user_data.reconstr3d_inpaint_output = {inpainted_im, input_im, inpaint_mask};
        end
        
        % only replace the pixels in the high-res original image which were
        % inpainted into
        res_inpaint = imresize(handles.user_data.reconstr3d_inpaint_output{1}, [size(handles.user_data.input_im,1) size(handles.user_data.input_im,2)]);
        res_mask = imresize(handles.user_data.reconstr3d_inpaint_output{3}, size(handles.user_data.input_mask));
        res_mask = imdilate(res_mask, strel('disk',1));
        res_mask = repmat(res_mask,[1 1 3]);
        reconstr_im(res_mask) = res_inpaint(res_mask);
    end
    
    % run the 3D reconstruction
    params = reconstr3dFunc('createInputParamsCell', preprocess_inpainting);
    [ vrml_filepath medsup_filepath ] = reconstr3dFunc('reconstr3d', reconstr_im, params, handles );
    
    % store output of 3D reconstruction
    handles.user_data.reconstr3d_vrml_output = {vrml_filepath, medsup_filepath};
    handles.user_data.reconstr3d_vrml_output_params = params;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % active view button
    set(handles.pushbutton_3dreconstr_vrml, 'Enable','on');
    
    % view resulting VRML
    viewVRMLFunc('viewVRML', handles.user_data.reconstr3d_vrml_output{1}, handles);
end


% --- Executes on 3D reconstruction button click
function pushbutton_3dreconstr_view_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    viewVRMLFunc('viewVRML', handles.user_data.reconstr3d_vrml_output{1}, handles);
end