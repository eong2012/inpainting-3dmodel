function [ varargout ] = ourReconstr3DGuiCallbacks( varargin )
% callbacks for our 3D-reconstruction GUI
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end

% --- Executes on 3D reconstruction button click
function pushbutton_our3dreconstr_exec_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % deactive view VRML button
    set(handles.pushbutton_our3dreconstr_vrml, 'Enable','off');
    set(handles.pushbutton_our3dreconstr_image, 'Enable','off');
    
    reconstr_im = handles.user_data.input_im;
    
    % run the 3D reconstruction
    params = ourReconstr3dFunc('createInputParamsCell');
    [ vrml_filepath output_filepath medsup_filepath ] = ourReconstr3dFunc('reconstr3d', handles.user_data.input_im, handles.user_data.input_mask, params, handles );
    
    % store output of 3D reconstruction
    handles.user_data.ourreconstr3d_vrml_output = {vrml_filepath, output_filepath, medsup_filepath};
    handles.user_data.ourreconstr3d_vrml_output_params = params;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % active view button
    set(handles.pushbutton_our3dreconstr_vrml, 'Enable','on');
    set(handles.pushbutton_our3dreconstr_image, 'Enable','on');
    
    % show the image
    inp_out = imread(handles.user_data.ourreconstr3d_vrml_output{2});
    fig_h = figure('Name','Our 3D inpainting Output'); imshow(inp_out);
    set(fig_h, 'units', 'pixels', 'position', [100 100 size(inp_out,2) size(inp_out,1)], 'paperpositionmode', 'auto');
    set(get(fig_h,'CurrentAxes'), 'position', [0 0 1 1], 'visible', 'off');
    
    % view resulting VRML
    viewVRMLFunc('viewVRML', handles.user_data.ourreconstr3d_vrml_output{1}, handles);
end


% --- Executes on view VRML button click
function pushbutton_our3dreconstr_view_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    viewVRMLFunc('viewVRML', handles.user_data.ourreconstr3d_vrml_output{1}, handles);
end


% --- Executes on view inpainting button click
function pushbutton_our3dreconstr_image_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % show the image
    inp_out = imread(handles.user_data.ourreconstr3d_vrml_output{2});
    fig_h = figure('Name','Our 3D inpainting Output'); imshow(inp_out);
    set(fig_h, 'units', 'pixels', 'position', [100 100 size(inp_out,2) size(inp_out,1)], 'paperpositionmode', 'auto');
    set(get(fig_h,'CurrentAxes'), 'position', [0 0 1 1], 'visible', 'off');
end