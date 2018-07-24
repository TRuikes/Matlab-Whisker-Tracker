function Clusters = ClusterTraces(Angles,Side)
%%

% find the number of traces per side per frame
nl = zeros(1, size(Side,2));
nr = zeros(1, size(Side,2));
for i = 1:size(Side,2)
    nl(i) = numel(find(Side{i} == 'L'));
    nr(i) = numel(find(Side{i} == 'R'));
end
nl = medfilt1(nl, 10);
nr = medfilt1(nr, 10);


% find the spread of whiskers per fram (delta-angle-left, dal)
dal = zeros(1,size(Angles,2));
dar = zeros(1,size(Angles,2));
for i = 1:size(Angles,2)
    lidx = find(Side{i} == 'L');
    if ~isempty(lidx)
        dal(i) = max(abs(Angles{i}(lidx))) - min(abs(Angles{i}(lidx)));
    end
    ridx = find(Side{i} == 'R');
    if ~isempty(ridx)
        dar(i) = max(abs(Angles{i}(ridx))) - min(abs(Angles{i}(ridx)));
    end
end
dal = medfilt1(dal, 20);
dar = medfilt1(dar, 20);
dt = dal+dar;
dt = dt./max(dt);

% decide to throw a frame is spread is too small
keep_idx = zeros(1, size(Angles,2));
keep_idx( dt > 0.3) = 1;




Clusters = cell(1,size(Angles,2));

% Determine section type (ie # of traces)
for i = 1:size(Angles,2)
    
    if keep_idx(i) == 0
        continue
    end
    
    
    cluster = zeros(1,length(Side{i}));
    
    % Process leftside
    lidx = find(Side{i} == 'L');
    
    % if there are only 1 or 2 traces
    if nl(i) > 0 && nl(i) <= 2 
        
        for j = 1:length(lidx)
            cluster(lidx(j)) = 1;
        end
        
        
        % if there are 3 or 4 traces
    elseif nl(i)> 2 && nl(i) <= 6
        
        b1 = 0.5; % classification boundary
        angles = abs(Angles{i}(lidx)) - min(abs(Angles{i}(lidx)));
        angles = angles./max(angles);
        
        for j = 1:length(lidx)
            if angles(j) <= b1
                cluster(lidx(j)) = 1;
            elseif angles(j) > b1
                cluster(lidx(j)) = 2;
            end
        end
        
        % if there are more than 4 traces
    elseif nl(i) > 6
        
        b1 = 0.3;
        b2 = 0.7; % classification boundaries
        angles = abs(Angles{i}(lidx)) - min(abs(Angles{i}(lidx)));
        angles = angles./max(angles);
        
        for j = 1:length(lidx)
            if angles(j) <= b1
                cluster(lidx(j)) = 1;
            elseif angles(j) > b1 && angles(j) <= b2
                cluster(lidx(j)) = 2;
            elseif angles(j) > b2
                cluster(lidx(j)) = 3;
            end
        end
        
    end
    
    
    
    
    % Process rightside
    ridx = find(Side{i} == 'R');
    
    % if there are only 1 or 2 traces
    if  nr(i) > 0 && nr(i) <= 2 
        
        for j = 1:length(ridx)
            cluster(ridx(j)) = 1;
        end
        
        
        % if there are 3 or 4 traces
    elseif  nr(i) > 2 &&  nr(i) <= 6
        
        b1 = 0.5; % classification boundary
        angles = abs(Angles{i}(ridx)) - min(abs(Angles{i}(ridx)));
        angles = angles./max(angles);
        
        for j = 1:length(ridx)
            if angles(j) <= b1
                cluster(ridx(j)) = 1;
            elseif angles(j) > b1
                cluster(ridx(j)) = 2;
            end
        end
        
        % if there are more than 4 traces
    elseif nr(i)> 6
        
        b1 = 0.3;
        b2 = 0.7; % classification boundaries
        angles = abs(Angles{i}(ridx)) - min(abs(Angles{i}(ridx)));
        angles = angles./max(angles);
        
        for j = 1:length(ridx)
            if angles(j) <= b1
                cluster(ridx(j)) = 1;
            elseif angles(j) > b1 && angles(j) <= b2
                cluster(ridx(j)) = 2; 
            elseif angles(j) > b2
                cluster(ridx(j)) = 3;
            end
        end
        
    end
    
    
    if any(cluster == 0)
        
        null_idx = find(cluster == 0);
        if length(null_idx) == 1
            if ismember(null_idx, ridx) & length(ridx) == 1
                cluster(null_idx) = 1;
            elseif ismember(null_idx, lidx) & length(lidx) == 1
                cluster(null_idx) = 1;
            end
        end
        
        if any(cluster == 0)
            %keyboard
            cluster(cluster == 0) = NaN;
        end
        
    end
    
    Clusters{i} = cluster;
    
    
end