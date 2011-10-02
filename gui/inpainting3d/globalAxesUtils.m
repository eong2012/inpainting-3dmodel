function [ varargout ] = globalAxesUtils( varargin )
% functions pertaining to adjusting axes
%   first parameter should be the function name; following that all
%   parameters are sent as parameters to the function

    if nargout(varargin{1}) > 0
        [varargout{1:nargout(varargin{1})}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
end


function [ all_axes_h ] = getAllAxesHandlesSorted(handles)
    % find all the axes
    all_axes_h = findall(handles.inpainting3d_gui, '-regexp', 'Tag', handles.gui_data.axes_search_re)';

    if length(all_axes_h) > 1
        % sort by axes no.
        [temp sorted_idx] = sort(cellfun(@(x) str2num(x{1}{1}), regexp(get(all_axes_h, 'Tag'), '(\d+)$', 'tokens')));
        all_axes_h = all_axes_h(sorted_idx);
    end
end


function setBgImageForAllAxes( handles )
% sets the background image to all the axes and assigns the context menu to
%   that image

    a = findall(handles.inpainting3d_gui, '-regexp', 'Tag', handles.gui_data.axes_search_re);
    for axes_idx = 1:length(a)
        setBgImageForAxes( handles, axes_idx );
    end
end


function setBgImageForAxes( handles, axes_idx )
% sets the background image to all the axes and assigns the context menu to
%   that image

    axes_handle = handles.([handles.gui_data.axes_tag_prefix num2str(axes_idx)]);

    tag_name = get(axes_handle, 'Tag');
    
    % delete all axes children recursively
    globalGuiUtils('recursiveHandleDelete', get(axes_handle, 'Children'));

    image(handles.user_data.input_im, 'Parent', axes_handle, 'Tag',[handles.gui_data.im_tag_prefix num2str(axes_idx)]);
    % set the axes properties
    set(axes_handle, 'DataAspectRatio', [1 1 1], 'Box','off', 'XColor',get(handles.inpainting3d_gui,'Color'), 'YColor',get(handles.inpainting3d_gui,'Color'), ...
                'Units','pixels', 'Tag',tag_name, 'XTick',[], 'YTick',[], 'ZTick',[]);
end



function deleteOverlayImages(handles, axes_no)
    curr_axes_h = handles.([handles.gui_data.axes_tag_prefix num2str(axes_no)]);
    c = get(curr_axes_h, 'Children');

    c = findall(c, 'Type', 'image');    % filter out any thing other than images

    if ~isempty(c)
        % check if there is a background image
        has_background = ~isempty(handles.user_data.input_im);

        % get list of handles to delete
        del_handles = c(1:end-has_background);
        del_handles = del_handles(ishandle(del_handles));

        % delete the handles to the overlay images
        delete(del_handles);
    end
end