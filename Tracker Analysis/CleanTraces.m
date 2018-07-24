function [Traces,Origins] = CleanTraces(Traces,Origins,dist_mid)
%%

if nargin == 2
    dist_mid = 500;
end


mid(1:size(Traces,1),1:2) = NaN;
for i = 1:size(Traces,1)
    o = [];
    for j = 1:size(Traces{i},2)
        if size(Traces{i}{j},1) >= 20
            o(end+1,:) = Traces{i}{j}(1,:); %#ok<*AGROW>
        end
    end
    
    if ~isempty(o)
        mid(i,:) = mean(o,1);
    end
end


b = 1/10*ones(1,10);
a = 1;
xfit  = filter(b,a,mid(:,1));
xfit = fillgaps(xfit);
yfit = filter(b,a,mid(:,2));
yfit = fillgaps(yfit);
mid(:,1) = xfit;
mid(:,2) = yfit;


Tkeep = {};
Okeep = {};
Tdismiss = {};
for i = 1:size(Traces,1)
    
    keeptick = 1;
    dismisstick = 1;
    
    
    if ~isempty(Traces{i})
        for j = 1:size(Traces{i},2)
            pt = Traces{i}{j}(1,:);
            
            dist = sqrt( sum(( pt-mid(i,:)).^2));
            l = size(Traces{i}{j},1);
            if dist < dist_mid && l > 10
                Tkeep{i}{keeptick} = Traces{i}{j};
                Okeep{i}(keeptick,:) = Origins{i}(j,1:2);
                keeptick = keeptick+1;
            else
                Tdismiss{i}{dismisstick} = Traces{i}{j};
                dismisstick = dismisstick+1;
            end
        end
    end
    
    
end

Traces = Tkeep;
Origins = Okeep;


%}
%{
Tkeep = {};

h = waitbar(0,'stuff')
for i = 1:Settings.Nframes
    if i > size(Traces,2)
        break
    end
    if ~isempty(Traces{i})
        keep_idx = ones(1,size(Traces{i},2));
        
        for j = 1:size(Traces{i},2)
            for k = 1:size(Traces{i},2)
                if j ~= k
                    d =[];
                    t1 = Traces{i}{j};
                    t2 = Traces{i}{j};
                    for l = 1:size(t1,1)
                        d(l) = mean(sqrt( sum( (t2-t1(l,:)).^2,2)));
                    end
                    
                    dist = mean(d);
                    
                    if dist < 21
                        if size(t1,1) <= size(t2,1)
                            keep_idx(j) = 0;
                        else
                            keep_idx(k) = 0;
                        end
                    end
                end
            end
        end
        
        keeptick = 1;
        for j = 1:length(keep_idx)
            if keep_idx(j)
                Tkeep{i}{keeptick} = Traces{i}{j};
                keeptick = keeptick+1;
            end
        end
        
        
    end
    
    waitbar(i/Settings.Nframes)
end
close(h)

%}