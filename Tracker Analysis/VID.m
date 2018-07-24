printvid = 0;
printtrackernose = 1;
printsidediv = 0;
printrawtraces = 1;


rawcolor = [0 0 0];
nosecolor = [1 0 0];


if printvid
    outname = 'test';
    idx = find(outname == '_',1,'last');
    %outname = [outname(1:idx-1) '_colored'];
    vidout = VideoWriter(outname,'Motion JPEG AVI');
    open(vidout)
end

if printsidediv
    fn = @(a,b,x) a*x + b;
    xax = -500:500;
end




figure(1)
clf
colormap gray
for i = 1:Settings.Nframes
    Settings.Current_frame = i;
    
    
    
    f=  LoadFrame(Settings);
    imagesc(f)
    hold on
    
    if printtrackernose
        n = Tracker.Nose(i,:);
        a = Tracker.Headvec(i,:);
        scatter(n(:,2), n(:,1),'MarkerFaceColor',nosecolor,'MarkerEdgeColor',nosecolor)
        quiver(n(:,2), n(:,1), a(:,2)*20, a(:,1)*20,'color',nosecolor)
    end
    
    if printsidediv
        if i < size(Tracker.div,1)
            a = Tracker.div(i,:);
            l = fn(a(1),a(2),xax);
            plot(xax,l,'color','y','LineStyle','--')
        end
    end
    
    if printrawtraces
        if i < size(Tracker.Traces,2)
            t = Tracker.Traces{i};
            if ~isempty(t)
                for j = 1:size(t,2)
                    plot(t{j}(:,2), t{j}(:,1),'color',rawcolor)
                end
            end
        end
    end
    
    
    
    
    
    hold off
    drawnow
    
    if printvid
        fdata = getframe;
        writeVideo(vidout, fdata.cdata);
    end
    
end


if printvid
    close(vidout)
end


