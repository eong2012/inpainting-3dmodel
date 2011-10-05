function [ varargout ] = globalGuiUtils( varargin )
% utils to set GUI
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    % evaluate function according to the number of inputs and outputs
    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function [ handles ] = initGui( handles, hObject, eventdata )
    % create the main axes and its overlay text
    axes_tag = [handles.gui_data.axes_tag_prefix '1'];
    
    % create the main axes and paint the test on top of it
    h1 = axes('Parent',handles.inpainting3d_gui, ...
              'Box', 'on', ...
              'Units','pixels', ...
              'Position',handles.gui_data.axes_loc(1,:), ...
              'YDir','reverse',...
              'Tag',axes_tag, ...
              'XTick', [], ...
              'YTick', [], ...
              'ZTick', []); 
          
    text(0.5,0.5, ['{\color{red}3D inpainting}'], ...
                   'Tag',[handles.gui_data.axes_txt_prefix '1'], ...
                   'FontSize',12, ...
                   'FontWeight','bold', ...
                   'HorizontalAlignment','center', ...
                   'VerticalAlignment','middle');
               
    handles.(axes_tag) = h1;
    
    % set callbacks to all buttons
    set(handles.pushbutton_loadim, 'Callback',@(hObject,eventdata) buttonCallbacks('btn_load_im_Callback', hObject, eventdata, guidata(hObject)));
    set(handles.pushbutton_fgmask, 'Callback',@(hObject,eventdata) buttonCallbacks('btn_load_mask_Callback', hObject, eventdata, guidata(hObject)));
    
    % Set callbacks for slider_im_fg
    set(handles.slider_im_fg, 'Callback', @(hObject,eventdata) imfgSliderCallbacks('imfg_slider_Callback', hObject, eventdata, guidata(hObject)) );
    set(handles.slider_im_fg, 'CreateFcn', @(hObject,eventdata) imfgSliderCallbacks('imfg_slider_CreateFcn', hObject, eventdata, guidata(hObject)) );
    addlistener(handles.slider_im_fg, 'Action', @(hObject,eventdata) imfgSliderCallbacks('imfg_slider_Action', hObject, eventdata, guidata(hObject)) );
    
    % Set callbacks for the inpainting GUI
    set(handles.edit_inpainting_scale, 'Callback', @(hObject,eventdata) inpaintingGuiCallbacks('scale_text_Callback', hObject, eventdata, guidata(hObject)) );
    set(handles.edit_inpainting_scale, 'CreateFcn', @(hObject,eventdata) inpaintingGuiCallbacks('scale_text_CreateFcn', hObject, eventdata, guidata(hObject)) );
    set(handles.pushbutton_inpainting_exec, 'Callback', @(hObject,eventdata) inpaintingGuiCallbacks('pushbutton_inpainting_exec_Callback', hObject, eventdata, guidata(hObject)) );
    set(handles.pushbutton_save_inpainting, 'Callback', @(hObject,eventdata) inpaintingGuiCallbacks('pushbutton_inpainting_save_Callback', hObject, eventdata, guidata(hObject)) );
    
    % Set callbacks for 3D reconstruction GUI
    set(handles.checkbox_3dreconstr_inp, 'Callback', @(hObject,eventdata) reconstr3DGuiCallbacks('inpainting_checkbox_Callback', hObject, eventdata, guidata(hObject)) );
    set(handles.edit_3dreconstr_inp_scale, 'Callback', @(hObject,eventdata) reconstr3DGuiCallbacks('scale_text_Callback', hObject, eventdata, guidata(hObject)) );
    set(handles.edit_3dreconstr_inp_scale, 'CreateFcn', @(hObject,eventdata) reconstr3DGuiCallbacks('scale_text_CreateFcn', hObject, eventdata, guidata(hObject)) );
    set(handles.pushbutton_3dreconstr_exec, 'Callback', @(hObject,eventdata) reconstr3DGuiCallbacks('pushbutton_3dreconstr_exec_Callback', hObject, eventdata, guidata(hObject)) );
    set(handles.pushbutton_3dreconstr_vrml, 'Callback', @(hObject,eventdata) reconstr3DGuiCallbacks('pushbutton_3dreconstr_view_Callback', hObject, eventdata, guidata(hObject)) );
    
    % reset to the state when a new image is being loaded
    [ handles ] = guiDataResetBeforeNewIm(handles);
