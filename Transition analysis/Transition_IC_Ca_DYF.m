%% This code is for analyzing the Ca_activity of Independent components before and after events onset
% draw the trace IC by IC seperately, for single trial.
% e.g. eye movement onset; facial movement onset; REM onset

%% Load related data
% 1.ICA data;
% 2.Onset time point;
% 3.df_f data;

%% resize onset time point
EM_onset1 = round((EM_onset_manual * size(df_f,3)) / length(EEG));
Timew = 10 % 取10s的time window (onset前10秒和后10秒)
SR = 10; % imaging的采样频率为10Hz

for i = 1: length(EM_onset1)
    pret = EM_onset1(i)- SR*Timew;
    postt = EM_onset1(i) + SR*Timew -1;
    h(i) = figure('Position',[ 744.0000  413.8000  852.2000  636.2000]); 
    ylimit = [0 0];
    
    for j = 1: length(ICA_idx)
        IC_dff = ICA_trace(j,pret:postt) /mean(ICA_trace(j,pret:postt));
        plot(linspace(0,Timew*2, (postt - pret + 1)), ICA_trace(j,pret:postt) + ylimit(2),...
            'lineWidth', 2);
        axis tight;
        ylimit = ylim;
        hold on;
    end
    yl = ylim;
    stem(Timew,yl(2),'Marker','none');
    hold off;
end

for i = 1: length(EM_onset1)
    pret = EM_onset1(i)- SR*Timew;
    postt = EM_onset1(i) + SR*Timew -1;
    h(i) = figure('Position',[ 744.0000  413.8000  852.2000  636.2000]); 
     
    imagesc(ICA_trace(:,pret:postt));

end

%% Statistics of one session (one recording)
% data needed: ICtrace(IC * df/f), label (brain states, length = imaging frames)










