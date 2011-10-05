function [ new_sup ] = adjustSup( sup, fgmask )
% This function makes sure that the SPs follow the foreground boundaries
%   This function also makes sure all connected components in FG are merged 
%   into one SP

    [labels num_labels] = bwlabel(fgmask);
    
    max_sup = max(sup(:));
    
    % iterate over all FG labels
    for lbl_idx = 1:num_labels
        region = labels == lbl_idx;
        not_region = ~region;

        max_sup = max_sup + 1;
        sup(region) = max_sup;
        
%         unique_sup = unique(sup(region))';
%         
%         % check each SP
%         for sup_idx = unique_sup
%             % check how many pixels for each SP in this FG are inside and
%             % outside
%             sup_region = sup == sup_idx;
%             inside = nnz(sup_region & region);
%             outside = nnz(sup_region & not_region);
%             
%             % check if enough pixel for this SP are inside and outside
%             if inside > 5 && outside > 5
%                 % break the inside of the SP into a separate SP
%                 sup(sup_region & region) = max_sup + 1;
%                 max_sup = max_sup + 1;
%             end
%         end
    end
    
    % reassign labels
    [sups, SortVec] = sort(sup(:));
    UV(SortVec) = ([1; diff(sups)] ~= 0);
    supus = sup(UV);
    
%     
%            SparseIndex = sparse(sups(end),1);
%            SparseIndex(Unique_a) = 1:size(Unique_a);
%            MedSup = full(SparseIndex(a));
           
    new_sup = sup;
    for idx = 1:length(supus)
        new_sup(sup == supus(idx)) = idx;
    end
end

