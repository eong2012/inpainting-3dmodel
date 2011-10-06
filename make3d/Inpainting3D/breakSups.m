function [ PlanePara Sup2Para sup SupOri div_newfgmaskidx lr_sups ] = breakSups( Default, fgmaskidx, PlanePara, Sup2Para, sup, SupOri  )
% This function breaks each connected component foreground SP into multiple
%   SP at regular heights. The index of the first broken SP (starting from
%   the top) is the same as the original SP. All subsequent new SPs' 
%   indices follow the maximum SP index. The PlanePara for the new SPs are 
%   added as 0s. div_newfgmaskidx stores the indices for the newly broken
%   SPs. lr_sups stores the SPs on the left and right of each new SP.

    max_sp_id = size(Sup2Para,2);
    div_newfgmaskidx = {};
    lr_sups = {};
    
    % iterate over all the regions
    for lbl_idx = 1:length(fgmaskidx)
        region = sup == fgmaskidx(lbl_idx);
        div_newfgmaskidx{lbl_idx} = [];         % this will store the new SPs created
        lr_sups{lbl_idx} = {};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % divide the region into sub regions (new SPs) %
        height_reg = any(region, 2);
        min_h = find(height_reg, 1, 'first');
        max_h = find(height_reg, 1, 'last');
        h_divs = min_h:Default.DivideRegionHeight:max_h+1;
        if h_divs(end) ~= max_h+1
            h_divs(end+1) = max_h+1;
        end
        h_divs = [h_divs(1:end-1); h_divs(2:end)-1];
        
        rows = 1:size(region,1);
        curr_lbl = 0;
        
        % check if all SPs are connected components (if not break them further)
        for idx = 1:size(h_divs,2)
            temp_region = region;
            temp_region(~ismember(rows,h_divs(1,idx):h_divs(2,idx)), :) = 0;
            [regs numlabels] = bwlabel(temp_region);
            
            % iterate over every connected component
            for regidx = 1:numlabels
                curr_lbl = curr_lbl + 1;
                curr_sup_reg = regs == regidx;
                
                % renumber the SP (in both sup and SupOri)
                if idx > 1
                    max_sp_id = max_sp_id + 1;
                    sup(curr_sup_reg) = max_sp_id;
                    SupOri(curr_sup_reg) = max_sp_id;
                    div_newfgmaskidx{lbl_idx}(end+1) = max_sp_id;
                else
                    div_newfgmaskidx{lbl_idx}(end+1) = fgmaskidx(lbl_idx);
                end
                
                % collect the left and right superpixel
                valid_rows = find(any(curr_sup_reg,2))';
                lr_sups_curr = zeros(length(valid_rows),2);
                for r_idx = 1:length(valid_rows)
                    % find the left SP
                    lc_idx = find(curr_sup_reg(valid_rows(r_idx),:),1,'first')-1;
                    if lc_idx >= 1
                        lr_sups_curr(r_idx,1) = sup(valid_rows(r_idx),lc_idx);
                    else
                        lr_sups_curr(r_idx,1) = -1;
                    end
                    
                    % find the right SP
                    rc_idx = find(curr_sup_reg(valid_rows(r_idx),:),1,'last')+1;
                    if rc_idx <= size(curr_sup_reg,2)
                        lr_sups_curr(r_idx,2) = sup(valid_rows(r_idx),rc_idx);
                    else
                        lr_sups_curr(r_idx,2) = -1;
                    end
                end
                
                % store the SP left and right of the new SP
                lr_sups{lbl_idx}{end+1} = lr_sups_curr;
            end
        end
        
        % add the new SPs to the PlanePara and Sup2Para
        if curr_lbl > 1
            Sup2Para(end+1:end+curr_lbl-1) = size(PlanePara,2)+1:size(PlanePara,2)+curr_lbl-1;
            PlanePara(:,end+1:end+curr_lbl-1) = 0;
        end
        
        % also adjust the original SP's PlanePara to 0
        PlanePara(:,Sup2Para(1,fgmaskidx(lbl_idx))) = 0;
    end
    
end

