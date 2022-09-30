%% This new code is based on J. Reidl et al. 2007 and discussions between Chi and Hiroshi
% First 40 PCA modes are picked to do ICA further.
% Farewell 2015.

% *****************************09152016************************************
% This is a demo
% *************************************************************************

%% Clear
% clear
% close all
% clc

% load df_f from your recording file, df_f is the cortex-wide activty, pixel*frame (row*column)
%df_f= permute(cell2mat(struct2cell(processed_signal_470)),[2 3 1] );
% df_f_raw = T470_final(:,:,size(T470_final,3)/3+1:end);
df_f_raw = T470_final(:,:,:);
df_f = df_f_raw;


%%%Important! df_f里面不能有空值！ 如果有，请将下面一部分注释添加进入正文
   
% Get temporal mean of each pixel for reconstruction
image_size = [size(df_f,1), size(df_f,2)];
df_f = reshape(df_f, [image_size(1)*image_size(2), size(df_f,3)]);
Temporal_Mean = mean(df_f,2);

% Check the kurtosis for all concataneted frames, higher spatial kurtosis
% than temporal kurtosis is preferred
Kur_S = kurtosis(df_f);
Kur_T = kurtosis(df_f');

%%% run this part if there is Nan in the df_f  (not fixed yet)
temp = ~isnan(df_f(:,1));
idx = find(temp==1)';

%set the nan as 0
idxnan = find(temp==0)';
for j = 1: size(df_f, 2)
    df_f(idxnan, j) = 0;
end

% or: discard the nan
% df_f = df_f(~isnan(df_f(:,1)),:);

disp(['Spatial Kurtosis: ' num2str(nanmean(Kur_S)) '+/-' num2str(nanstd(Kur_S))]);    
disp(['Temporal Kurtosis: ' num2str(nanmean(Kur_T)) '+/-' num2str(nanstd(Kur_T))]);    

%% PCA
% PCA subtract the mean of rows, which is the temporal mean of each pixel
% here since we will transpose the data
[COEFF_all,SCORE_all,latent_all] = pca(df_f');
% COEFF_all: PC component
% SCORE: temporal traces of each PC over time
Info = cumsum(latent_all)./sum(latent_all); % Check information retained
CompNum = 60; % Choose first 40 components
ModePCA = COEFF_all(:,1:CompNum); % COEFF: Row: Pixel, Column: Component

% Plot to check

figure
set(gcf,'color','b')
for mode = 1:20
    %subaxis(4,5,mode, 'Spacing', 0.04, 'Padding', 0, 'Margin', 0.03);
    subplot(4,5,mode);
    clims = [-0.04 0.04];
    image = ModePCA(:,mode);
    
    %Run this part if there is nan in raw df_f
%     a = NaN(image_size(1)*image_size(2),1);
%     a(idx) = image;
%     b = reshape(a(:,1),image_size);
%     imagesc(b, clims);
    
    %Run this line when df_f has no nan
    imagesc(reshape(image,[image_size(1) image_size(2)]),clims);
    
    axis square
    axis off
    title([ ' ModePCA' num2str(mode)]);
end
savefig([ '_ModePCA_1-20']);
%close all

figure
set(gcf,'color','b')
for mode = 21:40
    %subaxis(4,5,mode-20, 'Spacing', 0.04, 'Padding', 0, 'Margin', 0.03);
    subplot(4,5,mode-20);
    clims = [-0.04 0.04];
    image = ModePCA(:,mode);
    
    %Run this part if there is nan in raw df_f
%     a = NaN(image_size(1)*image_size(2),1);
%     a(idx) = image;
%     b = reshape(a(:,1),image_size);
%     imagesc(b, clims);
    
    %Run this line when df_f has no nan
    imagesc(reshape(image,[image_size(1) image_size(2)]),clims);

    axis square
    axis off
    title([ ' ModePCA' num2str(mode)]);
end
savefig([ '_ModePCA_21-40']);
%close all

figure
set(gcf,'color','b')
for mode = 41:60
    %subaxis(4,5,mode-20, 'Spacing', 0.04, 'Padding', 0, 'Margin', 0.03);
    subplot(4,5,mode-40);
    clims = [-0.04 0.04];
    image = ModePCA(:,mode);
    
    %Run this part if there is nan in raw df_f
%     a = NaN(image_size(1)*image_size(2),1);
%     a(idx) = image;
%     b = reshape(a(:,1),image_size);
%     imagesc(b, clims);
    
    %Run this line when df_f has no nan
    imagesc(reshape(image,[image_size(1) image_size(2)]),clims);

    axis square
    axis off
    title([ ' ModePCA' num2str(mode)]);
end
savefig(['_ModePCA_41-60']);

%% ICA;
% ICA algorithm: JADE, Cardoso, 2013
B = jadeR(ModePCA'); % Input: Row: PC, Column: Pixel; 
ModeICA = (B*ModePCA')'; % Get: ModeICA: Column: Independent Component(IC), Row: Pixel;
% Get temporal traces of each IC
A = inv(B)'; % column: PCA, row: IC, each column: PCA project on IC;
SCORE_ICA = A*SCORE_all(:,1:CompNum)'; % Raw: ICA Component, Column: Frame

% Plot to check
figure
set(gcf,'color','w')
for mode = 1:20
    %subaxis(4,5,mode, 'Spacing', 0.04, 'Padding', 0, 'Margin', 0.03);
    subplot(4,5,mode);
    clims = [-3 10];
    image = ModeICA(:,mode);
    
    %Run this part if there is nan in raw df_f
%     a = NaN(image_size(1)*image_size(2),1);
%     a(idx) = image;
%     b = reshape(a(:,1),image_size);
%     imagesc(b, clims);
    
    %Run this line when df_f has no nan
    imagesc(reshape(image,[image_size(1) image_size(2)]),clims);

    axis square
    axis off
    title([ ' ModeICA' num2str(mode)]);
end
savefig([ '_ModeICA_1-20']);
%close all

figure
set(gcf,'color','w')
for mode = 21:40
    %subaxis(4,5,mode-20, 'Spacing', 0.04, 'Padding', 0, 'Margin', 0.03);
    subplot(4,5,mode-20);
    clims = [-3 10];
    image = ModeICA(:,mode);
    
    %Run this part if there is nan in raw df_f
%     a = NaN(image_size(1)*image_size(2),1);
%     a(idx) = image;
%     b = reshape(a(:,1),image_size);
%     imagesc(b, clims);
    
    %Run this line when df_f has no nan
    imagesc(reshape(image,[image_size(1) image_size(2)]),clims);

    axis square
    axis off
    title([ ' ModeICA' num2str(mode)]);
end
savefig([ '_ModeICA_21-40']);
%close all

figure
set(gcf,'color','w')
for mode = 41:60
    %subaxis(4,5,mode-20, 'Spacing', 0.04, 'Padding', 0, 'Margin', 0.03);
    subplot(4,5,mode-40);
    clims = [-3 10];
    image = ModeICA(:,mode);
    
    %Run this part if there is nan in raw df_f
%     a = NaN(image_size(1)*image_size(2),1);
%     a(idx) = image;
%     b = reshape(a(:,1),image_size);
%     imagesc(b, clims);
    
    %Run this line when df_f has no nan
    imagesc(reshape(image,[image_size(1) image_size(2)]),clims);

    axis square
    axis off
    title([ ' ModeICA' num2str(mode)]);
end
savefig([ '_ModeICA_41-60']);

%% save data
save('20220623_ICA_#136.mat','df_f_raw','COEFF_all','latent_all','SCORE_all','ModeICA',...
    'ModePCA','SCORE_ICA','-v7.3');


%% Reconstruction
% remove modes corresponding to motion artifacts and hemo contaminations
% 去除movement artifacts and 血氧信号 应该是做了什么mask
% ModeIndex = true(size(ModeICA,2),1);
% %ModeIndex(Mode_removed) = false;
% SCORE_ICA = SCORE_ICA(ModeIndex,:);
% ModeICA = ModeICA(:,ModeIndex);
% % % reconstruct        
% % RecICA_Sum = ModeICA*SCORE_ICA + repmat(Temporal_Mean,1,size(SCORE_ICA,2));
% 
% 
% %Mode_removed is not found