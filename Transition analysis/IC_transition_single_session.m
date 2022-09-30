%% Statistics of one session (one recording)
% data needed: ICtrace(IC * df/f), label (brain states, length = imaging frames)
% this code is for analyze the transition activity of different ICs in a
% single session (one recording session)
clear all;

z_score = 1;
%% Load the data from ICA statistics and set file path
root_path = uigetdir();
file = dir([root_path,'\', '*ICA_statistics.mat']);
load([root_path,'\',file.name]);
subfolder = '\Transition_analysis';
save_folder = fullfile(root_path, subfolder);
if isempty(dir(save_folder))
    mkdir(save_folder);
end

 if z_score
     for i = 1:size(ICtrace,1)
         ICtrace(i,:) = (ICtrace(i,:)-mean(ICtrace(i,:)))/std(ICtrace(i,:));
     end
 end 
 
%% Set the parameters
% frames
Timew = 30; % 取前Timews的time window
Timewpost = 60 - Timew; %总共取一分半 取决于前后状态有多长
oldSR = 10; % imaging的采样频率为SRHz
SR = 10;
if oldSR~=SR
    ICtrace2 = [];
    for i = 1:size(ICtrace,1) 
       ICtrace2(i,:) = interp1(1/oldSR:1/oldSR:size(ICtrace,2)/oldSR, ICtrace(i,:), 1/SR:1/SR:size(ICtrace,2)/oldSR);
    end
    ICtrace = ICtrace2;
end 

label = imresize(label, SR/oldSR, 'nearest');

pre = Timew * SR; % 取transition time 前面100帧  改了SR Timew之后就不是了
post = Timewpost * SR;  % 取transition time 后面100帧
transitions = {'Wake_to_NREM', 'NREM_to_Wake', 'NREM_to_REM','REM_to_Wake'};
IC_name = {'pRSC','aRSC','PPC','Vis','pS1BC','aS1BC','S1HL','M1','M2','ACC','M1orS1FL','FrA'};

%% Construct the activity matrix
% struct for transition Ca data

 


fluo_transitions_allIC = {};  % constrct a cell contains every IC

for i = 1:size(ICtrace,1)  % for every IC
    fluo_transitions = struct;
    for tr = 1:length(transitions)
        fluo_transitions.(char(transitions(tr))) = [];
    end
   fluo_signal = ICtrace(i, :);
   for tr = 1:length(transitions)   % for every kind of transition
       temp = calculate_transition_ca(char(transitions(tr)),pre,post,label,fluo_signal);
       fluo_transitions.(char(transitions(tr))) = [fluo_transitions.(char(transitions(tr))); temp];
   end
   fluo_transitions_allIC{i} = fluo_transitions;
end

clear i tr;


%% Plotting the average traces for every kind of IC and every kind of transitions
% 根据IC来画transition的图
% 每个IC一个图，里面包含四种transition的情况
average_trace = {};

for i = 1: length(fluo_transitions_allIC)
    h = figure('NumberTitle', 'off', 'Name', char(IC_name{i}), 'position', [535.4,458.6,809.6,572]);
    for tr = 1:length(transitions)
        yyy = fluo_transitions_allIC{i}.(char(transitions(tr)));
        if ~isempty(yyy)
            subplot(2,2,tr);   % 记得把subplot数目改成transitions的总数
            hold on;
            % Normalize using the mean pre value
            for j = 1: size(yyy,1)
               yyy(j,:) = smooth(yyy(j,:));
               %average = mean(yyy(j,1:pre));
%               yyy(j,:) = (yyy(j,:) - average) / (max(yyy(j,:)) - min(yyy(j,:))) ;
               %yyy(j,:) = (yyy(j,:) - min(yyy(j,:))) / (max(yyy(j,:)) - min(yyy(j,:)));
            end
            
            mean_tr = nanmean(yyy, 1);
            std_tr = nanstd(yyy,1)/sqrt(size(yyy,1)-1);
            
            average_trace{i}.(char(transitions(tr))) = mean_tr;

            x = [1:pre+post];
            fill([x fliplr(x)],[mean_tr+std_tr fliplr(mean_tr-std_tr)], [0.8 0.8 0.8]);
            hold on;
            plot(mean_tr, 'LineWidth',2);
            xlabel('Time after state transition (s)', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            ylabel('Z-score', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            title(char(transitions(tr)),'Interpreter', 'none', 'Fontname','Times New Roman', 'FontSize', 15);
            %plot([pre+0.5 pre+0.5], [-1 2], 'r--')
            %ylim([-0.2 0.2]);
            xlim([1 pre+post+1]);
            set(gca, 'xTick', [1,pre+1,pre+post], 'xTickLabel', [-Timew, 0, Timewpost]);
            hold on;
            y1 = ylim;
            axis tight;
            plot((pre+1)*ones(1,100), linspace(y1(1),y1(2),100),'r', 'LineWidth',1); % draw a line at transition point
            clear y1 ylim;
        end
    end
     saveas(h, [save_folder, ['\',  char(IC_name{i}), '.png']]);
     saveas(h, [save_folder, ['\',  char(IC_name{i}), '.fig']]);
end

close all;

save([save_folder, ['\',  file.name(1:12),'transition_analysis', '.mat']], 'fluo_transitions_allIC',...
    'IC_name','Timew', 'Timewpost','transitions','average_trace','pre', 'post', '-v7.3');


% 根据transition类型来画
% 每一个图里包含不同IC的同一种transition类型

for i = 1: length(transitions)
    h = figure('NumberTitle', 'off', 'Name', char(transitions{i}), 'position', [38.6,773.8,1825.6,276.2]);
    for tr = 1:length(fluo_transitions_allIC)
        yyy = fluo_transitions_allIC{tr}.(char(transitions(i)));
        if ~isempty(yyy)
            subplot(2,ceil(length(IC_name)/2),tr);   % 记得把subplot数目改成transitions的总数
            hold on;
            % Normalize using the mean pre value
            for j = 1: size(yyy,1)
               yyy(j,:) = smooth(yyy(j,:));
               %average = mean(yyy(j,1:pre));
%               yyy(j,:) = (yyy(j,:) - average) / (max(yyy(j,:)) - min(yyy(j,:))) ;
               %yyy(j,:) = (yyy(j,:) - min(yyy(j,:))) / (max(yyy(j,:)) - min(yyy(j,:))) ;
            end
            
            mean_tr = nanmean(yyy, 1);
            std_tr = nanstd(yyy,1)/sqrt(size(yyy,1)-1);

            x = [1:pre+post];
            fill([x fliplr(x)],[mean_tr+std_tr fliplr(mean_tr-std_tr)], [0.9 0.9 0.9]);
            hold on;
            plot(mean_tr, 'LineWidth',2,'color', [0.48 0.78 0.35]);
            xlabel('Time after state transition (s)', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            ylabel('Z-score', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            title(char(IC_name(tr)),'Interpreter', 'none', 'Fontname','Times New Roman', 'FontSize', 15);
            %plot([pre+0.5 pre+0.5], [-1 2], 'r--')
            %ylim([-0.2 0.2]);
            xlim([1 pre+post+1]);
            set(gca, 'xTick', [1,pre+1,pre+post], 'xTickLabel', [-Timew, 0, Timewpost]);
            hold on;
            y1 = ylim;
            axis tight;
            plot((pre+1)*ones(1,100), linspace(y1(1),y1(2),100),'r', 'LineWidth',1); % draw a line at transition point
            clear y1 ylim;
        end
    end
     saveas(h, [save_folder, ['\',  char(transitions(i)), '.png']]);
     saveas(h, [save_folder, ['\',  char(transitions(i)), '.fig']]);
end

close all;

 






