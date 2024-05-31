clc;

% Set the path to the directory containing the audio files
audio_dir = 'C:\Users\ANSWEB\Desktop\Minor Project\dataset';

% Set the path to the directory where the resampled audio files will be saved
output_dir = 'C:\Users\ANSWEB\MATLAB Drive\Fluentnet\new';

% Create an AudioDatastore object to load the audio files
ads = audioDatastore(audio_dir,'IncludeSubfolders',true);

% Set the target sampling rate
target_fs = 16000;

% Set the down-sampling factor
downsample_factor = round(22050 / target_fs);

% Initialize the counter variable
count = 1;

% Loop over the audio files in the datastore and resample each one
while hasdata(ads)
    % Load the next audio file
    [x, fs] = read(ads);
    
    % Resample the signal
    y = resample(x, 1, downsample_factor);
    
    % Get the subfolder of the current audio file
    subfolder = fileparts(ads.Files{count});

     % Set the target filename and location
    [~,filename,ext] = fileparts(ads.Files{count});
    new_filename = fullfile('C:\Users\ANSWEB\MATLAB Drive\Fluentnet\new', sprintf('%s%s', filename, '.wav'));
    
    audiowrite(new_filename, y, target_fs);
    
    % Increment the counter
    count = count + 1;
end
disp("done");
