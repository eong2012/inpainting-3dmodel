function updateAxes(handles, threshold)
%UPDATEAXES Summary of this function goes here
%   Detailed explanation goes here

    [ all_axes_h ] = globalAxesUtils('getAllAxesHandlesSorted', handles);

    % iterate over all axes
    for idx = 1:length(all_axes_h)
        curr_axes_h = all_axes_h(idx);

        % bottom most handle is the background image if:
%         has_features = ~isempty(handles.user_data.user_images(idx).values);

        % if feature not available then nothing to do
%         if ~has_features
%             continue;
%         end

        % delete previous overlay images
        globalAxesUtils('deleteOverlayImages', handles, idx);

        % delete any text on the axes
        delete(findall(handles.inpainting3d_gui, 'Tag',[handles.gui_data.axes_txt_prefix num2str(idx)]));

        tag_name = get(curr_axes_h, 'Tag');

%         if ~isempty(handles.user_data.user_images(idx).im1)
            hold(curr_axes_h, 'on');
%         end

        % display the FG mask
        image(handles.user_data.display_mask, 'AlphaData',threshold, 'Parent',curr_axes_h, 'Tag',[handles.gui_data.mask_tag_prefix num2str(idx)]);

        set(curr_axes_h, 'DataAspectRatio', [1 1 1], 'Box','off', 'XColor',get(handles.inpainting3d_gui,'Color'), 'YColor',get(handles.inpainting3d_gui,'Color'), ...
                    'Units','pixels', 'Tag',tag_name, 'XTick',[], 'YTick',[], 'ZTick',[]);


        % SORT the images on the axes

        % get all children
        c = get(curr_axes_h, 'Children');

        % get background image
        im_h = findall(curr_axes_h, 'Tag',[handles.gui_data.im_tag_prefix num2str(idx)]);

        % get boundary image
        mask_h = findall(curr_axes_h, 'Tag',[handles.gui_data.mask_tag_prefix num2str(idx)]);

        % rest of the images
        remaining_h = findall(c, 'Type', 'image');    % filter out any thing other than images
        remaining_h(ismember(remaining_h, [im_h mask_h])) = [];

        % set the image order
        set(curr_axes_h, 'Children', [mask_h; remaining_h; im_h]);
    end
end
