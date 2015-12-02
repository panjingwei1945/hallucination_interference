cd('/Users/xun/Nutstore/Projects/Collaboration/幻听干预仪/20151118_data/')
% lines = importdata('dev001.TXT','\t');
lines = importdata('dev003.TXT','\t');
%% 
n_ts = 0;
for i = 1:size(lines,1)
    if ~isempty(lines{i})
        n_ts = n_ts + 1;
        line_split{n_ts} = strsplit(lines{i}, '\t');
        % the first item is time string, split it into different time units
        aux_1 = strsplit(line_split{n_ts}{1}, '/');
        ts_line(n_ts,:) = cellfun(@(x) str2num(x), aux_1);
    end
end

%%
lines_use = lines(1:end);

inds_powerOn = 0;
time_powerOn = [];

inds_trial = 0;
task_trial = struct([]);
task_trial(1).time_start = [];
task_trial(1).report_time = {};
task_trial(1).report_event = {};
task_trial(1).report_count = [];

%
ln = 1;
while ln < size(lines_use,1)
    %%
    [line_data, line_time] = get_data_line(lines, ln);
    
    if isempty(line_data)
           ln = ln + 1;
        continue;
    end
    
    if strcmpi(line_data{2}, 'Power on')
        inds_powerOn = inds_powerOn + 1;
        time_powerOn = [time_powerOn ; line_time];
        ln = ln + 1;
        continue;
    end
    %%
    if strcmpi(line_data{2}, 'play')
        inds_trial = inds_trial + 1;
        task_trial(inds_trial).time_start = line_time;
        
        report_count = 0;
        task_trial(inds_trial).report_count = report_count;
        
        ln = ln + 1;
        % get next line
        [line_data, line_time] = get_data_line(lines, ln);
        while  ~isempty(line_data) && strncmpi(line_data{2}, 'push',4)
               report_count = report_count + 1;
               task_trial(inds_trial).report_count = report_count;
               task_trial(inds_trial).report_event{report_count} = line_data{2};
               task_trial(inds_trial).report_time{report_count} = line_time;
               ln = ln + 1;
                % get next line
               [line_data, line_time] = get_data_line(lines, ln);
            
        end
    end
    ln = ln + 1;
end


%% 
hour_trial_day = {};
trial_start_min = arrayfun(@(x) x.time_start(5) + x.time_start(4)*60, task_trial);

days_trial = arrayfun(@(x) x.time_start(3), task_trial);
days = unique(days_trial);
%% Daily Performance

for i = 1:length(days)
    %%
    inds_trial_day = find(days_trial == days(i));
    num_trial_day(i) = length(inds_trial_day);
    task_trial_day{i} = task_trial(inds_trial_day);
    
    hour_trial_day{i} = arrayfun(@(x) x.time_start(4), task_trial_day{i});
    
%     plot(trial_start_min(inds_trial_day));
    for j = 1:length(inds_trial_day)
        report_count_day(j) = task_trial(inds_trial_day(j)).report_count;   
    end
    daily_score(i) = sum(report_count_day>=7 & report_count_day<=9)/length(report_count_day);
end

inds_day_use = 1:length(days);% 4:10;
%%
hb1 = bar(days(inds_day_use), daily_score(inds_day_use));
set(hb1,'facecolor',[.4 .4 .4]);
set(gca,'fontsize',25)
xlabel('Days','fontsize',25);
ylabel('Task trial score','fontsize',25)
title('Patient 001 first 7 days')
%%
startHour = cellfun(@(x) min(x), hour_trial_day);
endHour = cellfun(@(x) max(x), hour_trial_day);

daily_task_hour = min(startHour): max(endHour);


daily_hour_trial_count = zeros(length(hour_trial_day),length(daily_task_hour));

for i = 1:length(hour_trial_day)
    for j = 1:length(daily_task_hour)
        daily_hour_trial_count(i,j) = sum(hour_trial_day{i} == daily_task_hour(j));
    end
    morning_counts(i) = sum(daily_hour_trial_count(i, daily_task_hour<12));
    afternoon_counts(i) = sum(daily_hour_trial_count(i, daily_task_hour>=12));
end

%%
figure;
bar3(daily_task_hour, daily_hour_trial_count(inds_day_use,:)')
fntsz = 20;
xlabel('Days (Nov-)','fontsize',fntsz)
zlabel('Trial Count','fontsize',fntsz);
ylabel('Hour','fontsize',fntsz);
set(gca,'fontsize', fntsz, 'xticklabel',days(inds_day_use));

%% Bar plot compare morning and afternoon
mean_morning_counts = mean(morning_counts(inds_day_use));
se_morning_counts = std(morning_counts(inds_day_use))/sqrt(length(inds_day_use));

mean_afternn_counts = mean(afternoon_counts(inds_day_use));
se_afternn_counts = std(afternoon_counts(inds_day_use))/sqrt(length(inds_day_use));

figure; hold on;
hb = bar([1 2], [mean_morning_counts mean_afternn_counts]);
set(hb,'facecolor',[.4 .4 .4])
errorbar([1 2], [mean_morning_counts mean_afternn_counts], [se_morning_counts se_afternn_counts],...
    'k.', 'LineWidth',3)
set(gca,'xlim',[.3 2.7], 'fontsize',25,'xtick',[1 2],'xticklabel', {'Morning', 'Afternoon'})

ylabel('Trial Counts', 'fontsize',25);
title('Patient 001 first 7 days')

[h,p] = ttest2(morning_counts(inds_day_use), afternoon_counts(inds_day_use))


