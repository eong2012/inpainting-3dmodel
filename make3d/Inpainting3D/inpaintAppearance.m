function [ img ] = inpaintAppearance( Default, img, SupEpand, div_newfgmaskidx, lr_sups )
%INPAINTAPPEARANCE Summary of this function goes here
%   Detailed explanation goes here
    
    % resize the mask and the image
    img = imresize(img, Default.InpaintingScale);
    SupEpand = imresize(SupEpand, [size(img,1), size(img,2)], 'nearest');
    
    curr_done = 0;
    
    % iterate over all old SPs
    for orig_sup_idx = 1:length(div_newfgmaskidx)
        % iterate over all newly divided SPs
        for new_sup_idx = 1:length(div_newfgmaskidx{orig_sup_idx})
            fprintf('\n\t\tInpainting SP %d/%d using only L/R SPs', curr_done+1, length(horzcat(div_newfgmaskidx{:})));
            
            sp_idx = div_newfgmaskidx{orig_sup_idx}(new_sup_idx);
            curr_lr_sups = lr_sups{orig_sup_idx}{new_sup_idx};
            
            % get all the unique SPs on the left and right
            curr_lr_sups = unique(curr_lr_sups);
            curr_lr_sups(curr_lr_sups == -1) = [];
            
            % make the masks for src SPs and the new dst SP
            inpaint_dst = SupEpand == sp_idx;
            inpaint_src = ismember(SupEpand, curr_lr_sups);
            
            % call the inpainting algo
            img = inpaint(img, [0 0 0], inpaint_src, inpaint_dst);
            
            curr_done = curr_done + 1;
        end
    end
end

