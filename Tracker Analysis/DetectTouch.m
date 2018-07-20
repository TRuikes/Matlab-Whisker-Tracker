function Touch = DetectTouch(Traces, Objects)
%%
[opts(:,1), opts(:,2)] = find(Objects);
minrange = 10;
Touch = cell(1,size(Traces,2));



%{
% Method tracking whole trace
h = waitbar(0,'Detecting Touch');
for i = 1:size(Traces,2)
    touchpt = cell(1,size(Traces{i},2));
    for j = 1:size(Traces{i},2)
        t = Traces{i}{j};
        x = t';
        y = opts';
        d1 = y(1,:) - x(1,:)';
        d2 = y(2,:) - x(2,:)';
        d = sqrt( (d1.^2 + d2.^2));
        [a,~] = find(d <= minrange);
        touchpt{j} = unique(a);
    end
    Touch{i} = touchpt;
    waitbar(i/size(Traces,2))
end
close(h);
%}

% Method tracking only tip of trace
h = waitbar(0,'Detecting Touch (only tip');
for i = 1:size(Traces,2)

    touchpt = cell(1, size(Traces{i},2));
    
    for j = 1:size(Traces{i}, 2)
        t = Traces{i}{j};
      
        idx = size(t,1) - 5 : size(t,1);
        
        x = t(idx,:)';
        y = opts';
        d1 = y(1,:) - x(1,:)';
        d2 = y(2,:) - x(2,:)';
        d = sqrt( (d1.^2 + d2.^2));
        [a, ~] = find(d <= minrange);
        
        if ~isempty(a)
            touchpt{j} = size(t,1);
        end
    end
  
    Touch{i} = touchpt;
    waitbar(i/size(Traces,2))
    
end
close(h)
