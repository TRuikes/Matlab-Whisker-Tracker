function General = getstats(Tracker, Manual)

%% Track frames of interest
c = Tracker.Clusters;
keep = zeros(1,size(c,2));

for i = 1:size(c,2)
    if ~isempty(c{i})
        keep(i) = 1;
    end
end

General.keep = keep;


%% Find unique clusters in tracker
s = Tracker.Side;
c = Tracker.Clusters;

uniquelabels = {};
for i = 1:size(c,2)
    if ~isempty(c)
        for j = 1:size(c{i}, 2)
            uniquelabels{end+1} = sprintf('%s%d',s{i}(j),c{i}(j));
        end
    end
end
uniquelabels = unique(uniquelabels);
General.tracker_labels = uniquelabels;

%% Find unique clusters in manual data
s = Manual.Side;
c = Manual.Clusters;

uniquelabels = {};
for i = 1:size(c,2)
    if ~isempty(c)
        for j = 1:size(c{i}, 2)
            uniquelabels{end+1} = sprintf('%s%s',s{i}(j), c{i}(j));
        end
    end
end
uniquelabels = unique(uniquelabels);
General.manual_labels = uniquelabels;


%% Get manual frame idx
keep = zeros(1,size(Manual.Clusters,2));
for i = 1:length(keep)
    if ~isempty(Manual.Clusters{i})
        keep(i) = 1;
    end
end
General.manual_keep = keep;
