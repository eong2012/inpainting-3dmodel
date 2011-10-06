function [ PlanePara ] = inpaintAlpha( Default, PlanePara, Sup2Para, SupEpand, div_newfgmaskidx, lr_sups )
%INPAINTALPHA Summary of this function goes here
%   Detailed explanation goes here
    
    % iterate over all old SPs
    for orig_sup_idx = 1:length(div_newfgmaskidx)
        % iterate over all newly divided SPs
        for new_sup_idx = 1:length(div_newfgmaskidx{orig_sup_idx})
            sp_idx = div_newfgmaskidx{orig_sup_idx}(new_sup_idx);
            curr_lr_sups = lr_sups{orig_sup_idx}{new_sup_idx};
            
            % average the SPs on the left and 
            l_sups = curr_lr_sups(:,1);
            l_sups(l_sups == -1) = [];
            lplanepara = PlanePara(:,full(Sup2Para(1,l_sups)));
            lplanepara = mean(lplanepara,2);
            
            % average the SPs on the right and 
            r_sups = curr_lr_sups(:,2);
            r_sups(r_sups == -1) = [];
            rplanepara = PlanePara(:,full(Sup2Para(1,r_sups)));
            rplanepara = mean(rplanepara,2);
            
            assert(~(any(isnan(lplanepara)) && any(isnan(rplanepara))), 'No SPs exist on both left and right!?');
            
            if any(isnan(lplanepara))
                lplanepara = rplanepara;
            end
            
            if any(isnan(rplanepara))
                rplanepara = lplanepara;
            end
            
            % average the alpha from left and right
            PlanePara(:,full(Sup2Para(1,sp_idx))) = mean([lplanepara rplanepara],2);
        end
    end
end

