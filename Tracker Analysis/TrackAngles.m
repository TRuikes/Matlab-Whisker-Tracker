function Angles = TrackAngles(Traces,HeadVector)
%%

nframes = size(Traces,2);
Angles = cell(1, nframes);


if nargin > 1
    SubtractHeadAngle = 1;
else
    SubtractHeadAngle = 0;
end

for i = 1:nframes
    
    if ~isempty(Traces{i})
        a= zeros(1, size(Traces{i},2));
        for j = 1:size(Traces{i},2)
            t = Traces{i}{j};
            v = t(10,:) - t(1,:);
            a(j) = atan2d(v(2), v(1));
        end
        
        
        
        
        if SubtractHeadAngle
            headangle = atan2d(HeadVector(i,2), HeadVector(i,1));
            a = a + (headangle+90);
            
        end
        
        idx = find(a > 180);
        a(idx) = a(idx)-360;
        idx = find(a < -180);
        a(idx) = a(idx) + 360;
        
        %{
        idx = find(a < -180);
        a(idx) = a(idx) + 360;
        idx = find(a > 180);
        a(idx) = a(idx) - 360;
        
        %}
        
        
        
        Angles{i} = a;
    end
end