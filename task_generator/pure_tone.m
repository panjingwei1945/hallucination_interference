fs = 192000;
nBits = 16;
fq = 1000;
dur = 5000; %ms

timestamp = (0:1/192000:dur/1000);
waveform = sin(2 * pi * fq * timestamp);

sound(waveform, fs, nBits);


%% empty tone





