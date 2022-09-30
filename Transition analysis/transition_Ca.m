
warning off;
root_path = 'F:\photometry data_OFC\transition_analysis\';
target_ch = 'RSC';

% frames
pre =60;
post = 60;

transitions = {'wake_nrem', 'nrem_wake', 'nrem_trem','trem_wake', 'trem_prem', 'prem_wake'};
norm = 1;

% struct for transition Ca data
fluo_transitions = struct;
for tr = 1:length(transitions)
    fluo_transitions.(char(transitions(tr))) = [];
end

files = dir([root_path, '\*ICA*.mat']);

for i = 1:files
    temp = files(i).name;
    data = load([root_path, '\', temp]);
    bs = data.bs; % brain state data
    fluo_signal = data.(target_ch);
   for tr = 1:length(transitions)
       temp = calculate_transition_fluo(char(transitions(tr)),pre,post,bs,fluo_signal);
       fluo_transitions.(char(transitions(tr))) = [fluo_transitions.(char(transitions(tr))); temp];
   end
end

fig1 = figure;

% 根据IC来画transition的图

for tr = 1:length(transitions)
    subplot(3,2,tr); hold on
    yyy = fluo_transitions.(char(transitions(tr)));
    mean_tr = nanmean(yyy, 1);
    std_tr = nanstd(yyy,1)/sqrt(size(yyy,1)-1);

x = [1:pre+post];
fill([x fliplr(x)],[mean_tr+std_tr fliplr(mean_tr-std_tr)], [0.8 0.8 0.8])
hold on
plot(mean_tr, 'LineWidth',2)
title(char(transitions(tr)),'Interpreter', 'none', 'FontSize', 20)
%plot([pre+0.5 pre+0.5], [-1 2], 'r--')
%ylim([0.90 1.05])
xlim([1 pre+post+1])
set(gca, 'xTick', [1,pre+1,pre+post], 'xTickLabel', [-pre, 0, post])
end
 saveas(fig1, [root_path, ['\',  target_ch, '.png']])
