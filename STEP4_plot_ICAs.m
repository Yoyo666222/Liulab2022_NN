%% load a few mat files before running this code 
%% mannually pick good ICAs and set them to ICA_idx in line 11
%by DQ 20210702

% 1. load ICA parameters;
% 2. load state_frames;
% 3. load EMs (resize to frames)


%% manually pick good ICAs
ICA_idx = [9 10 16 17 21 23:27 29 31:33 35 37 38:42 45 47 49 51:59];

%% thresholding ICAs
image_size = [size(df_f_raw,1)  size(df_f_raw,2)];
for i = 1:length(ICA_idx)
temp = (reshape(ModeICA(:,ICA_idx(i)),image_size));
bw = (temp>=3.5)% | (temp<=-4); % threshold  % | means or(a,b)
BW2 = bwareafilt(bw,[50 1000]); % only leave those patches between specific area size
figure
imshow(BW2); drawnow;  % visualize ICA areas, change threshold if something looks wierd
bw3 = imfill(BW2, 'holes');
ICA{i} = bw3;
end

close all;

%% put all ICAs into a matrix for visualizing
int_ICA = zeros(image_size(1),image_size(2));
for i = 1:length(ICA_idx)
temp = find(ICA{i}==1); int_ICA(temp) = i;
end
int_ICA(int_ICA==0)=NaN;
h = figure;
imagesc(int_ICA, 'AlphaData', ~isnan(int_ICA));
axis off

for i = 1:length(ICA_idx)
if ~isnan(find(int_ICA==i))
bw = int_ICA==i;
tmp2 = bwareafilt(bw,1);
stats = regionprops(tmp2);
centroid = stats.Centroid;
figure(h); hold on; text(centroid(1), centroid(2),{num2str(ICA_idx(i))})
end
end
savefig(['IC_overlay.fig']);


%% calculate df_f traces for each ICAs
DF_matrix = reshape(df_f_raw, [image_size(1)*image_size(2), size(df_f_raw,3)]);

for i = 1:length(ICA_idx)
tmp = DF_matrix(find(int_ICA==i),:);
ICA_trace(i,:) = sum(tmp);
end

%% plot ICA traces together with brainstates and eyemovements
% create saving folders
save_folder = 'IC_traces';
if isempty(dir(save_folder))
    mkdir(save_folder)
end

%label = imresize(labels, [size(ICA_trace,2),1],'nearest');

%%
colors = [43 160 220;
129 131 132
255 194 61
0 0 0] ./ 255;
for i = 1:size(ICA_trace,1)
    h = figure('Position',[3.40000000000000,481.800000000000,2041.60000000000,432.800000000000]); 
    %h1 =subplot(4,1,1); 
    %imagesc(label',[1 4]);colormap(h1,colors);
    hold on; 
    title(['IC', num2str(ICA_idx(i))]);
    axis off;
    h2 = subplot(4,1,[2 3 4]); 
    plot(ICA_trace(i,:), 'color', [.48 .78 .35],'lineWidth',2); 
    axis tight;
    ylim([-10 50]);
    %axis off;
    box off;
    %h3 = subplot(4,1,4); 
    %plot(EMs);box off; 
    saveas(gcf,[save_folder, '\', 'IC', num2str(ICA_idx(i)) '.fig'])
    %linkaxes([h1,h2, h3], 'x');
    %linkaxes([h1,h2], 'x');
    %close(h)
end
close all;


%% save files
save(['IC_plots.mat'], 'ICA_idx','int_ICA','ICA_trace','-v7.3');




