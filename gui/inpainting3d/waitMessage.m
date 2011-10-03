function [ dlg ] = waitMessage( title, message, im, im_map )
%WAITMESSAGE Used to display a non-closable wait message over a modal 
%   dialog box

    % default values
    fig_size = [400 130];
    temp = get(0, 'ScreenSize');
    fig_position = temp([3 4])/2;
    
    % convert message to a cell array
    if ischar(message)
        message = {message};
    end
    
    
    % make the main figure
    dlg = dialog('Name', title, 'units','Pixels', 'Position',[fig_position-fig_size/2 fig_size], 'CloseRequestFcn',''); %, 'WindowStyle','non-modal'
    
    % make the axes for the image
    clr = get(dlg,'Color');
    ax = axes('Parent',dlg, 'Units','pixels', 'Position',[20 20 fig_size(2)-40 fig_size(2)-40], 'XTick',[], ...
        'YTick',[], 'ZTick',[], 'Box','off', 'YDir','reverse', 'XColor',clr, 'YColor',clr, 'Color',clr, 'Tag','axes_im');
    
    % display the image
    im_h = image('CData',im, 'Parent',ax);
    set(dlg, 'Colormap',im_map);
    axis(ax, 'equal');
    
    % make the uicontrol for holding the text
    h = uicontrol('Parent',dlg, 'Style','Text', 'Position',[fig_size(2) 40 fig_size(1)-fig_size(2)-20 fig_size(2)-80], 'String','', ...
        'FontSize',10, 'HorizontalAlignment','left', 'BackgroundColor',clr, 'Tag','txt_info');
    message = textwrap(h, message);
    set(h, 'String',message);
    
    drawnow;
end