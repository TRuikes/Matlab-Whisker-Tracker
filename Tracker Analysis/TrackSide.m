function Labels = TrackSide(Output, Settings, Labels)
% Adds 'Side' field to Labels struct
%% Estimate midpoint across video
Traces = Output.Traces;
o = Output.Objects;
headsize = 150;

nframes = size(Traces,2);
midpoint(1:nframes,2) = NaN;
for i = 1:nframes
    if ~isempty(Traces{i})
        pts = zeros(size(Traces{i},2),2);
        for j = 1:size(Traces{i},2)
            pts(j,:) = Traces{i}{j}(1,:);
        end
        midpoint(i,:) = mean(pts,1);
    end
end

b = 1/10*ones(1,10);
a = 1;
xfit  = filter(b,a,midpoint(:,1));
xfit = fillgaps(xfit);
yfit = filter(b,a,midpoint(:,2));
yfit = fillgaps(yfit);
mid(:,1) = xfit;
mid(:,2) = yfit;


%% Assign label


vec(1:nframes,1:2) = NaN;
theta(1:nframes) = NaN;
l(1:nframes,1:2) = NaN;
Side = cell(1,nframes);
fn = @(a,b,x) a*x + b;

h = waitbar(0, 'Assigning side labels');
for i = 1:nframes
    
    Settings.Current_frame = i;
    f = LoadFrame(Settings);
    f = imbinarize(f, Settings.Silhouettethreshold);
    f = imerode(~f, strel('diamond',5));
    f(find(o)) = 0;
    measure_idx = find(sum(f,2) >= 0.3*max(sum(f,2)));   
    
    sf = sum(f(measure_idx,:),1); %#ok<FNDSB>
    [~,midline] = max(sf);
    dpl = mid(i,2) - midline;
    
    t1 = acosd(dpl/headsize);
    theta(i) =  90-t1;
    
    a = sqrt(abs(headsize^2 - dpl^2));
    
    vx = dpl/sqrt(sum(dpl^2 + a^2));
    vy = a / sqrt(sum(dpl^2 + a^2));
    
    vec(i,:) = [vx,vy];
    l(i,:) = [vy/vx, mid(i,1)-( (vy/vx)*mid(i,2))];
    
  
    
    for j = 1:size(Traces{i},2)
        t = Traces{i}{j};
        v = t(1,:) - t(10,:);
        a(j) = atan2d(v(2),v(1)) - theta(i);
        
        if t(1,1) <= fn(l(i,1), l(i,2), t(1,2))
            if l(i,1) >= 0             
                Side{i}(j) = 'L';
            else
                clr = 'b';
                Side{i}(j) = 'R';
            end
        else
            if l(i,1) < 0               
                Side{i}(j) = 'L';
            else               
                Side{i}(j) = 'R';

            end
        end
        
        % if a(j) <= 0
        %     clr = 'b';
        % else
        %     clr = 'r';
        % end
        
    end
    
    
    waitbar(i/nframes)
 
end
close(h)
Labels.Side = Side;
Labels.Angle = vec;

