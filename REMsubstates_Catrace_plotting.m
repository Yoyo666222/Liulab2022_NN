%%% this code is for,or post-HOG analysis,,
%%% extract the substates initiation time point
%%% first version on 20211101 by DYF
clear all;
%%
files_fig  = dir('*corrHeatmap_*.fig');
for n = 1:length(files_fig)
    open(files_fig(n).name);
    fig = gcf;
    % Enable data cursor mode
    datacursormode on
    dcm_obj = datacursormode(fig);
    % Set update function
    set(dcm_obj,'UpdateFcn',@myupdatefcn)
    % Wait while the user to click
    disp('Click line to display a data tip, then press "Return"');
    
    % Export cursor to workspace
    i = str2num(files_fig(n).name(24:end-4));
    try
        pause
        info_struct = getCursorInfo(dcm_obj);
        loc_x(i) = info_struct.Position(1);   % 需要y的话就直接加n
        if isfield(info_struct, 'Position')
            fprintf('%.2f %.2f \n',info_struct.Position);
        end
    catch
        break;
        
    end
    close();
end

%如果认为这一段咩有aREM，则把点点在REM onset之前 即可

%% load the HOG analysis data file (containing REM onset and offset)
files = dir('*HOGanalysis_REM.mat');
load(files.name);
[remonset, remoffset] = find_onset_offset(label_video,1,1);
% manually read the onset point through the corrHeatmap
aREMpoint = loc_x;

%% transfer the aREM onset point to relate whole video length idx
aREMonset = [];

for j = 1:length(aREMpoint)
    start = int32(remonset(j) - round(FrameRate*20));  % 选REM前面20秒的NREM作为参考
    stop = int32(remoffset(j) + round(FrameRate*20));  % 选REM后面20秒的wake作为参考
    if aREMpoint(j) > round(FrameRate*20)
        aREMonset(j) = aREMpoint(j) + start;
    else
        aREMonset(j) = remoffset(j);
    end
    
end
clear j start stop;

%% Calculate the aREM length (optional for optogenetics analysis)
aREMdur = [];
for j = 1:length(aREMonset)
    if ~aREMonset(j)==0
        aREMdur(j) = remoffset(j) - aREMonset(j);
    else
        aREMdur(j) = 0;
    end
end
aREMdur(aREMdur<0) = 0;

aREMdur = aREMdur/FrameRate;

save(['aREMrelated.mat'],'aREMdur','aREMonset','aREMpoint','-v7.3');

%% Calculate the qREM length (optional for optogenetics analysis)
qREMdur = [];
for j = 1:length(aREMonset)
    if ~aREMonset(j)==0
        qREMdur(j) = aREMonset(j) - remonset(j);
    else
        qREMdur(j) = remoffset(j) - remonset(j);
    end
end

qREMdur = qREMdur/FrameRate;

save(['qREMrelated.mat'],'qREMdur','-v7.3');



%% Load the IC statistics data

load('#76_20210811_ICA_statistics.mat');
fps = 25;



%% Plot the IC trace of NREM, REM and point out the aREM initiation time
% transfer the aREMonset to correlate with imaging idx
preNan = length(find(isnan(label_video)));
aREMonset_imaging = round(length(label)*(aREMonset-preNan)/(length(label_video)-preNan));

% find rem onset and offset in imaging idx
[remonset, remoffset] = find_onset_offset(label, 1, 1);

%%
% set the start & stop point and ploting episode by episode
label_plot = {};
for j = 1:length(aREMonset_imaging)
    if ~aREMonset_imaging(j)==0
        start = remonset(j) - round(fps*10);  % 取REM前十秒的NREM
        stop =  remoffset(j) + round(fps*10);  % 取REM后十秒的wake
        label_plot{j} = [repelem(3,remonset(j) -start),...
            repelem(1,aREMonset_imaging(j) -remonset(j)+1),...
            repelem(0,remoffset(j) - aREMonset_imaging(j)+1),...
            repelem(2,stop - remoffset(j))];
        
        
        % plotting labels with IC raw traces
        figure();
        subplot(size(ICtrace,1)+1,1,1);
        imagesc(label_plot{j});
        for i = 1:size(ICtrace,1)
            subplot(size(ICtrace,1)+1,1,i+1);
            plot(ICtrace(i,start:stop),'g','LineWidth',2);
            ylim([-0.1 0.3]);
            xlim([0 stop-start+1]);
            axis off;
            
            
        end
    end
end

%% save files

%save(['REMsubstates.mat'], 'aREMonset_imaging', 'aREMonset','aREMpoint','-v7.3');

label_substates = label;
[remonset, remoffset] = find_onset_offset(label,1,1);
for i = 1:length(aREMonset_imaging)
    %if aREMonset_imaging(i) ~= 0
    if aREMonset_imaging(i) >remonset(i)
        label_substates(aREMonset_imaging(i):remoffset(i))=0;
    elseif aREMonset_imaging == remonset(i)
        label_substates(aREMonset_imaging(i)+1:remoffset(i))=0;
    end
end
save(['label_substates.mat'], 'label_substates');
%% test

j = 1;
figure();
subplot(size(ICtrace,1)+1,1,1);
imagesc(label_plot{j});
subplot(12,1,[2 3]);
start = remonset(j) - round(fps*10);  % 取REM前十秒的NREM
stop =  remoffset(j) + round(fps*10);
plot(ICtrace(1,start:stop),'g','LineWidth',2);
ylim([-0.1 0.3]);
xlim([0 stop-start+1]);
axis off;
i = 9;
subplot(12,1,[4 5]);
plot(ICtrace(i,start:stop),'g','LineWidth',2);
ylim([-0.1 0.3]);
xlim([0 stop-start+1]);
axis off;
i = 3;
subplot(12,1,[6 7]);
plot(ICtrace(i,start:stop),'g','LineWidth',2);
ylim([-0.1 0.3]);
xlim([0 stop-start+1]);
axis off;
i = 2;
subplot(12,1,[8 9]);
plot(ICtrace(i,start:stop),'g','LineWidth',2);
ylim([-0.1 0.3]);
xlim([0 stop-start+1]);
axis off;
i = 7;
subplot(12,1,[10 11]);
plot(ICtrace(i,start:stop),'g','LineWidth',2);
ylim([-0.1 0.3]);
xlim([0 stop-start+1]);
axis off;

%%
function output_txt = myupdatefcn(~,event_obj)
% ~            Currently not used (empty)
% event_obj    Object containing event data structure
% output_txt   Data cursor text
pos = get(event_obj, 'Position');
output_txt = {['x: ' num2str(pos(1))], ['y: ' num2str(pos(2))]};
end





