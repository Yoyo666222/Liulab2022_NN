%clear all
dpath = 'D:\Raw_data\WF_imaging_downsized\20220623\';
cd(dpath)
%raw_images = dir('*downsized_cropped.tif');
raw_images = dir('*109_101*.tif');
for n  = 1:length(raw_images)
    % reading tiffs into mat files
    image_info = imfinfo(raw_images(n).name);
    imagestack = struct;
    h1 = waitbar(0, ['Reading Image ' num2str(n) '/' num2str(length(raw_images))]);
    for i = 1 :length(image_info)
        image = imread(raw_images(n).name,i);            
        imagestack(i).data = image;
        waitbar(i/length(image_info), h1)
        clear image 
    end
    sprintf(['saving raw image ' num2str(n)])
    save([raw_images(n).name(1:end-4) '_raw.mat'], 'imagestack', '-v7.3')

    % calculate deltaF/F
    imagestack = cell2mat(struct2cell(imagestack));
    processed_signal = struct();
    h2 = waitbar(0, ['Processing Image ' num2str(n) '/' num2str(length(raw_images))]);
    t = 0;
    for i = 1:size(imagestack,1)
        for j = 1:size(imagestack,2)
            t = t+1;
            temp2 = squeeze(imagestack(i,j,:));
            temp2 = double(temp2);
            temp3 = (temp2-nanmean(temp2))/nanmean(temp2);
            processed_signal(i,j).data = temp3;
            clear temp2 temp3
            waitbar(t/(size(imagestack,1)*size(imagestack,2)), h2)
        end
    end
    sprintf(['saving processed signal ' num2str(n)])
    save([raw_images(n).name(1:end-4) '_downsized_processed.mat'], 'processed_signal', '-v7.3');
    %df_f = permute(cell2mat(struct2cell(processed_signal)),[3 1 2]);
    %save(['df_f.mat'], 'df_f', '-v7.3');
    clear imagestack processed_signal
    close(h1);close(h2);
end

clear all;



% imagestack_processed = struct();
% t = 0;
% for i = 1:size(imagestack,1)
%     for j = 1:size(imagestack,2)
%         t = t+1
%         temp2 = squeeze(imagestack(i,j,:));
%         temp3 = (temp2-mean(temp2))/mean(temp2);
%         imagestack_processed(i,j).data = temp3;
%         clear temp2 temp3
%     end
% end
% 
% % image_processed = NaN([size(temp) size(image_info,1)]);
% % image_processed = permute(cell2mat(struct2cell(imagestack_processed)),[2 3 1]);
% % 
% % frame_rate = 5;
% % vidObj=VideoWriter(['470_' num2str(frame_rate), 'fps.avi']);
% % vidObj.FrameRate = frame_rate;
% % open(vidObj);
% % 
% % figure;
% % for i = 1:20000
% % temp = squeeze(image_processed(:,:,i));
% % imagesc(temp,'AlphaData',~isnan(temp));
% % caxis([-0.12 0.12]); axis off; pause(0.1)
% % writeVideo(vidObj,getframe);
% % end
% % 
% % close(vidObj);
% % 
% %         
