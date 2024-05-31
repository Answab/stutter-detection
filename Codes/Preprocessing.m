clc;
clear all;
% load sheets
ttds = tabularTextDatastore("C:\Users\ANSWEB\Desktop\Minor Project\dataset",'IncludeSubfolders',true,"FileExtensions",".csv");

% Set the number of frequency bins
num_bins = 256;

% Set the window size and overlap size in seconds
win_size_sec = 0.025;  % 25 ms
overlap_size_sec = 0.010;  % 10 ms

%Defining sampling frequency
fs=16000;
 
% Set the window size and overlap (in samples)
win_size = round(win_size_sec * fs);
overlap = round(overlap_size_sec * fs);

% Set the desired block length in seconds
block_length = 4;

% figure
fig=figure('visible','off');

for j=1:length(ttds.Files)
    % Load the audio file and csv
    item=ttds.Files(j);
    [~,filename] = fileparts(item);
    csv_file = readmatrix(item{1});
    audio_src=fullfile('C:\Users\ANSWEB\MATLAB Drive\Fluentnet\new', sprintf('%s%s', filename, '.wav'));
    [audio, fs] = audioread(audio_src);

    % Calculate the number of samples per block
    samples_per_block = block_length * fs;
    
    % Calculate the total number of blocks
    currentLength = length(audio);
    num_blocks = ceil(currentLength / samples_per_block);
    
    % Determine the amount of padding needed
    desiredLength = num_blocks * block_length * fs; % Desired length in seconds
      
    paddingLength = desiredLength - currentLength;
    if paddingLength < 3*fs
        paddedAudio = padarray(audio, paddingLength, 0, 'post');% 'post' to pad at the end of the signal
    else
        num_blocks = num_blocks-1;
        block_end = num_blocks * samples_per_block;
        paddedAudio =audio(1:block_end, :); % cut the remaining
    end
    

    % annotation sub matrix indices
    ann_indi(1:num_blocks+1)=1;
    % Divide the audio file into equal-length blocks
    for i = 1:num_blocks
        block_start = (i - 1) * samples_per_block + 1;
        block_end = i * samples_per_block;
        block = paddedAudio(block_start:block_end, :);

        % finding classification by slicing mother csv
        ending_time = i * block_length;
        end_matrix=csv_file(:,3);
        [~, idx] = min(abs(end_matrix - ending_time));
        ann_indi(i+1)=idx;
        csv_sub=csv_file(ann_indi(i):idx, 4);

        uniques=unique(csv_sub);
        switch uniques(end) % avoiding the remining classifications (less probability)
            case 0
                dest='C:\Users\ANSWEB\Desktop\deeptransfer\Dataset2\0';
            case 1
                dest='C:\Users\ANSWEB\Desktop\deeptransfer\Dataset2\1';
            case 2
                dest='C:\Users\ANSWEB\Desktop\deeptransfer\Dataset2\2';
            case 3
                dest='C:\Users\ANSWEB\Desktop\deeptransfer\Dataset2\3';
            case 4
                dest='C:\Users\ANSWEB\Desktop\deeptransfer\Dataset2\4';
            case 5
                dest='C:\Users\ANSWEB\Desktop\deeptransfer\Dataset2\5';
        end

        % Compute the spectrogram using STFT
        [S, f, t, p] = spectrogram(block, win_size, overlap,num_bins,fs);
        
        % Convert the magnitude spectrogram to dB
        S_dB = 20*log10(abs(S));      
    
        % Display the spectrogram as an image
        imagesc(t, f, S_dB);

        axis xy; % flip the y-axis to put low frequencies at the bottom
        colorbar('off');
        set(gca, 'visible', 'off');

        new_filename=strcat(filename,'-',string(i));
        new_filename = fullfile(dest, sprintf('%s%s', new_filename, '.png'));
        saveas(fig,new_filename);
    end
    disp(j)
end

disp("end");