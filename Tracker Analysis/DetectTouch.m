function Tracker = DetectTouch(Tracker)
%%
filterSettings;

fprintf(['ASSUMING: \n\t-no objects within gap, gap is determined by intensity' ...
    ' profile along y-axis at border of frame\n'])
fprintf('\t-Only touching within gap (touching above platform is neglected)\n')




Objects = Tracker.Objects;
Traces = Tracker.Traces_clean;
ncols = 5;
nframes = size(Traces,1);

y1 = sum(Objects(:,1:ncols),2);
y1 = y1./ncols;
y2 = sum(Objects(:,end-ncols+1:end),2);
y2 = y2./ncols;
y1(1:10) = 1;
y1(end-10:end) = 1;
y2(1:10) = 1;
y2(end-10:end) = 1;



idx = find(y1 < 0.5 |  y2 < 0.5);

opts = [];
[opts(:,1), opts(:,2) ] = find(Objects);
ymax = max(idx) + 5;
ymin = min(idx) - 5;
idxopts = find(opts(:,1) < ymax & opts(:,1) > ymin);
opts = opts(idxopts,:); %#ok<FNDSB>


Touch = cell(1,nframes);
h= waitbar(0,'detect touch');

%%
for i = 1:nframes
    looptouch = cell(1, size(Traces{i},2));
    
    for j = 1:size(Traces{i},2)
        t = Traces{i}{j};
        dist = [];
        dist(:,:,1) = opts(:,1) - t(:,1)';
        dist(:,:,2) = opts(:,2) - t(:,2)';
        dist = dist.^2;
        dist = sqrt( sum( dist,3));
        [~, tpt] = find(dist <= Settings.dist_object); %#ok<NODEF>
        looptouch{j} = unique(tpt);
        
    end
    
    Touch{i} = looptouch;

    waitbar( i/nframes);

end
close(h);

Tracker.Touch = Touch;
%%
%{
vidout = VideoWriter('ghostwhiskers','MPEG-4');
open(vidout);

figure(2)
clf
for i = 1:nframes
   
    if isempty(Traces{i})
        continue
    end
Settings.Current_frame = 1;


imshow(Objects)
hold on
scatter(opts(:,2), opts(:,1),'r','filled')

for j = 1:size(Traces{i},2)
    t = Traces{i}{j};
    plot(Traces{i}{j}(:,2), Traces{i}{j}(:,1),'b')
    
    if ~isempty(Touch{i}{j})
        idx = Touch{i}{j};
        pts = t(idx,:);
        scatter(pts(:,2) , pts(:,1), 'g','filled')
    end
        
end
hold off
drawnow
pause(0.05)

frame = getframe;
writeVideo(vidout, frame);
end
close(vidout)
%}
