function out = CleanTraces(Tracker, Settings)
%%
nframes = size( Tracker.Traces,1);
tracked_frames = ones(1,nframes);

Nose = Tracker.Nose;
frame_heigth = size(Tracker.Objects, 1);
frame_width = size(Tracker.Objects,2);


% Filter points with nose at border
for i = 1:nframes
    if isnan(Nose(i,1)) || isnan(Nose(i,2))
        tracked_frames(i) = 0;
        continue
    end
    
    if Nose(i,1) < Settings.min_nose_dist || ...
            Nose(i,2) > frame_heigth - Settings.min_nose_dist
        tracked_frames(i) = 0;
        continue
    end
    
    if Nose(i,2) < Settings.min_nose_dist || ...
            Nose(i,2) > frame_width - Settings.min_nose_dist
        tracked_frames(i) = 0;
    end
    
end

% Filter frames too large acceleration on nose
da = diff(Nose,1);
da = sqrt( sum( da.^2,2));
da = medfilt1(da,3);
da(end+1) = 0;
tracked_frames(da > Settings.max_accel) = 0;

% Filter frames with too few neighbouring tracked frames
frame_density = conv2(tracked_frames, ones(1,10)./10,'same');
tracked_frames(frame_density < Settings.frame_density) = 0;





idx = find(tracked_frames);
idx2 = find(~tracked_frames);


figure(1)
clf
hold on
scatter(idx,Tracker.Nose(idx,2),'g','filled')
scatter(idx2,Tracker.Nose(idx2,2),'r','filled')
