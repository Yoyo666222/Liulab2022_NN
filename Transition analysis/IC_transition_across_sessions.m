%% Statistics across sessions
% this code is for statistics of different sessions 
% data needed: transition activity after IC transition analysis
clear all;

%% Load data & set parameters
root_path = uigetdir();
root_file = dir([root_path,'\']);
fluo_transitions_allsession = {};
SR = 10; % imaging�Ĳ���Ƶ��Ϊ10Hz
Date = date();
save_folder = [root_path, '\', Date, '_transition_statistics_crosssession'];
if isempty(dir(save_folder))
    mkdir(save_folder)
end


for k = 1: length(root_file)
    file_path = [root_path, '\', root_file(k).name, '\', 'Transition_analysis\'];
    if isfolder(file_path)
        file = dir([file_path, '*transition_analysis.mat']);
        if exist([file_path,'\',file.name],'file')
            load([file_path,'\',file.name]);  % ��̫��Ϊʲôû��transition_analysis�ļ��л��ǻᱻʶ�����
            %         pre = Timew * SR; % ȡtransition time ǰ��100֡
            %         post = Timewpost * SR;  % ȡtransition time ����100֡
            %% calculate the mean in the session and combine different sessions
            for i = 1:length(average_trace)
                for tr = 1:length(transitions)
                    if myIsField(average_trace{i}, char(transitions(tr))) %�ж����session������û������transition
                        % ������ �жϽṹ���к����������ֶ�
                        fluo_transitions_allsession{i}.(char(transitions(tr)))(k,:) = average_trace{i}.(char(transitions(tr)));
                        % ��һ��ֻ�ܴ���ͬ��frame���ȵ����ݣ�����˵10Hz��25Hz�����ݾͲ���ͬʱ���֣���Ϊ��Ȼʱ��һ���������ݳ��Ȳ�ͬ
                    end
                end
            end
        end
    end
    clear average_trace;
end
clear i tr;

%% plotting
for i = 1: length(fluo_transitions_allsession)
    h = figure('NumberTitle', 'off', 'Name', char(IC_name{i}), 'position', [535.4,458.6,809.6,572]);
    for tr = 1:length(transitions)
        yyy = fluo_transitions_allsession{i}.(char(transitions(tr)));
        if ~isempty(yyy)
            subplot(2,2,tr);   % �ǵð�subplot��Ŀ�ĳ�transitions������
            hold on;
%             % Normalize using the mean pre value
%             for j = 1: size(yyy,1)
%                yyy(j,:) = smooth(yyy(j,:));
%                average = mean(yyy(j,1:size(yyy,2)/2));
%                yyy(j,:) = yyy(j,:)/average;
%             end
            
            mean_tr = nanmean(yyy, 1);
            std_tr = nanstd(yyy,1)/sqrt(size(yyy,1)-1);
            
            x = [1:pre+post];
            fill([x fliplr(x)],[mean_tr-std_tr fliplr(mean_tr+std_tr)], [0.8 0.8 0.8]);
            hold on;
            plot(mean_tr, 'LineWidth',2,'color', [0.48 0.78 0.35]);
            xlabel('Time after state transition (s)', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            ylabel('Z-socre', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            title(char(transitions(tr)),'Interpreter', 'none', 'Fontname','Times New Roman', 'FontSize', 15);
            %plot([pre+0.5 pre+0.5], [-1 2], 'r--')
            ylim([-3 4]);
            xlim([1 pre+post+1]);
            set(gca, 'xTick', [1,pre+1,pre+post], 'xTickLabel', [-Timew, 0, Timewpost]);
            hold on;
            y1 = ylim;
            %axis tight;
            plot((pre+1)*ones(1,100), linspace(y1(1),y1(2),100),'r', 'LineWidth',1); % draw a line at transition point
            clear y1 ylim;
        end
    end
     saveas(h, [save_folder, ['\',  char(IC_name{i}), '.png']]);
     saveas(h, [save_folder, ['\',  char(IC_name{i}), '.fig']]);
end
clear i tr;
close all;

save([save_folder, ['\','across_session_transition_analysis', '.mat']], 'fluo_transitions_allsession',...
    'IC_name','Timew', 'Timewpost','transitions','SR', '-v7.3');


% ����transition��������
% ÿһ��ͼ�������ͬIC��ͬһ��transition����

for i = 1: length(transitions)
    h = figure('NumberTitle', 'off', 'Name', char(transitions{i}), 'position', [38.6,502.6,1825.6,539.2]);
    for tr = 1:length(fluo_transitions_allsession)
        yyy = fluo_transitions_allsession{tr}.(char(transitions(i)));
        if ~isempty(yyy)
            subplot(2,ceil(length(IC_name)/2),tr);   % �ǵð�subplot��Ŀ�ĳ�IC������
            hold on;
%             % Normalize using the mean pre value
%             for j = 1: size(yyy,1)
%                yyy(j,:) = smooth(yyy(j,:));
%                average = mean(yyy(j,1:size(yyy,2)/2));
%                yyy(j,:) = yyy(j,:)/average;
%             end
            
            mean_tr = nanmean(yyy, 1);
            std_tr = nanstd(yyy,1)/sqrt(size(yyy,1)-1);

            x = [1:pre+post];
            fill([x fliplr(x)],[mean_tr+std_tr fliplr(mean_tr-std_tr)], [0.8 0.8 0.8]);
            hold on;
            plot(mean_tr, 'LineWidth',2,'color', [0.48 0.78 0.35]);
            xlabel('Time after state transition (s)', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            ylabel('Z-socre', 'Fontname','Times New Roman','Fontsize',10, 'FontWeight', 'bold');
            title(char(IC_name(tr)),'Interpreter', 'none', 'Fontname','Times New Roman', 'FontSize', 15);
            %plot([pre+0.5 pre+0.5], [-1 2], 'r--')
            ylim([-3 4]);
            xlim([1 pre+post+1]);
            set(gca, 'xTick', [1,pre+1,pre+post], 'xTickLabel', [-Timew, 0, Timewpost]);
            hold on;
            y1 = ylim;
            %axis tight;
            plot((pre+1)*ones(1,100), linspace(y1(1),y1(2),100),'r', 'LineWidth',1); % draw a line at transition point
            clear y1 ylim;
        end
    end
     saveas(h, [save_folder, ['\',  char(transitions(i)), '.png']]);
     saveas(h, [save_folder, ['\',  char(transitions(i)), '.fig']]);
end

close all;


