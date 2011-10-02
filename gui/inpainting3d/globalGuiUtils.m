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
    % disable the VRML button
    set(handles.pushbutton_openvrml, 'Enable','off');
    % disable the fg mask button
    set(handles.pushbutton_fgmask, 'Enable','off');
    
    % create the main axes and its overlay text
    axes_tag = [handles.gui_data.axes_tag_prefix '1'];
    
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
    enableDisableSliderImFG(handles, 0)
end


function enableDisableSliderImFG(handles, enable)
% enable or disable the slider controls
    if enable
        enable = 'on';
    else
        enable = 'off';
    end

    set(handles.slider_im_fg, 'Enable',enable);
    set(handles.text_slider_im, 'Enable',enable);
    set(handles.text_slider_fg, 'Enable',enable);
end


function recursiveHandleDelete(handle_list)
% recursively (by going down the children tree) deletes all children handles in a list

    if isempty(handle_list)
        return;
    end

    for hndl = handle_list
        if ishandle(hndl)
            children_hndls = get(hndl, 'Children');
            recursiveHandleDelete(children_hndls);
            delete(hndl);
        end
    end
end