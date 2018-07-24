clear
clc

% Initialize
% Load and preprocess data
%
% The data is not sorted per cluster, that is, the angle is available per
% individual trace, not for a cluster troughout the video...


load('E:\Studie\Stage Neurobiologie\Videos\Analysed Videos\Video_3_tracked')
mfile = fullfile(Settings.PathName, Settings.FileName);
mfile = [mfile(1:end-4) '_Annotations'];
if exist(mfile,'var')
    load(mfile)
    manualdata = 1;
else
    manualdata =0;
end


Tracker.Traces = Output.Traces;
Tracker.Objects = Output.Objects;
Tracker.Nose = Output.Nose;
Tracker.Origins = Output.Origins;
Tracker.Headvec = Output.AngleVector;
[Tracker.Traces, Tracker.Origins] = CleanTraces(Tracker.Traces, Tracker.Origins); % Filtering noise
Tracker.Parameters = getParams(Tracker);


%Labels = TrackSide(Tracker,Settings); % Assigning side labels
%Tracker.Side = Labels.Side;
%Tracker.div = Labels.division;
%Tracker.Angles = TrackAngles(Tracker.Traces); % Extracting angles for single whiskers


%Tracker.Clusters = ClusterTraces(Tracker.Angles,Tracker.Side); % Assign cluster ID per trace
%Tracker.Angles = TrackAngles(Tracker.Traces, Labels.Angle); % Extracting angles for single whiskers

%[Tracker.Curvature] = TrackCurvature(Tracker.Traces);
%Tracker.Touch = DetectTouch(Tracker.Traces, Tracker.Objects);


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

FIG;



