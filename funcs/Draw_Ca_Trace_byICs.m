


filepath = uigetdir;
name1 = '\visualValues.csv';
name2 = '\ACCValues.csv';
name3 = '\RSCValues.csv';
name4 = '\PFCValues.csv';
visual = importdata([filepath, name1]);
ACC = importdata([filepath, name2]);
RSC = importdata([filepath, name3]);
PFC = importdata([filepath, name4]);

time = linspace(0, size(RSC.data,1)/5,size(RSC.data,1)/2);
figure('Color','w','Position',[59.4 749.8 1926.4 300.2]);
plot(time, RSC.data(2001:end,2));
axis tight;

hold on;
plot(time, ACC.data(2001:end,2));
axis tight;
hold on;
plot(time, visual.data(2001:end,2));
axis tight;
hold on;
plot(time, PFC.data(2001:end,2));
axis tight;

xlabel('Time (s)');
ylabel('deltaF/F');
title('Calcium signals during hallucination state');
legend('RSC', 'ACC', 'Visual Cortex','Prefrontal Cortex');





