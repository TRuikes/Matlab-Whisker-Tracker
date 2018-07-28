%% Initialize Matlab for tracking
clear
clc
addpath(genpath(pwd))


% Load previously saved settings
if ~exist('Settings\Settings.mat','file')
    makeSettings;
else
    
    % Overwrite default settings with settings from previous session
    load('Settings\Settings.mat')
    ot = Settings.object_threshold;
    dl = Settings.Dilationsize;
    ort = Settings.Origin_threshold;
    tt = Settings.trace_threshold;
    
    makeSettings;
    Settings.object_threshold = ot;
    Settings.Dilationsze = dl;
    Settings.Origin_threshold = ort;
    Settings.trace_threshold = tt;
end

[Settings.FileName, Settings.PathName] = uigetfile(fullfile(Settings.default_video_path,'*.*'),'Select video file');
Settings.Video = fullfile(Settings.PathName,Settings.FileName);

if Settings.use_external_specfile
    
    % See manual for requirements of an external specfile
    
    try
        % In our data, for each .dat video file, a corresponding .m file
        % exists with metadata.
        m_file = fullfile(Settings.PathName,Settings.FileName);
        m_file(end-2) = 'm';
        load(m_file)
        Settings.Video_width = Data.Resolution(1);
        Settings.Video_heigth = Data.Resolution(2);
        Settings.Nframes = Data.NFrames;
    catch
        disp('Make sure to turn of --use external specfile-- in settings or update the section loading the video specifications.')
    end
    
    
else
    
    try
        Video_object = VideoReader(Settings.Video);
        Settings.Video_width = Video_object.Height;
        Settings.Video_heigth = Video_object.Width;
        Settings.Nframes = floor(Video_object.Duration * Video_object.FrameRate);
        Settings.Video_object = Video_object;
        
        
        
        
    catch
        disp('The Video is not readable with ''VideoReader''')
        
        
    end
    
    
end






%% pre-tracking setup

% Background detection
[Output.Objects,Settings.object_threshold] = ObjectDetection(Settings);

% Track nose
Output = TrackNose(Settings, Output);

% Set parameters on single frame, repeat on multiple frames if desired
Settings.definite_settings = 0;
while Settings.definite_settings == 0
    Settings = FrameSelection(Settings);
    Settings = TrackingParameters(Settings, Output);
end






%% Video tracking
n_frames  = Settings.Nframes;

if ~exist('Nose','var')
    Nose(1:n_frames,1:2) = 1;
else
    Nose = Output.Nose;
    
end



n_tracked = 0;


Traces = cell(n_frames,1);
Origins = cell(n_frames,1);


h = waitbar(0,'Tracking Video -');
time_buffer_size = 10;
timestamps = zeros(1,time_buffer_size);

frame_idx = CostumFrameSelection(Settings, Output);
n_frames_to_track = numel(find(frame_idx));

for framenr = 1:n_frames
    
    if frame_idx(framenr)
        
        if ~isnan(Nose(framenr,1)) % Use tracked nose as indication to track frame or not
            Settings.Current_frame = framenr;
            Output = TrackFrame(Settings, Output);
            
            Traces{framenr} = Output.Traces;
            Origins{framenr} = Output.Origins;
            
            
            % Update timing variables
            n_tracked = n_tracked+1;
            time = clock;
            timestamps = circshift(timestamps,-1);
            timestamps(end) = time(4)*3600 + time(5)*60 + time(6);
            elapsed_time = timestamps(end) - timestamps(1);
            
            
            n_frames_left = n_frames_to_track - n_tracked;
            track_speed = time_buffer_size/elapsed_time;
            time_left = n_frames_left/track_speed;
            
            bar_string = sprintf('Tracking video - %d/%d \n@%1.2fFPS   Time left: %4.0fs',framenr,n_frames,track_speed,time_left);
            h.Children.Title.String = bar_string;
            
            
        end
        
    else
        Traces{framenr} = {};
        Origins{framenr} = {};
    end
    waitbar(framenr/n_frames);
    
    
end

close(h)



%% Export video
ans = '';
while ~strcmp(ans,'y') & ~strcmp(ans, 'n')
    ans = inputdlg('Print video?');
end

if strcmp(ans,'y')
    export_video = 1;
else
    export_video = 0;
end


if export_video
    i = 1;
    Settings.vidout_name = fullfile(Settings.outpath,[sprintf('Video_%d',i) Settings.export_video_raw_extention '.avi']);
    if exist(Settings.vidout_name,'file')
        flag = 1;
        i = 2;
        while flag == 1
            Settings.vidout_name = fullfile(Settings.outpath,...
                [sprintf('Video_%d',i) Settings.export_video_raw_extention '.avi']);
            
            if ~exist(Settings.vidout_name,'file')
                flag = 0;
            else
                i = i+1;
            end
            
        end
    end
    Settings.matout_name = fullfile(Settings.outpath, 'ParameterSetup');
    
    
    
    
    
    if Settings.export_video_rawtraces
        
        h = waitbar(0,'Writing Video');
        
        
        figure;
        set(gcf,'position',[100 100 round(Settings.export_video_scaling*Settings.Video_heigth) ...
            round(Settings.export_video_scaling*Settings.Video_width)]);
        set(gcf,'Units','pixels')
        set(gca,'Units','normalized')
        set(gca,'Position',[0 0 1 1])
        
        colormap('gray')
        
        
        
        vidout = VideoWriter(Settings.vidout_name,'Motion JPEG AVI');
        open(vidout)
        
        
        for framenr = 1:Settings.Nframes
            tic
            Settings.Current_frame = framenr;
            frame = LoadFrame(Settings);
            cla
            imagesc(frame)
            axis('off')
            hold('on')
            
            if ~isempty(Traces{framenr})
                for i =  1:size(Traces{framenr},2)
                    plot(Traces{framenr}{i}(:,2), Traces{framenr}{i}(:,1),'r')
                end
            end
            fdata = getframe;
            writeVideo(vidout, fdata.cdata);
            hold('off')
            
            waitbar(framenr/Settings.Nframes)
            
        end
        
        
        close(vidout)
        close(h)
        close(gcf)
    end
    
end

%% Save tracker info



Output.Traces = Traces;
Output.Origins = Origins;
save(Settings.matout_name ,'Output','Settings')


if Settings.autosave_settings
    save('Settings\Settings.mat','Settings')
end
