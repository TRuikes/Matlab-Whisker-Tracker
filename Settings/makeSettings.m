%% Interface Settings
% Not overwritten in new sessions

% File details
Settings.video_extension = '.dat';
Settings.default_video_path = 'E:\Studie\Stage Neurobiologie\Videos\Mouse 47';

Settings.use_external_specfile = 1; % Use if any otherformat than the formats
                                    % supported by the 'VideoReader'
                                    % function:
                                    % https://nl.mathworks.com/help/matlab/import_export/supported-video-file-formats.html
Settings.costum_background = 1;
Settings.batch_mode = 0; % don't touch this one                                    
                                    
       
% Tracker export settings
Settings.outpath = 'E:\Studie\Stage Neurobiologie\Videos\Analysed Videos';
Settings.autosave_settings = 1; % update settings to those chosen in current session
Settings.export_video_rawtraces = 1; % export video with raw traces in video path
Settings.export_video_scaling = 1;
Settings.export_video_raw_extention = '_rawtraces';




%% Hidden Tracking Settings
% Nose tracking
Settings.TrackNose = 1;
Settings.Silhouettethreshold = 0.3; % Also used in whisker tracking
Settings.nose_interval = 10; % Interval for sampling video; nr of frames

Settings.object_pixel_ratio = 0.15;
Settings.dist_from_edge = 5; % minimum distance from frame edge;
Settings.n_background_samples = 30; % number of sample frames to extract background


Settings.extrapolationsize = 7;

% Trace propagation settings
Settings.circle_start = -25;
Settings.circle_end = 25;
Settings.stepsize = 5;
Settings.minimum_traclength = 5;

%% GUI Tracking Settings
                            
% Object detection
Settings.object_threshold = 0.45; % Default threshold

% Frame Tracking
Settings.Dilationsize = 20;
Settings.Origin_threshold = 0.05; % Sensitivity towards trace origins
Settings.trace_threshold = 0.99; % stop criterium for single trace tracking

