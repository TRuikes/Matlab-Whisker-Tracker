nframes = size(Manual.Traces,1);
tracked_frames = zeros(1, nframes);
for i = 1:nframes
    if ~isempty(Manual.Traces{i})
        tracked_frames(i) = 1;
    end
end
x1 = find(tracked_frames,1,'first');
x2 = find(tracked_frames,1,'last');



% Get theta per manual tracked traces
manual_labels = Manual.Label_names;
nlabels = size(manual_labels, 2);
theta_manual(1:nframes,1:nlabels) = NaN;


filterSettings;
c1 = Settings.colors.manual;
c2 = Settings.colors.tracker_dark;


theta_tracker = [];
for i = x1:x2
   
    
    ntraces = size(Manual.Parameters{i},1);
    for j = 1:ntraces
        idx = find(strcmp(Manual.Labels{i}{j}, manual_labels));
        theta_manual(i,idx) = Manual.Parameters{i}(j,5);
    end
    
   
    
    
    ntraces = size(Tracker.Parameters_clean{i},1);
    if ntraces> 0
        theta_tracker(end+1:end+ntraces, 1:2) =[ ones(ntraces,1)*i, Tracker.Parameters_clean{i}(:,5)];
    end
    
    
    
    
end


f = figure;
f.Units = 'normalized';
f.Position = [0 0 1 1];

hold on
scatter(theta_tracker(:,1), theta_tracker(:,2), 'MarkerFaceColor',c2,'MarkerEdgeColor',c2)
plot(x1:x2,theta_manual(x1:x2,:),'r','LineWidth',1.5)


saveas(gcf,[Tracked_Videos.ExportNames{fidx} '_thetas.png'])