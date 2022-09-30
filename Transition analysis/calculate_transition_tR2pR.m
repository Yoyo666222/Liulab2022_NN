function trans_fluo = calculate_transition_tR2pR(c,t1,t2,states,fluo)

trans_fluo = [];
arem_idx = find(states == 0);
rrem_idx = find(states == 1);
trem_idx = find(states == 1); %弃用 若要用，改掉数字
prem_idx = find(states==4);


switch c
    case 'TonicREM_to_PhasicREM'
        pre_idx = trem_idx;
        post_idx = prem_idx;
    case 'qREM_to_ActiveREM'
        pre_idx = rrem_idx;
        post_idx = arem_idx;
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