function trans_fluo = calculate_transition_fluo2(c,t1,t2,states,fluo)

trans_fluo = [];
w_idx = find(states == 2);
s_idx = find(states == 3);
r_idx = find(states == 1);


switch c
    case 'nrem_rem'
        pre_idx = s_idx;
        post_idx = r_idx;
    case 'wake_nrem'
        pre_idx = w_idx;
        post_idx = s_idx;
    case 'nrem_wake'
        pre_idx = s_idx;
        post_idx = w_idx;    
    case 'rem_wake'
        pre_idx = r_idx;
        post_idx = w_idx;
end

        tmp = post_idx -1;
        t_time = intersect(pre_idx,tmp);
%       wst = intersect(wst, In_idx);


%t = 10;
for i = 1:length(t_time)
%    if ~ismember(l_idx, [wst(i)-t: wst(i)+2*t]) 
        if t_time(i)+t2 < length(fluo) && t_time(i)-t1+1>0
            pre = intersect([t_time(i)-t1+1:t_time(i)+1], pre_idx);
            
        %switch c
            if length(pre) < t1
                trans_pre = [nan(1,t1-length(pre)) fluo(pre)];
            else
            trans_pre = fluo(pre);
            end

            post = intersect([t_time(i)+1:t_time(i)+t2], post_idx);
            if length(post) < t2
                trans_post = [fluo(post) nan(1,t2-length(post))];
            else
            trans_post = fluo(post);
            end
            
      trans =  [trans_pre trans_post];
%       if ~isempty(trans)
%       trans = trans/(mean([trans_pre(end); trans_post(1)]));
%       end
      %z_spikesd([round((wst(i)-t): round((wst(i)+ t)))]);
%  plot (trans_fr)
      trans_fluo  = [trans_fluo; trans];
      
        end
%    end
end
end