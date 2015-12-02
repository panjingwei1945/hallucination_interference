timing = 'random';
% timing = 'fixed_intv';
fbase = 2000;

chord_interval = 1; % in octave
chord_num = 1;

fs = 48000;

num_beeps = 40;

fixed_blank_interval = 0.4;
rand_blank_range = [0.1 0.8];

if strcmp(timing, 'random')
    blank_interval = randi([rand_blank_range(1) rand_blank_range(2)].*fs, 1, num_beeps); % Random sound interval, 0.2-0.6 sec.
elseif strcmp(timing, 'fixed_intv')
    blank_interval = repmat(fixed_blank_interval*fs, 1,num_beeps);
end
blank_dur = 0.4; % fixed sound interval
% 

total_dur = 20;
sound_dur = 0.15;
sound_interval = sound_dur + blank_dur;

fq_hi_lim = 2^((chord_num-1)*chord_interval)*fbase;


% s = zeros(1,fs*total_dur);
s = [];

beep = zeros(1,fs*sound_dur);

for j = 1:chord_num
    fq(j) = fbase*2^((j-1)*chord_interval);
    single_tone = make_and_play_tone_cosRamp(fq(j), sound_dur ,fs,0);
    beep = beep + single_tone;
%     plot(single_tone);
end
beep = beep./chord_num;    


for i = 1:num_beeps
    s = [s beep zeros(1, blank_interval(i))];
end
% 
% for i=1:(total_dur/sound_interval)
%     range1 = (i-1)*sound_interval*fs+1;
%     range2 = range1 + sound_dur*fs -1;
%     s(range1:range2) = beep;
% end

%%
sound(s, fs);
%% Load pre-recorded sound
[cue,fs] = audioread('cue.wav');
pre_cue_dur = 0.5; % sec
post_cue_dur = 1;
cue = [zeros(pre_cue_dur*fs, 1); cue; zeros(post_cue_dur*fs, 1)];
[endsound,fs] = audioread('endsound_edited.wav');
[presound,fs] = audioread('presound_edited.wav');
%% Combine sounds
sound_combined = [presound; cue; s'; endsound];
%% test sound
sound(sound_combined, fs);

%% write wav file
if ~isdir(date)
    mkdir(date);
end
file_name = sprintf('chord_%s_C%d_%d_%dk.wav', timing, chord_num , fbase, round(fq_hi_lim))
audiowrite(sprintf('%s/%s', date, file_name), sound_combined, fs);




