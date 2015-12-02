
function s = make_and_play_tone_cosRamp(cf, d, sf, play_sound_flag)
%% cosine ramp

if nargin < 3
    sf = 22050;                 % sample frequency (Hz)
    play_sound_flag = 0;
end

% prepare tone
% cf = 2000;                  % carrier frequency (Hz)
% d = 0.3;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation

% prepare ramp
dr = d / 10;
nr = floor(sf * dr);
r = sin(linspace(0, pi/2, nr));
r = [r, ones(1, n - nr * 2), fliplr(r)];

% make ramped sound
s = s .* r;

if play_sound_flag == 1
    sound(s, sf);               % sound presentation
end
% pause(d + 0.5);             % waiting for sound end
% plot(s);

