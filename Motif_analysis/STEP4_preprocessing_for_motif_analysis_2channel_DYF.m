%% Modified code for 2 channel corrected data
% edition on 2021/10/28 by DYF

%%
% cd
files = dir(['*corrected*','_df_f*.mat']);

for n = 1:length(files)
    load(files(n).name,'T470_final');
    %���ĸ��������ϵ�һ�����
    
    imagestack_corrected = T470_final;
    image_size = size(imagestack_corrected);
    image_corrected2 = reshape(imagestack_corrected, [size(imagestack_corrected,1)*size(imagestack_corrected,2),size(imagestack_corrected,3)]);
    %����ά����ת����һά�ģ�����imagestack2���ձ��һ����������*ʱ������
    
    image_corrected3 = NaN(size(image_corrected2));
    for i =1:size(image_corrected2,1)
        temp = image_corrected2(i,:);
        temp(temp<(mean(temp)+2*std(temp)))=min(temp);    %ȥ�����ں͵�������sd��ֵ��Ŀ��:ȥ����������
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



%%����˵��
% temp: ����Ԥ������ͼ���ֵ�ж�
% idx: ͼ���ֵ��λ��
% image_corrected4/41: ��������ֵ��ͼƬ
