%% Modified code for 2 channel corrected data
% edition on 2021/10/28 by DYF

%%
% cd
files = dir(['*corrected*','_df_f*.mat']);

for n = 1:length(files)
    load(files(n).name,'T470_final');
    %把四个数据整合到一起进行
    
    imagestack_corrected = T470_final;
    image_size = size(imagestack_corrected);
    image_corrected2 = reshape(imagestack_corrected, [size(imagestack_corrected,1)*size(imagestack_corrected,2),size(imagestack_corrected,3)]);
    %将二维数组转换成一维的，所以imagestack2最终变成一个像素向量*时间向量
    
    image_corrected3 = NaN(size(image_corrected2));
    for i =1:size(image_corrected2,1)
        temp = image_corrected2(i,:);
        temp(temp<(mean(temp)+2*std(temp)))=min(temp);    %去掉高于和低于两倍sd的值，目的:去除背景噪声
        temp = (temp-min(temp))/(max(temp)-min(temp));
        image_corrected3(i,:) = temp;
        clear temp;
    end
    temp = ~isnan(image_corrected3(:,1));
    idx = find(temp==1)';
    image_corrected4 = image_corrected3(~isnan(image_corrected3(:,1)),:);
    %clear image_corrected3 image_corrected2 imagestack_corrected
    save([num2str(n), '-1xdownsized_norm.mat'], 'image_corrected4', 'idx', 'image_size', '-v7.3')
    % end
end



%%变量说明
% temp: 经过预处理后的图像空值判断
% idx: 图像空值的位置
% image_corrected4/41: 不包含空值的图片
