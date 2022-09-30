%% This code is for analzing the IC forescnece value across states
%% First part: single trial analysis
% First version done on 20210720 by DYF

% 1. load raw imaging data
% load('F:\Wide-field_imaging\20210330_data_analysis\down_size_cropped_raw.mat');
% edited on 20211026:
% load: ICAdata (including df_f_raw); brainstates; IC_plots.

%% transfer the data to realtive value to the whole space
% rawdata = cell2mat(struct2cell(imagestack));
% rawdata = double(rawdata);

% for df/f
% df_f= permute(cell2mat(struct2cell(processed_signal_470)),[2 3 1] );
% rawdata = df_f;

% for rawdata
% rawdata = double(cell2mat(struct2cell(imagestack)));

% load data from IC analysis
rawdata = df_f_raw;
imagesize = [size(rawdata,1), size(rawdata,2)];
rawdata_reshape = reshape(rawdata, [imagesize(1)*imagesize(2), size(rawdata,3)]);

% if there is decay in the trace, do detrend or highpass first
% rawdata_reshape = highpass(rawdata_reshape, 0.0002, 10);



%% 2. load IC data and brain states
label = labels(:,1);   % take the three brain states out
label = imresize(label, [size(rawdata_reshape,2),1], 'nearest');

%% use ICA_idx and rf to make ICtrace matrix
% now one raw of IC trace means one IC rf across time
% 这一段太繁琐了，整理一下搞成function
% 可以写：load IC_overlay然后每一个region出现一行字，将输入作为值

%IC index manually added
pRSC_IC = [12]; % for #90_129: use left pRSC
aRSC_IC = [14];
% RSC_IC = [40 33];
PPC_IC = [35];
VisualC_IC = [25 23];
pS1BC_IC = [10 32 27 2];
aS1BC = [11 3 29 19];
S1HL = [9 20];
M1_IC = [18 15 13 8 7];
M2_IC = [17];
ACC = [30];
M1orS1FL = [33 26];
FrA = [21 24];


ICs = {pRSC_IC,aRSC_IC, PPC_IC, VisualC_IC, pS1BC_IC,aS1BC,S1HL,M1_IC, M2_IC,ACC, M1orS1FL, FrA };  %need to modify

ICtrace = [];
data = rawdata_reshape; % calculate df/f

for i = 1: length(ICs)
    IC = IC_mean(ICs{i}, data, int_ICA, ICA_idx);
    ICtrace = [ICtrace; IC];
    clear IC;
end


% rf = []; % relative forescence
% for i = 1: size(ICtrace,2)  % rawdata: width * height * time  对每个时间点进行平均值计算
%     mean_data = mean(rawdata_reshape(~isnan(int_ICA),i),1);     %这个地方不能取所有pixel的活动，而是要取所有IC的活动
%     for j = 1: size(ICtrace,1) % rawdata_reshape: pixels * time
%        rf(j,i) = ICtrace(j,i) / mean_data;   %%这个地方如果不减去mean_data最后可能会出现有正有负的状态
%     end
% end


%% calculate z-score (optional)
zsocre = [];
tic;                                % tic;与toc;配合使用能够返回程序运行时间
bar = waitbar(0,'读取数据中...');    % waitbar显示进度条
len = size(rawdata_reshape,1);
for j = 1:size(rawdata_reshape,1)
    average = mean(rawdata_reshape(j,:),2);
    std = std(rawdata_reshape(j,:));
    for i = 1:size(rawdata_reshape,2)
        zsocre(j,i) = (rawdata_reshape(j,i) - average)/std;
    end
    clear average std;
    disp([num2str(j)]);
    str=['计算中...',num2str(100*j/len),'%'];    % 百分比形式显示处理进程,不需要删掉这行代码就行
    waitbar(j/len,bar,str);                       % 更新进度条bar，配合bar使用
end
clear i j;
close(bar);
toc;
data = zsocre;

ICtrace = [];
for i = 1: length(ICs)
    IC = IC_mean(ICs{i}, data, int_ICA, ICA_idx);
    ICtrace = [ICtrace; IC];
    clear IC;
end


%% Separate the IC_trace by states
% use rf: spatial relative activity; use ICtrace: df_f
trace = ICtrace;
%trace = rf;
Wake_IC_trace = trace(:,label==2);
NREM_IC_trace = trace(:,label==3);
REM_IC_trace = trace(:,label==1);

wake_IC = nanmean(Wake_IC_trace, 2);
NREM_IC = nanmean(NREM_IC_trace, 2);
REM_IC = nanmean(REM_IC_trace,2);

%% plotting
% color setting
color = [.85,.93,.2;...
    .82,.87,.84;...
    .66,.8,.37;...
    .73,.86,.64;...
    .39,.6,.24;...
    .26,.51,.08;...
    .15,.58,.25;...
    .43,.61,.94;...
    .61,.71,.9;...
    .11,.26,.55;...
    .64,.54,.17;...
    ]
IC_name = {'pRSC','aRSC','PPC','Vis','pS1BC','aS1BC','S1HL','M1','M2','ACC','M1/S1FL','FrA'};

