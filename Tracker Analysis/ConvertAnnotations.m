function Output = ConvertAnnotations(CurvesByFrame)
%%


i = 350;


Rlabel = cell(1, size(CurvesByFrame,1));
Llabel = cell(1, size(CurvesByFrame,1));



% Find unique whiskers
uniquewhiskers = {};
for i = 1:size(CurvesByFrame , 1)
    
    if ~isempty(CurvesByFrame{i})
        for j = 1:size(CurvesByFrame{i},2)
            label = sprintf('%s%d',CurvesByFrame{i}{j}{5},CurvesByFrame{i}{j}{6});
            
            
            flag = 1;
            for k = 1:length(uniquewhiskers)
                if strcmp(uniquewhiskers{k},label)
                    flag = 0;
                end
            end
            
            if flag
                uniquewhiskers{end+1} = label;
            end
        end
    end
end


nwhiskers = size(uniquewhiskers,2);
Traces = cell(1, size(CurvesByFrame,1));
Labels = cell(1, size(CurvesByFrame,1));
Labelsfull = cell(1, size(CurvesByFrame,1));
Clusters = cell(1, size(CurvesByFrame,1));
% Extract traces and labels
for i = 1:size(CurvesByFrame, 1)
    if ~isempty(CurvesByFrame{i})
        Traces{i} = cell(1, nwhiskers);
        
        for j = 1:size(CurvesByFrame{i}, 2)
            
           if strcmp(CurvesByFrame{i}{j}{4},'track')
                label = sprintf('%s%d',CurvesByFrame{i}{j}{5},CurvesByFrame{i}{j}{6});
                tid = find(strcmp(uniquewhiskers, label));
                Traces{i}{tid}(end+1,1:2) = [CurvesByFrame{i}{j}{2}, CurvesByFrame{i}{j}{1}];
                
                Labels{i}(tid) = label(1);
                Clusters{i}(tid) = label(2);
                Labelsfull{i}{tid} = label;
            end
        end
        
    end
end



% Fit a quadratic funtion trough the traces
Tracesfit = cell(1, size(CurvesByFrame, 1));

for i = 1:size(Traces, 2)
    if ~isempty(Traces{i})
        for j = 1:size(Traces{i},2)
            t = Traces{i}{j};
            npts = size(t,1);
            rawax = 1:npts;
            fitax = linspace(1,npts,90);
            
            px = polyfit(rawax, t(:,1)', 2);
            py = polyfit(rawax, t(:,2)', 2);
            
            tfit(:,1) = polyval(px, fitax);
            tfit(:,2) = polyval(py, fitax);
            
            Tracesfit{i}{j} = tfit;
        end
        
    end
end

count = 0;

% Extract Tochdata
for i = 1:size(CurvesByFrame, 1)
    if ~isempty(CurvesByFrame{i})
       
        tick = 1;
        for j = 1:size(CurvesByFrame, 2)
            if strcmp(CurvesByFrame{i}{j}{4}, 'touch')
                Touch.label{i}{tick} = sprintf('%s%d',CurvesByFrame{i}{j}{5},CurvesByFrame{i}{j}{6});
                Touch.pt{i}(tick,:)= [CurvesByFrame{i}{j}{2}, CurvesByFrame{i}{j}{1}];
                tick = tick+1;
                count = count+1;
            end
        
        
        
        end
       
    end
end


disp(count)
Output.TracesSmall = Traces;
Output.Traces = Tracesfit;
Output.Labels.Side = Labels;
Output.Labels.Clusters = Clusters;
Output.Labels.Full = Labelsfull;
Output.Touch = Touch;

