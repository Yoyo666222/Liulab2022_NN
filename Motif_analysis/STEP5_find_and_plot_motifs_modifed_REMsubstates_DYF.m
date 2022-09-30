% clear all;
SF1 = uigetdir; % set the save folder
SF2 = uigetdir; % set the save folder

STEP4_preprocessing_for_motif_analysis_2channel_DYF;
% modified by DYF on 2021/12/07 for aREM or qREM motif finding

%%

% SF1 = uigetdir; % set the save folder
% SF2 = uigetdir; % set the save folder


%% aREM
files = dir('*norm.mat');
K = 20;
L = 20;
% start = 1;
% stop = 30000;

% load onset & offset

for i = 1:length(files)
    load(files(i).name);
    for p = 1:length(aREMonset_imaging)
    start = aREMonset_imaging(p);
    stop = remoffset_imaging(p);
    if start ~= 0
        %for p = 1:length(remonset)
        %start = remonset(p);
        %stop = remoffset(p);
        [W,H,cost,loadings,power] = seqNMF(image_corrected4(:,start:1:stop),'K',K,'L',L,'lambda',0, 'lambdaOrthoW', 0);
        
        subfolder = [SF1 '\aREM' files(i).name(1:end-13) '_K' num2str(K) '_L' num2str(L) '_' num2str(start) '-' num2str(stop), '_motifs'];
        if isempty(dir(subfolder))
            mkdir(subfolder)
        end
        saveas(gcf, [ subfolder '/' '_' num2str(start) '-' num2str(stop), 'analysis.fig']);
        save([subfolder, '/',files(i).name(1:end-13) '_' num2str(K) '_L' num2str(L) '_' num2str(start) '-' num2str(stop), '_motifs.mat']);
        
        for n = 1:size(W,2)
            %figure('Position', [658   421   437   270]); for 20 frames
            figure('Position', [744,622.600000000000,1224.20000000000,427.400000000000]); % for 50 frames
            hold on
            for j = 1:L
                subplot(5,10,j)
                a = NaN(image_size(1)*image_size(2),1);
                a(idx) = W(:,n,j);
                b = reshape(a(:,1),[image_size(1),image_size(2)]);
                b = imgaussfilt(b,2);
                %imagesc(b);
                imagesc(b,'AlphaData',~isnan(b))
                colormap(hot)
                caxis([-0.2 1.0])
                %caxis([-0.5 5]);
                axis off
                %         drawnow
            end
            saveas(gcf, [subfolder '/motif', num2str(n) '.fig']);
            saveas(gcf, [subfolder '/motif', num2str(n) '.png']);
            close all;
            % 明天在这里加上画H 的code
        end
    end
    %end
    end
end


%% qREM

for i = 1:length(files)
    load(files(i).name);
    for p = 1:length(aREMonset_imaging)
    start = remonset_imaging(p);
    stop = aREMonset_imaging(p)-1;
    if stop ~= -1
        %for p = 1:length(remonset)
        %start = remonset(p);
        %stop = remoffset(p);
        [W,H,cost,loadings,power] = seqNMF(image_corrected4(:,start:1:stop),'K',K,'L',L,'lambda',0, 'lambdaOrthoW', 0);
       
        subfolder = [SF2 '\qREM' files(i).name(1:end-13) '_K' num2str(K) '_L' num2str(L) '_' num2str(start) '-' num2str(stop), '_motifs'];
        if isempty(dir(subfolder))
            mkdir(subfolder)
        end
        saveas(gcf, [subfolder '/' '_' num2str(start) '-' num2str(stop), 'analysis.fig']);
        save([subfolder, '/', files(i).name(1:end-13) '_' num2str(K) '_L' num2str(L) '_' num2str(start) '-' num2str(stop), '_motifs.mat']);
        
        for n = 1:size(W,2)
            %figure('Position', [658   421   437   270]); for 20 frames
            figure('Position', [744,622.600000000000,1224.20000000000,427.400000000000]); % for 50 frames
            hold on
            for j = 1:L
                subplot(5,10,j)
                a = NaN(image_size(1)*image_size(2),1);
                a(idx) = W(:,n,j);
                b = reshape(a(:,1),[image_size(1),image_size(2)]);
                b = imgaussfilt(b,2);
                %imagesc(b);
                imagesc(b,'AlphaData',~isnan(b))
                colormap(hot)
                caxis([-0.2 1.0])
                %caxis([-0.5 5]);
                axis off
                %         drawnow
            end
            saveas(gcf, [subfolder '/motif', num2str(n) '.fig']);
            saveas(gcf, [subfolder '/motif', num2str(n) '.png']);
            close all;
            % 明天在这里加上画H 的code
        end
    end
    %end
    end
end

%% REM
files = dir('*norm.mat');
K = 20;
L = 20;
% start = 1;
% stop = 30000;

% load onset & offset

for i = 1:length(files)
    load(files(i).name);
    for p = 1:length(remonset_imaging)
    start = remonset_imaging(p);
    stop = remoffset_imaging(p);
    if start ~= 0
        %for p = 1:length(remonset)
        %start = remonset(p);
        %stop = remoffset(p);
        [W,H,cost,loadings,power] = seqNMF(image_corrected4(:,start:1:stop),'K',K,'L',L,'lambda',0, 'lambdaOrthoW', 0);
        
        subfolder = [ 'REM' files(i).name(1:end-13) '_K' num2str(K) '_L' num2str(L) '_' num2str(start) '-' num2str(stop), '_motifs'];
        if isempty(dir(subfolder))
            mkdir(subfolder)
        end
        saveas(gcf, [ subfolder '/' '_' num2str(start) '-' num2str(stop), 'analysis.fig']);
        save([subfolder, '/',files(i).name(1:end-13) '_' num2str(K) '_L' num2str(L) '_' num2str(start) '-' num2str(stop), '_motifs.mat']);
        
        for n = 1:size(W,2)
            %figure('Position', [658   421   437   270]); for 20 frames
            figure('Position', [744,622.600000000000,1224.20000000000,427.400000000000]); % for 50 frames
            hold on
            for j = 1:L
                subplot(5,10,j)
                a = NaN(image_size(1)*image_size(2),1);
                a(idx) = W(:,n,j);
                b = reshape(a(:,1),[image_size(1),image_size(2)]);
                b = imgaussfilt(b,2);
                %imagesc(b);
                imagesc(b,'AlphaData',~isnan(b))
                colormap(hot)
                caxis([-0.2 1.0])
                %caxis([-0.5 5]);
                axis off
                %         drawnow
            end
            saveas(gcf, [subfolder '/motif', num2str(n) '.fig']);
            saveas(gcf, [subfolder '/motif', num2str(n) '.png']);
            close all;
            % 明天在这里加上画H 的code
        end
    end
    %end
    end
end




%% Plot the time events

% figure(); 
% subplot(21,1,1);
% imagesc(label');
% axis off;
% for i = 1:20
% subplot(21,1,i+1); 
% plot(H(i,:));
% axis tight;
% axis off;
% end








