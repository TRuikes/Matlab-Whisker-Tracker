function Tracker = CleanTraces(Tracker)
%%
filterSettings;
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



Traces = Tracker.Traces;
Parameters = Tracker.Parameters;
% Create boolean cell with tag to keep/reject per trace
Valid_trace = cell(1,nframes);
for i = 1:nframes
   if tracked_frames(i)
       Valid_trace{i} = ones(1, size(Traces{i},2)); % keep all traces by default
   else
       Valid_trace{i} = zeros(1, size(Traces{i},2)); % reject all traces by default
   end
end

% Filter based on minimum length and distance from nose
for i = 1:nframes
    for j = 1:length(Valid_trace{i})
        
     
        
        l = Parameters{i}(j,7);
        d = sqrt(sum( (Parameters{i}(j,9:10)).^2));
         
         
        if l <= Settings.min_trace_length 
            Valid_trace{i}(j) = 0;
           
        end
                
        if d > Settings.max_dist_trace_nose
            Valid_trace{i}(j) = 0;           
        end
        
        
    end
end


% Create a new trace set with fits of the measured traces
Traces_clean = cell(nframes,1);
Parameters_clean = cell(1, nframes);

h = waitbar(0,'fitting');
for i = 1:nframes
    nclean = numel(find(Valid_trace{i}));
    idx = find(Valid_trace{i});
    Tsave = cell(1, nclean);
    Psave = zeros(nclean, size(Parameters{i},2));
    
    for j = 1:length(idx)
        trace = Traces{i}{idx(j)};
        params = Parameters{i}(idx(j),:);
        
       if size(trace, 1) < 10
           fit_degree = Settings.fit_degree_small;
       elseif size(trace, 1) >= 10 && size(trace, 1) < 20
           fit_degree = Settings.fit_degree_medium;
       else
           fit_degree = Settings.fit_degree_large;
       end
        
        pX = polyfit(1:size(trace,1)- Settings.cutoff,...
            trace(1:end-Settings.cutoff,1)', fit_degree);
        pY = polyfit(1:size(trace,1)- Settings.cutoff,...
            trace( 1:end-Settings.cutoff,2)', fit_degree);
        
        fitax = 1:size(trace,1)-Settings.cutoff+4;
        
       
        Tsave{j} = [polyval(pX, fitax); polyval(pY, fitax)]';
        Psave(j,:) = params;      
   
    end
    
    Traces_clean{i} = Tsave;
    Parameters_clean{i} = Psave;
    
    waitbar(i/nframes)
end
        
close(h)


Tracker.Traces_clean = Traces_clean;
%Tracker.Parameters_clean = Parameters_clean;
