clear all
close all
clc

addpath(genpath(pwd))


[PathName,Files,Extension] = BatchProcessing;

if ~exist('Settings\Settings.mat','file')
    disp('Run ParameterSetup first')
end


load('Settings\Settings.mat')
Settings.batch_mode = 1;
flag = 1;
while flag
    answer=  inputdlg('Print videos (y/n)?');
    if strcmp(answer{1},'y') | strcmp(answer{1},'n')
        flag = 0;
    end
end

if answer{1} == 'y'
    export_video = 1;
else
    export_video = 0;
end


%%
if ~exist('Settings\tracker_log.txt','file')
    log_file = fopen('Settings\tracker_log.txt','w');
else
    log_file = fopen('Settings\tracker_log.txt','a+');
    
end

time = clock;
fprintf(log_file, '\r\n\r\n\r\n%2d/%02d/%02d - batch dir: %s\r\n\r\n',time(1),time(2),time(3),PathName);

fprintf('Tracking videos (%d):\n',size(Files,1))
for i = 1:size(Files,1)
    
    try
        
        time_start = clock;
        
        fprintf(log_file,'%2.0f:%2.0f:%2.0f %s\r\n',time(4),time(5),time(6),Files{i});
        
        full_name = fullfile(PathName,[Files{i} Extension]);
        fprintf('(%d/%d) - %s\n',i,size(Files,1),full_name)
        slash_idx = find(full_name == '\',1,'last');
        Settings.PathName = full_name(1:slash_idx-1);
        Settings.FileName = full_name(slash_idx+1:end);
        
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
                Settings.Video = fullfile(Settings.PathName, Settings.FileName);
                Video_object = VideoReader(Settings.Video);
                Settings.Video_width = Video_object.Height;
                Settings.Video_heigth = Video_object.Width;
                Settings.Nframes = floor(Video_object.Duration * Video_object.FrameRate);
                Settings.Video_object = Video_object;
                
                
                
                
            catch
                disp('The Video is not readable with ''VideoReader''')
                
                
            end
            
        end
        
        [Output.Objects,~] = ObjectDetection(Settings);
        Output = TrackNose(Settings, Output);
        
        Nose = Output.Nose;
        n_frames_to_track = numel(find(~isnan(Nose(:,1))));
        n_frames = Settings.Nframes;
        n_tracked = 0;
        
        
        Traces = cell(n_frames,1);
        Origins = cell(n_frames,1);
        
        
        h = waitbar(0,'Tracking Video -');
        time_buffer_size = 10;
        timestamps = zeros(1,time_buffer_size);
        
        for framenr = 1:n_frames
            
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
            waitbar(framenr/n_frames);
            
            
        end
        
        close(h)
        
        Output.Traces = Traces;
        Output.Origins = Origins;
        save(fullfile(Settings.PathName, [Settings.FileName(1:end-4) '_tracked']),'Output','Settings')
        
        
        time_end = clock;
        
        
        n_empty = numel(find(isnan(Output.Nose(:,1))));
        n_tot = Settings.Nframes;
        n_tracked=  n_tot-n_empty;
        
        tot_time = time_end(4)*3600+time_end(5)*60+time_end(6) - ...
            time_start(4)*3600 - time_start(5)*60 - time_start(6) ;
        
        fps = n_tracked/tot_time;
        
        n_traces = 0;
        for q = 1:size(Output.Traces,1)
            n_traces = n_traces + size(Output.Traces{q},2);
        end
        
        fprintf(log_file,'\r\t Time elapsed: %.0f\r\n',tot_time);
        fprintf(log_file,'\r\t # Frames: %d\r\n',n_tot);
        fprintf(log_file,'\r\t # Tracked: %d\r\n',n_tracked);
        fprintf(log_file,'\r\t Speed: %2.2f\r\n',fps);
        fprintf(log_file,'\r\t # Traces: %d\r\n\r\n',n_traces);
        
        
        
        if export_video
            h = waitbar(0,'Writing Video');
            
            
            figure;
            set(gcf,'position',[100 100 round(Settings.export_video_scaling*Settings.Video_heigth) ...
                round(Settings.export_video_scaling*Settings.Video_width)]);
            set(gcf,'Units','pixels')
            set(gca,'Units','normalized')
            set(gca,'Position',[0 0 1 1])
            
            colormap('gray')
            
            
            vidout = VideoWriter(fullfile(Settings.PathName,[Settings.FileName(1:end-4) Settings.export_video_raw_extention ]),'Motion JPEG AVI');
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
    catch
        fprintf(log_file,'\r\n An error occured!\r\n\r\n');
    end
    
end



fclose(log_file);
fprintf('Finished!\n')