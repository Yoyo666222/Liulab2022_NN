%%% This code is for correct one-photon calcium data (especially WF) using
%%% 405nm signal.
%%% finallized on 2021-10-25 by DYF

%% set parameters
fps = 25;
save_path = uigetdir();
filename = '#136_20220623_spontaneous_corrected_df_f.mat';

%%
% for i = 1:80
%     for j = 1:80
%         processed_signal_405(i,j).data = [processed_signal_405_1(i,j).data;...
%         processed_signal_405_2(i,j).data; processed_signal_405_3(i,j).data;];
%         processed_signal_470(i,j).data = [processed_signal_470_1(i,j).data;...
%         processed_signal_470_2(i,j).data; processed_signal_470_3(i,j).data;];
% 
%     end
% end
% clear processed_signal_405_1 processed_signal_405_2 processed_signal_405_3;
% clear processed_signal_470_1 processed_signal_470_2 processed_signal_470_3;

%% load df/f data from tiff 
% need to process the raw data first and make the name to be correct

% temp = load(file, 'T405', 'T470');
% T405 = temp.T405(:,:, 101:end);
% T470 = temp.T470(:,:, 101:end);
% clear temp
T405 = permute(cell2mat(struct2cell(processed_signal_405)), [2 3 1]);
T470 = permute(cell2mat(struct2cell(processed_signal_470)), [2 3 1]);

%% discard the first 100 frames
T405 = T405(:,:,101:end);
T470 = T470(:,:,101:end);
%%
% smooth per 500ms
% important!! smooth以及找系数 要去除nan！
temp = ~isnan(T405(:,:,1));
idx = find(temp==1)';
T405_reshape = reshape(T405,[size(T405,1)*size(T405,2),size(T405,3)]);
T470_reshape = reshape(T470,[size(T470,1)*size(T470,2),size(T405,3)]);
T405_nnan = T405_reshape(~isnan(T405_reshape(:,1)),:);


tic;                                % tic;与toc;配合使用能够返回程序运行时间
bar = waitbar(0,'读取数据中...');    % waitbar显示进度条
len = size(T405_nnan,1);
for i = 1:size(T405_nnan,1)
    T405_s(i,:) = smooth(T405_nnan(i,:), fps/2);
    disp([num2str(i)]);
    str=['计算中...',num2str(100*i/len),'%'];    % 百分比形式显示处理进程,不需要删掉这行代码就行
    waitbar(i/len,bar,str)   
end
close(bar);                % 循环结束可以关闭进度条，个人一般留着不关闭
toc;  

% treatment of 470data
nan405 = find(isnan(T405_reshape(:,1))==1);
nan470 = find(isnan(T470_reshape(:,1))==1);
common_nan = intersect(nan405,nan470);
snan470 = setdiff(nan470,common_nan);
T470_reshape(snan470,:) = min(min(T405_reshape));
T470_nnan = T470_reshape(~isnan(T405_reshape(:,1)),:);

% T405 regressed onto T470
tic;                                % tic;与toc;配合使用能够返回程序运行时间
bar = waitbar(0,'读取数据中...');    % waitbar显示进度条
len = min(size(T405_s,1),size(T470_nnan,1));
T405_regressed = zeros(size(T405_s,1), size(T405_s,2));
T470_corrected = zeros(size(T405_s,1), size(T405_s,2));
for j = 1: len
    p = polyfit(T405_s(j,:),T470_nnan(j,:),1);
    T405_regressed(j,:) = p(1)*T405_s(j,:) + p(2);
    % correction
    T470_corrected(j,:) = T470_nnan(j,:)-T405_regressed(j,:);
    
    disp([num2str(j)]);
    %str('计算中...',num2str(100*j/len),'%');
end
close(bar);
toc;

%有个bug就是470和405nan的位置不一样，这是由于截图的时候是分开的造成的，必须用同样的截图方式才行
%用同样的截图方式也会有差别，所以最后直接把405为空的位置赋给470，但是470本身可能多出来的空值设为最小值

%% fill the nan into signals
image_size = [size(T470,1),size(T470,2)];
a = NaN(image_size(1)*image_size(2),size(T470,3));
a(idx,:) = T405_s; 
T405_final = reshape(a,size(T470));
clear a;
a = NaN(image_size(1)*image_size(2),size(T470,3));
a(idx,:) = T470_corrected; 
T470_final = reshape(a,size(T470));

%% save the data after corection
% save_path = uigetdir();
save([save_path, '\', filename],'T405','T470','T405_final','T470_final','-v7.3');



%% before analysis: combine imaging data
% for i = 1:109
%     for j = 1:101
%         processed_signal_405(i,j).data = [processed_signal_405_1(i,j).data;...
%         processed_signal_405_2(i,j).data]; 
%     %; processed_signal_405_3(i,j).data;];
%         processed_signal_470(i,j).data = [processed_signal_470_1(i,j).data;...
%         processed_signal_470_2(i,j).data];
%     %processed_signal_470_3(i,j).data;];
% 
%     end
% end
