function [IC] = IC_mean(idx, reshapedata, int_ICA, ICA_idx)

    idx_matrix = [];
    for i = 1:length(idx)
        idx_in_IC = reshapedata(int_ICA==find(ICA_idx==idx(i)), :);
        idx_matrix = [idx_matrix; idx_in_IC];
        IC = mean(idx_matrix,1);
    end

return
