clear
clc

% Initialize
% Load and preprocess data
%
% The data is not sorted per cluster, that is, the angle is available per
% individual trace, not for a cluster troughout the video...
datapath = 'E:\Studie\Stage Neurobiologie\Videos\Analysed Videos';
files = dir(fullfile(datapath, '*.mat'));


%%

close all
for fidx= 1:size(files,1)
    clearvars -except files fidx datapath
    load(fullfile(files(fidx).folder,files(fidx).name))
    mfile = fullfile(Settings.PathName, Settings.FileName);
    mfile = [mfile(1:end-4) '_Annotations'];
    if exist(mfile,'var')
        load(mfile)
        manualdata = 1;
    else
        manualdata = 0;
    end
    
    
    Tracker.Traces = Output.Traces;
    Tracker.Objects = Output.Objects;
    Tracker.Nose = Output.Nose;
    Tracker.Origins = Output.Origins;
    Tracker.Headvec = Output.AngleVector;
    Tracker.Parameters = getParams(Tracker,'raw');
    figpath = fullfile(datapath,'figures');
    Tracker =  CleanTraces(Tracker); % Filtering noise
    Tracker.Parameters_clean = getParams(Tracker,'clean');
    
    
    % Tracker = DetectTouch(Tracker);
    
    
    
    
    
    %Tracker.Clusters = ClusterTraces(Tracker.Angles,Tracker.Side); % Assign cluster ID per trace
    %Tracker.Angles = TrackAngles(Tracker.Traces, Labels.Angle); % Extracting angles for single whiskers
    
    %[Tracker.Curvature] = TrackCurvature(Tracker.Traces);
    
    
    
    if manualdata
        Manual.TracesRaw = CurvesByFrame;
        out = ConvertAnnotations(CurvesByFrame); % Store manual data in same format as tracker data
        Manual.Traces = out.Traces;
        Manual.manTouch = out.Touch;
        Manual.Objects = Tracker.Objects;
        Manual.Side = out.Labels.Side;
        Manual.Angles = TrackAngles(Manual.Traces, Labels.Angle); % Extract angles for single whiskers
        Manual.Clusters = out.Labels.Clusters;
        [Manual.Curvature] = TrackCurvature(Manual.Traces);
        Manual.Touch = DetectTouch(Manual.Traces, Tracker.Objects);
    else
        Manual = [];
    end
    
    General = getstats(Tracker,Manual);
    
    FIG_RAWDATA;
    FIG_CLEAN;
    
    %%
    idx = find(files(fidx).name == '_',1,'last');
    vidname = [files(fidx).name(1:idx-1) '_clean'];
    vidout = fullfile(files(fidx).folder, vidname);
    v = VideoWriter(vidout,'Motion JPEG AVI');
    
    open(v)
    figure(5)
    clf
    colormap gray
    nframes=  size(Tracker.Traces,1);
    for ii = 1:nframes
        Settings.Current_frame = ii;
        f = LoadFrame(Settings);
        imagesc(f);
        hold on
        
        
        for iii = 1:size(Tracker.Traces_clean{ii},2)
            t = Tracker.Traces_clean{ii}{iii};
            plot(t(:,2), t(:,1), 'r')
        end
        
        
        hold off


        frame = getframe;
        writeVideo(v, frame.cdata);
    end
    
    close(v)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end