% single trial plotting
y = [wake_IC'; NREM_IC'; REM_IC'];
figure('position', [81.8,552.2,1960.8,497.8]);
b = bar(y);
grid on;
set(gca,'XTickLabel',{'Wake','NREM', 'REM'});
legend('pRSC','aRSC','PPC','Vis','pS1BC','aS1BC','S1HL','M1','M2','ACC','M1/S1FL','FrA'	);
%ylabel('Z-score');
ylabel('df/f');
for k = 1: size(y,2)
    b(k).FaceColor = color(k,:);
end

savefig('df_f.fig');
%savefig('z-score.fig');


% for df/f
%save(['#76_20210513_ICA_statistics.mat'], 'df_f','label', 'ICs','IC_name', 'ICtrace', 'int_ICA', 'ICA_idx', 'wake_IC', 'NREM_IC', 'REM_IC' ,'-v7.3');

% for raw data
%% save data
save(['#90_20211129_ICA_statistics.mat'], 'rawdata_reshape','label', 'ICs','IC_name', 'ICtrace', 'int_ICA', 'ICA_idx', 'wake_IC', 'NREM_IC', 'REM_IC' ,'-v7.3');


%% Second part: across trial statistics

% unbiaed treat with different sessions
wake_ICs = [];
NREM_ICs = [];
REM_ICs = [];

wake_ICs = [wake_ICs, wake_IC];
NREM_ICs = [NREM_ICs, NREM_IC];
REM_ICs = [REM_ICs, REM_IC];

%% Plotting
% Across trial plotting
y1 = [mean(wake_ICs',1); mean(NREM_ICs',1); mean(REM_ICs',1)];
y2 = [std(wake_ICs',1)/sqrt(size(wake_ICs,2)); std(NREM_ICs',1)/sqrt(size(NREM_ICs,2)); std(REM_ICs',1)/sqrt(size(REM_ICs,2))];
h1 = figure('position', [3.4,630,1986.4,420]);
set(gca,'Fontname','Times New Roman','Fontsize',20, 'FontWeight', 'bold');
b = bar(y1, 'Grouped', 'LineWidth', 2);
grid on;
set(gca,'XTickLabel',{'Wake','NREM', 'REM'});

ylabel('Z-score');
%ylabel('df/f');

for k = 1: size(y,2)
    b(k).FaceColor = color(k,:);
end
hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(y1);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',y1, y2,'k','linestyle','none', 'LineWidth', 2);
hold off
%legend('V1','S1', 'pRSC', 'aRSC', 'PPC', 'M1', 'M2');
legend('RSC','PPC','Vis','pS1BC','aS1BC','S1HL','M1','M2','ACC','M1/S1FL','FrA'	);

title('Averaged activity of ICs across states');

%% Scatter plot
y = (REM_ICs-NREM_ICs)./(REM_ICs+NREM_ICs);
x = (REM_ICs-wake_ICs)./(REM_ICs+wake_ICs);

% y = (REM_IC-NREM_IC)./(REM_IC+NREM_IC);
% x = (REM_IC-wake_IC)./(REM_IC+wake_IC);

figure();
for p = 1:size(x,2)
    scatter(x(:,p), y(:,p));
    hold on;
end
xli = xlim;
yli = ylim;
plot(linspace(xli(1),xli(2),100), repelem(0,100), 'k');
hold on;
plot(repelem(0,100), linspace(yli(1),yli(2),100), 'k');
hold off;
clear xli yli;
xlabel('R-W/R+W');
ylabel('R-NR/R+NR');


%% z-score calculation



%% z-score scatter plot
x = REM';
y = (REM-wake)';

marker = char('+', 'o', '*');

% y = (REM_IC-NREM_IC)./(REM_IC+NREM_IC);
% x = (REM_IC-wake_IC)./(REM_IC+wake_IC);

figure();
q=1;
for p = 1:size(x,2)
%     for q = 1:size(x,1)
        h(q,p) = scatter(x(q,p), y(q,p),[80], color(p,:), 'filled','o');
        hold on;
%     end
end
q = q+1;
for p = 1:size(x,2)
%     for q = 1:size(x,1)
        h(q,p) = scatter(x(q,p), y(q,p),[80], color(p,:),'+','LineWidth',2);
        hold on;
%     end
end
q = q+1;
for p = 1:size(x,2)
%     for q = 1:size(x,1)
        h(q,p) = scatter(x(q,p), y(q,p),[80], color(p,:),'*','LineWidth',2);
        hold on;
%     end
end


xli = xlim;
yli = ylim;
plot(linspace(xli(1),xli(2),100), repelem(0,100), 'k');
hold on;
plot(repelem(0,100), linspace(yli(1),yli(2),100), 'k');
hold off;
clear xli yli;
xlabel('REM activity');
ylabel('REM - Wake / REM + Wake');
legend(h(1,:),'RSC','PPC','Vis','pS1BC','aS1BC','S1HL','M1','M2','ACC','M1/S1FL','FrA');
title('Scatter plot of IC activity during REM and wake state');



%%
% % use time point to average (not appropriate)
% % step1: load ICtrace, rf and label from each session
% % step2: gather all ICtrace and label together respectively
% % step3: find the onset and offset point about three states
% % step4 (not sure): in every state, for every couple of onset and offset
% % point, calculate the weighted mean and std (how) of every sessions, and
% % plot them with errorbar.
% % Alternative step4: use timepoint to do the mean and std.
%
%
% % Step1&2
% IC_traces = [];
% label_all = [];
% rfs = [];
%
% % 循环
% IC_traces = [IC_traces, ICtrace];
% label_all = [label_all; label];
% rfs = [rfs, rf];
%
% % Step3

% change the original order (#58-0330, #67-0512, #76-0513)
wake_IC = wake_IC([4,7, 1, 2, 3, 5, 6],:);
REM_IC = REM_IC([4, 7, 1, 2, 3, 5, 6],: );
NREM_IC = NREM_IC([4, 7, 1, 2, 3, 5, 6],: );

wake_IC = wake_IC([4,11,10,9,1,2,3,8,6,5,7],:);
REM_IC = REM_IC([4,11,10,9,1,2,3,8,6,5,7],: );
NREM_IC = NREM_IC([4,11,10,9,1,2,3,8,6,5,7],: );