end


function [ handles ] = guiDataResetBeforeNewIm(handles)
    % disable all gui elements which can't be used right now
    
    % disable the slider objects
    enableDisableSliderImFG(handles, 0);
    
    % disable the inpainting objects
    enableDisableInpaintingPanel(handles, 0);
    
    % disable the 3D reconstruction objects
    enableDisable3DReconstrPanel(handles, 0);
    
    % disable the VRML button
    set(handles.pushbutton_openvrml, 'Enable','off');
    % disable the fg mask button
    set(handles.pushbutton_fgmask, 'Enable','off');
    
    % reset all the data
    [ handles ] = globalDataUtils('reInitImageData', handles );
    [ handles ] = globalDataUtils('reInitMaskData', handles );
    [ handles ] = globalDataUtils('reInitOutputs', handles );
end


function enableDisableSliderImFG(handles, enable)
% enable or disable the slider controls
    enable = enableParamConvert(enable);

    set(handles.slider_im_fg, 'Enable',enable);
    set(handles.text_slider_im, 'Enable',enable);
    set(handles.text_slider_fg, 'Enable',enable);
end


function enableDisableInpaintingPanel(handles, enable)
% enable or disable the slider controls
    
    enable = enableParamConvert(enable);
    recursiveHandleEnable(get(handles.uipanel_inpainting,'Children'), enable);
    
    % deactive save button
    set(handles.pushbutton_save_inpainting, 'Enable','off');
end


function enableDisable3DReconstrPanel(handles, enable)
% enable or disable the slider controls
    
    enable = enableParamConvert(enable);
    recursiveHandleEnable(get(handles.uipanel_reconstr3d,'Children'), enable);
    
    % deactive view VRML button
    set(handles.pushbutton_3dreconstr_vrml, 'Enable','off');
    
    % set inpainting checkbox elements accordingly
    if get(handles.checkbox_3dreconstr_inp, 'Value') && strcmp(get(handles.checkbox_3dreconstr_inp, 'Enable'),'on')
        set(handles.text_3dreconstr_inp_scaling, 'Enable','on');
        set(handles.edit_3dreconstr_inp_scale, 'Enable','on');
    else
        set(handles.text_3dreconstr_inp_scaling, 'Enable','off');
        set(handles.edit_3dreconstr_inp_scale, 'Enable','off');
    end
end


function [ enable ] = enableParamConvert(enable)
% simply converts enable param to on or off
    if enable
        enable = 'on';
    else
        enable = 'off';
    end
end


function recursiveHandleEnable(handle_list, enable)
% recursively (by going down the children tree) deletes all children handles in a list

    if isempty(handle_list)
        return;
    end
    
    % convert to row vector to deal with for loop
    handle_list = handle_list(:)';
    
    for hndl = handle_list
        if ishandle(hndl)
            children_hndls = get(hndl, 'Children');
            recursiveHandleDelete(children_hndls);
            if isfield(get(hndl), 'Enable')
                set(hndl, 'Enable',enable);
            end
        end
    end
end


function recursiveHandleDelete(handle_list)
% recursively (by going down the children tree) deletes all children handles in a list

    if isempty(handle_list)
        return;
    end

    % convert to row vector to deal with for loop
    handle_list = handle_list(:)';
    
    for hndl = handle_list
        if ishandle(hndl)
            children_hndls = get(hndl, 'Children');
            recursiveHandleDelete(children_hndls);
            delete(hndl);
        end
    end
end