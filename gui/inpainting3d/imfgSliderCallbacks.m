function [ varargout ] = imfgSliderCallbacks( varargin )
% callbacks for slider_im_fg
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


% --- Executes during object creation, after setting all properties.
function imfg_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end


% --- Executes on slider mouse button up.
function imfg_slider_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    %obtains the slider value from the slider component
    slider_value = get(handles.slider_im_fg, 'Value');

    %puts the slider value into the edit text component
    %set(handles.threshold_text, 'String', num2str(slider_value));

    % Update handles structure
    guidata(hObject, handles);

    updateAxes(handles, slider_value);
end


% --- Executes on slider's inbetween dragging movement.
function imfg_slider_Action(hObject, eventdata, handles)
    imfg_slider_Callback(hObject, eventdata, handles);
end