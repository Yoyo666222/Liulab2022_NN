function trans_fluo = calculate_transition_ca(c,t1,t2,states,fluo)

trans_fluo = [];
w_idx = find(states == 2);
s_idx = find(states == 3);
trem_idx = find(states == 1);
prem_idx = find(states==4);


switch c
    case 'NREM_to_REM'
        pre_idx = s_idx;
        post_idx = trem_idx;
    case 'Wake_to_NREM'
        pre_idx = w_idx;
        post_idx = s_idx;
    case 'NREM_to_Wake'
        pre_idx = s_idx;
        post_idx = w_idx;    
    case 'REM_to_Wake'
        pre_idx = trem_idx;
        post_idx = w_idx;
    case 'trem_prem'
        pre_idx = trem_idx;
        post_idx = rem_idx;
    case 'prem_wake'
        pre_idx = prem_idx;
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
                continue
            else
            trans_pre = fluo(pre);
            end

            post = intersect([t_time(i)+1:t_time(i)+t2], post_idx);
            if length(post) < t2
                continue
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