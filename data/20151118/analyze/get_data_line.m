function [line_data, line_time] = get_data_line(lines, ln)

% lines: imported data lines; ln: line number.

if isempty(lines{ln})
    line_data = [];
    line_time = [];
else
    line_data = strsplit(lines{ln}, '\t');
    % the first item is time string, split it into different time units
    aux_1 = strsplit(line_data{1}, '/');
    line_time = cellfun(@(x) str2num(x), aux_1);
end