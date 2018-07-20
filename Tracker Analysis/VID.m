outname = Settings.vidout_name;
idx = find(outname == '_',1,'last');
outname = [outname(1:idx-1) '_colored'];

vidout = VideoWriter(outname,'Motion JPEG AVI');
open(vidout)


x1_tracker = find(General.keep, 1, 'first');
x2_tracker = find(General.keep, 1, 'last');


figure(1)
clf
colormap gray
for i = x1_tracker:x2_tracker
    Settings.Current_frame = i;
    f=  LoadFrame(Settings);
    imagesc(f)
    hold on
    
    
    for j = 1:size(Tracker.Traces{i},2)
         t = Tracker.Traces{i}{j};
        if isempty(Tracker.Clusters{i})
            plot(t(:,2), t(:,1), 'color' , 'k', 'LineWidth',1)
            continue
        end
        
        
       
        
        s = Tracker.Side{i}(j);
        n = Tracker.Clusters{i}(j);
        l = sprintf('%s%d',s,n);
        
        id = find(strcmp(General.tracker_labels,l));
        
        if ~isempty(id)
            plot(t(:,2), t(:,1), 'color', cc(id,:),'LineWidth',1)
        else
            plot(t(:,2), t(:,1),'color','k','LineWidth',1)
        end
    end
    
    hold off
    
    fdata = getframe;
    writeVideo(vidout, fdata.cdata);
    
end


close(vidout)


