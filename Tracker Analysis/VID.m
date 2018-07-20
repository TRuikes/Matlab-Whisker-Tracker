

vidout = VideoWriter(fullfile(Settings.PathName,[Settings.FileName(1:end-4) '_colors' ]),'Motion JPEG AVI');
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
        
        s = Tracker.Side{i}(j);
        n = Tracker.Clusters{i}(j);
        l = sprintf('%s%d',s,n);
        
        id = find(strcmp(General.tracker_labels,l));
        
        plot(t(:,2), t(:,1), 'color', cc(id,:),'LineWidth',1)
    end
    
    hold off
    
    fdata = getframe;
    writeVideo(vidout, fdata.cdata);
    
end


close(vidout)


