clear
clc

% Initialize
% Load and preprocess data
%
% The data is not sorted per cluster, that is, the angle is available per
% individual trace, not for a cluster troughout the video...
datapath = 'E:\Studie\Stage Neurobiologie\Videos\VideoDatabase\Tracker Performance';
Files = dir(fullfile(datapath,'*_Annotations_Tracker.mat'));



printvid = 0;
figraw = 0;
figclean = 0;
figcompare = 0;
printtracked = 0;

parentfolder = 'diff';

%%
close all
for fidx = 1:size(Files,1)
    clear Tracker Manual
    loadfile = fullfile(Files(fidx).folder, Files(fidx).name);
    load(loadfile)
    mfile = fullfile(datapath, Settings.FileName);
    mfile = [mfile(1:end-4) '_Annotations.mat'];
    
    if exist(mfile,'file')
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
    Tracker =  CleanTraces(Tracker,0); % Filtering noise
    Tracker.Parameters_clean = getParams(Tracker,'clean');
    Tracker = DetectTouch(Tracker);
    
    
    
    
    if manualdata
        Manual.TracesRaw = CurvesByFrame;
        out = ConvertAnnotations(CurvesByFrame); % Store manual data in same format as tracker data
        Manual.Traces = out.Traces';
        Manual.Objects= Output.Objects;
        Manual.Nose = Output.Nose;
        Manual.Headvec = Output.AngleVector;
        Manual.Parameters = getParams(Manual,'raw');
        Manual.Labels = out.Labels.Full;
        Manual.Label_names = out.Labels.Names;
        
        
        
    else
        Manual = [];
    end
    
    
    if figraw
        FIG_RAWDATA;
    end
    
    if figclean
        FIG_CLEAN;
    end
    
    if manualdata & figcompare
        FIG_COMPARE;
    end
    %
    
    
    if printvid
        switch(parentfolder)
            case 'same'
                vidout = [Tracked_Videos.ExportNames{fidx} '_clean'];
            case 'diff'
                vidout = [datapath '\' tokens{end}];
        end
        
        v = VideoWriter(vidout,'Motion JPEG AVI');
        filterSettings;
        open(v)
        figure;
        set(gcf,'position',[100 100 round(Settings.export_video_scaling*Settings.Video_heigth) ...
            round(Settings.export_video_scaling*Settings.Video_width)]);
        set(gcf,'Units','pixels')
        set(gca,'Units','normalized')
        set(gca,'Position',[0 0 1 1])
        ax = gca;
        colormap(ax,'gray')
        nframes=  size(Tracker.Traces,1);
        
        c1 = Settings.colors.tracker_dark;
        c2 = Settings.colors.manual_light;
        for ii = 1:nframes
            Settings.Current_frame = ii;
            f = LoadFrame(Settings);
            cla(ax)
            imagesc(ax,f);
            hold on
            
            
            for iii = 1:size(Tracker.Traces_clean{ii},2)
                t = Tracker.Traces_clean{ii}{iii};
                plot(ax,t(:,2), t(:,1), 'color',c1,'LineWidth',2)
            end
            
            for iii = 1:size(Tracker.Touch{ii},2)
                if ~isempty(Tracker.Touch{ii}{iii})
                    pts = Tracker.Touch{ii}{iii};
                    pt = [];
                    for iiii = 1:length(pts)
                        pt(iiii,:) = Tracker.Traces_clean{ii}{iii}(pts(iiii),:);
                    end
                    
                    scatter(ax, pt(:,2), pt(:,1), 'MarkerFaceColor',c1,'MarkerEdgeColor','y')
                    
                    
                end
            end
            
            
            if manualdata
                for iii = 1:size(Manual.Traces{ii},2)
                    t = Manual.Traces{ii}{iii};
                    plot(ax, t(:,2), t(:,1), 'color', c2,'LineStyle','--','LineWidth',2)
                end
                
                
                
            end
            hold off
            drawnow
            
            frame = getframe;
            writeVideo(v, frame.cdata);
            
        end
        
        close(v)
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    save(loadfile, 'Output','Tracker','Manual','Settings')
    
    
    
    
    
    
    
    
end



