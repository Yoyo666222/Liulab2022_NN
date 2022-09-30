%%% This code is for facial analysis using HOG method
%%% edited based on python version
%%% writed by DYF at 2021/10/29

%clear all;

%% related paramete rs and paths
savefolder = [uigetdir(),'\'];
cd(savefolder);
% session = '#142_20220704s2';
prompt = 'please name the session (e.g. #131_20220616)'; % 不要加.csv
session = input(prompt,'s');
% load labels, imresize to video length

st = 2201.8;   % 脑电减去video的时间 秒

%% read the rewrited video
%FileName = 'E:\Data!!!\Analyzed data\WF\#76_20210816_25fps_2channel\#76_0816_align_rewrite.avi';
%obj = VideoReader(FileName);
[filename_video, pathname] = uigetfile('*.mp4','plese choose the oringinal video');
obj = VideoReader([pathname, filename_video]);
numFrames = obj.NumFrames;% 读取视频的帧数CurrentTime
FrameRate = obj.FrameRate;
frame_1 = read(obj,1);   %以第一帧为例选取一个区域并记录区域信息
f = figure();
imshow(frame_1);
[x,y]=ginput(2);         % 选取区域的左上角和右下角  % for crop analysis
close (f);

% FrameRate  = newFramerate;
%% 1013
% base = int32(numFrames/2);
% numFrames = numFrames/2;

%% resize the label
% find remonset & offset in video alignment labels

% load the label file
[filename_label, pathname_label] = uigetfile('*.mat','plese choose the label file');
load([pathname_label,filename_label]);
label_video = imresize(labels, [numFrames,1],'nearest');

%%% for those misalignment videos
label_video = imresize(labels, [4*3600*FrameRate,1],'nearest');
if st>0
    label_video = label_video(round(st*FrameRate)+1:end);  % video在EEG之前开始
else
    label_video = [nan(round(abs(st)*FrameRate),1); label_video];
end

[remonset, remoffset] = find_onset_offset(label_video, 1, 1);

%% HOG extraction
HOG = {};
label_plot = {};

for j = 1: length(remonset)
    start = int32(remonset(j) - round(FrameRate*20)) ;  % 选REM前面20秒的NREM作为参考
    stop = int32(remoffset(j) + round(FrameRate*10));  % 选REM后面20秒的wake作为参考
    label_plot{j} = [repelem(3,remonset(j) -start),...
    repelem(1,remoffset(j) -remonset(j)+1),...
    repelem(2,stop - remoffset(j)) ]; 
    tic;
    bar = waitbar(0,'读取数据中...');    % waitbar显示进度条
    len = stop-start+1;
    
    for i = start:stop
        I = read(obj,i);
        I0 = imcrop(I,[x(1),y(1),abs(x(1)-x(2)),abs(y(1)-y(2))]);   %切割图像
        %I1 = rgb2gray(I0);%图像灰度化
        I1 = I0;
        
        [hog(i-start+1,:)] = extractHOGFeatures(I1,'CellSize',[8 8],...
            'BlockSize', [1,1],...
            'NumBins', 8);
        
        %disp([num2str(i-start)]);
        str=['计算中...',num2str(100*(i-start)/len),'%'];    % 百分比形式显示处理进程,不需要删掉这行代码就行
        waitbar((i-start)/len,bar,str);
    end
    HOG{j} = hog;
    close (bar);
    toc;
    clear hog;
end
clear i j;

% figure();
% subplot(1,2,1);
% imshow(I1);
% subplot(1,2,2);
% plot(visualization);


%% Similarity calculation (selected frames)
rho = {};
for j= 1:length(HOG)
    disp('Correlation calculation...');
    rho{j} = corr(HOG{j}');
    
    disp('Done!');
end
clear j;

%% Plots with labelling (brainstates)
colors = [43 160 220;
            129 131 132
            255 194 61
            0 0 0] ./ 255;

for j = 1:length(rho)
    figure('position',[744,407.4,617,642.6]);
    h1 = subplot(50,1,1:3);
    imagesc(label_plot{j}, [1 4]);
    colormap(h1,colors);
    axis off;
    title([session, ' REM sleep facial analysis map episode', num2str(j)]);
    
    h2 = subplot(50,1,5:50);
    imagesc(rho{j}); % Display correlation matrix as an image
    %set(gca, 'XTick', 1:9); % center x-axis ticks on bins
    %set(gca, 'YTick', 1:9); % center y-axis ticks on bins
    %set(gca, 'XTickLabel', 'aa'); % set x-axis labels
    %set(gca, 'YTickLabel', 'bb'); % set y-axis labels
    %title('Similarity heatmap', 'FontSize', 10); % set title
    colormap(h2,'hot'); % Choose jet or any other color scheme
    axis square;
    axis off;
    savefig([savefolder, 'corrHeatmap_REMsession_', num2str(j), '.fig']);
end
clear j;

close all;




%% save data
% FrameRate & numFrames: 对应的是与imaging align并且时间正确的rewrite video
save([savefolder,session,'_', 'HOGanalysis_REM.mat'],...
    'x','y',...
    'HOG', 'rho',...
    'label_plot','label_video',...
    'numFrames', 'FrameRate',...
    'remonset','remoffset','-v7.3');


%% clustering
%%
% Z = linkage(rho{1},'average','chebychev');
% T = cluster(Z,'maxclust',2);
% cutoff = median([Z(end-2,3) Z(end-1,3)]);
% dendrogram(Z,'ColorThreshold',cutoff);


%% test

% label_video = imresize(label, [numFrames,1],'nearest');
% [remonset, remoffset] = find_onset_offset(label_video, 1, 1);


