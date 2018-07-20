clear
clc


%% Initialize
% Load and preprocess data
%
% The data is not sorted per cluster, that is, the angle is available per
% individual trace, not for a cluster troughout the video...


load('E:\Studie\Stage Neurobiologie\Videos\Mouse 47\R17\Data_15_tracked')
load('E:\Studie\Stage Neurobiologie\Videos\Mouse 47\R17\Data_15_Annotations')
Tracker.TracesRaw = Output.Traces;
Tracker.Traces = Output.Traces;
Tracker.Objects = Output.Objects;
Tracker.Traces = CleanTraces(Tracker.Traces); % Filtering noise
Labels = TrackSide(Tracker,Settings); % Assigning side labels
Tracker.Side = Labels.Side;
Tracker.Angles = TrackAngles(Tracker.Traces); % Extracting angles for single whiskers


Tracker.Clusters = ClusterTraces(Tracker.Angles,Tracker.Side); % Assign cluster ID per trace
Tracker.Angles = TrackAngles(Tracker.Traces, Labels.Angle); % Extracting angles for single whiskers

[Tracker.Curvature] = TrackCurvature(Tracker.Traces);
Tracker.Touch = DetectTouch(Tracker.Traces, Tracker.Objects);



%%

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



%%
General = getstats(Tracker,Manual);



