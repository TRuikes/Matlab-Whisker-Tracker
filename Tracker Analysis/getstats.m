function General = getstats(Tracker, Manual)
%%
dataax = zeros(1, size(Tracker.Parameters,2));

for i = 1:length(dataax)
    if ~isempty(Tracker.Parameters{i})
        dataax(i) = 1;
    end
end


General.Tracker_ax = dataax;
