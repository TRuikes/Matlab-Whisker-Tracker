%%
close all

% figure 1 - unclustered tracker angles
x1 = find(General.keep,1,'first');
x2 = find(General.keep,1,'last');


hmargin = 0.1;
vmargin = 0.01;
subwidth = 0.25;
subheigth = 0.25;
vspace = 0.05;
hspace = 0.05;

% subplot A - raw angles
ax1 = axes('Units',  'normalized','Position',[hmargin 1-(vmargin+subheigth+vspace) subwidth subheigth],...
    'Xlim',[x1 x2],'Ylim',[-180 180],...
    'YTick',[-180 -90 0 90 180],'XTick',[x1 x2]);
ax2 = axes('Units', 'normalized', 'Position',[hmargin+(subwidth+hspace) 1-(vmargin+subheigth+vspace) subwidth subheigth]);
ax3 = axes('Units', 'normalized', 'Position',[hmargin+2*(subwidth+hspace) 1-(vmargin+subheigth+vspace) subwidth subheigth]);
ax4 = axes('Units',  'normalized','Position',[hmargin 1-vmargin-(2*(subheigth+vspace)) subwidth subheigth]);
ax5 = axes('Units', 'normalized', 'Position',[hmargin+(subwidth+hspace) 1-vmargin-(2*(subheigth+vspace)) subwidth subheigth]);
ax6 = axes('Units', 'normalized', 'Position',[hmargin+2*(subwidth+hspace) 1-vmargin-(2*(subheigth+vspace)) subwidth subheigth]);
ax7 = axes('Units',  'normalized','Position',[hmargin 1-vmargin-(3*(subheigth+vspace)) subwidth subheigth]);
ax8 = axes('Units', 'normalized', 'Position',[hmargin+(subwidth+hspace) 1-vmargin-(3*(subheigth+vspace)) subwidth subheigth]);
ax9 = axes('Units', 'normalized', 'Position',[hmargin+2*(subwidth+hspace) 1-vmargin-(3*(subheigth+vspace)) subwidth subheigth]);

% extract data
plotdata = [];
for i = 1:length(General.keep)
    if General.keep(i)
        loopdata = [i*ones(1,size(Tracker.Angles{i},2))' ,Tracker.Angles{i}'];
        plotdata(end+1:end+size(loopdata,1),:) = loopdata;
    end
end

scatter(ax1, plotdata(:,1), plotdata(:,2), 3,'k','filled')
xlim(ax1,[x1 x2])
ylim(ax1,[-180 180])
ax1.XTick = [x1 x2];
ax1.YTick = [-180 -90 0 90 180];
hold(ax1, 'on')
line(ax1,[x1 x2],[0 0],'color','k')




% suplot B - clustered angles

cc = jet( size(General.tracker_labels,2));
hold(ax2,'on')
for i = 1:size(General.tracker_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = str2double(General.tracker_labels{i}(2));
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Tracker.Side{j} == s & Tracker.Clusters{j} == c);
            loopdata = [j*ones(1,length(idx))', Tracker.Angles{j}(idx)'];
            plotdata(end+1:end+size(loopdata,1),:) = loopdata;
        end
    end
    scatter(ax2, plotdata(:,1), plotdata(:,2), 3, ...
        'MarkerFaceColor',cc(i,:), 'MarkerEdgeColor',cc(i,:))
    
end
xlim(ax2,[x1 x2])
ylim(ax2,[-180 180])
ax2.XTick = [x1 x2];
ax2.YTick = [-180 -90 0 90 180];
line(ax2,[x1 x2],[0 0],'color','k')

% subplot C - mean cluster angles and manual data
x1 = find( General.manual_keep == 1,1,'first');
x2 = find( General.manual_keep == 1,1,'last');




hold(ax3, 'on')
for i = 1:size(General.tracker_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = str2double(General.tracker_labels{i}(2));
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Tracker.Side{j} == s & Tracker.Clusters{j} == c);
            plotdata(j,i) = mean(Tracker.Angles{j}(idx));
        end
    end
    plotdata(:,i) = medfilt1(plotdata(:,i), 5);
    plot(ax3, x1:x2,plotdata(x1:x2,i),'color',cc(i,:),'LineWidth',1.5)
    
end

for i = 1:size(General.manual_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = General.tracker_labels{i}(2);
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Manual.Side{j} == s & Manual.Clusters{j} == c);
            if ~isempty(idx)
                plotdata(j,i) = Manual.Angles{j}(idx);
            else
                plotdata(j,i) = NaN;
            end
        end
    end
    
    %plotdata(:,i) = medfilt1(plotdata(:,i), 5);
    plot(ax3, x1:x2, plotdata(x1:x2,i),'r')
end


xlim(ax3,[x1 x2])
ylim(ax3,[-180 180])
ax3.XTick = [x1 x2];
ax3.YTick = [-180 -90 0 90 180];
line(ax3,[x1 x2],[0 0],'color','k')

%%
% Curvature D


% extract data
plotdata = [];
for i = 1:length(General.keep)
    if General.keep(i)
        idx = find(Tracker.Side{i} == 'R');
        loopdata = [i*ones(1,size(Tracker.Curvature.theta{i}(idx),2))' ,Tracker.Curvature.theta{i}(idx)'];
        plotdata(end+1:end+size(loopdata,1),:) = loopdata;
        
        
        idx = find(Tracker.Side{i} == 'L');
        loopdata = [i*ones(1,size(Tracker.Curvature.theta{i}(idx),2))' ,-Tracker.Curvature.theta{i}(idx)'];
        plotdata(end+1:end+size(loopdata,1),:) = loopdata;
    end
end


scatter(ax4, plotdata(:,1), plotdata(:,2), 3,'k','filled')
ylim(ax4,[-20, 20])

x1 = find(General.keep,1,'first');
x2 = find(General.keep,1,'last');
xlim(ax4, [x1 x2])

hold(ax1, 'on')
line(ax1,[x1 x2],[0 0],'color','k')



% suplot E - clustered angles


cc = jet( size(General.tracker_labels,2));
hold(ax5,'on')
for i = 1:size(General.tracker_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = str2double(General.tracker_labels{i}(2));
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Tracker.Side{j} == s & Tracker.Clusters{j} == c);
            loopdata = [j*ones(1,length(idx))', Tracker.Curvature.theta{j}(idx)'];
            if s == 'L'
                loopdata(:,2) = -loopdata(:,2);
            end
            plotdata(end+1:end+size(loopdata,1),:) = loopdata;
        end
    end
    scatter(ax5, plotdata(:,1), plotdata(:,2), 5, ...
        'MarkerFaceColor',cc(i,:), 'MarkerEdgeColor',cc(i,:))
    
end
xlim(ax5,[x1 x2])
ax5.XTick = [x1 x2];
ylim(ax5,[-20, 20])

line(ax5,[x1 x2],[0 0],'color','k')




% subplot F - mean cluster angles and manual data
x1 = find( General.manual_keep == 1,1,'first');
x2 = find( General.manual_keep == 1,1,'last');



hold(ax6, 'on')
for i = 1:size(General.tracker_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = str2double(General.tracker_labels{i}(2));
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Tracker.Side{j} == s & Tracker.Clusters{j} == c);
            if s == 'L'
                a = -1;
            else
                a = 1;
            end
            plotdata(j,i) = a*mean(Tracker.Curvature.theta{j}(idx));
        end
    end
   plotdata(:,i) = medfilt1(plotdata(:,i), 5);
   plot(ax6, x1:x2,plotdata(x1:x2,i),'color',cc(i,:),'LineWidth',1.5)
    
end


for i = 1:size(General.manual_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = General.tracker_labels{i}(2);
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Manual.Side{j} == s & Manual.Clusters{j} == c);
            if ~isempty(idx)
                if s == 'L'
                    a = -1;
                else
                    a = 1;
                end
                plotdata(j,i) = a *Manual.Curvature.theta{j}(idx);
            else
                plotdata(j,i) = NaN;
            end
        end
    end
    
    %plotdata(:,i) = medfilt1(plotdata(:,i), 5);
    plot(ax6, x1:x2, plotdata(x1:x2,i),'r')
end


xlim(ax6,[x1 x2])
%ylim(ax6,[-20 20])

ax6.XTick = [x1 x2];
ax6.YTick = [-180 -90 0 90 180];
line(ax6,[x1 x2],[0 0],'color','k')





%%
x1 = find(General.keep,1,'first');
x2 = find(General.keep,1,'last');
plotdata = [];
for i = x1:x2
  
    if ~isempty(Tracker.Touch{i})
        for j = 1:size(Tracker.Touch{i},2)
            if ~isempty(Tracker.Touch{i}{j})
            
                 plotdata(end+1,:) = [i,j];
                
            end
    
        end
    end
end
scatter(ax7, plotdata(:,1), plotdata(:,2),5 , 'k','filled')
xlim(ax7,[x1 x2])
ylim(ax7, [0 25])


% clustered data

hold(ax8,'on')
for i = 1:size(General.tracker_labels,2)
    
    s = General.tracker_labels{i}(1);
    c = str2double(General.tracker_labels{i}(2));
    
    plotdata = [];
    for j = 1:length(General.keep)
        if General.keep(j)
            idx = find( Tracker.Side{j} == s & Tracker.Clusters{j} == c);
            
            if ~isempty(Tracker.Touch{j}) && ~isempty(idx)
                
                for k = 1:length(idx)
                    if ~isempty(Tracker.Touch{j}{idx(k)})
                        plotdata(end+1,:) = [j,idx(k)];
                    end
                end
            end
            
        end
    end
    scatter(ax8, plotdata(:,1), plotdata(:,2), 5, ...
        'MarkerFaceColor',cc(i,:), 'MarkerEdgeColor',cc(i,:))
    
end
xlim(ax8,[x1 x2])
ax8.XTick = [x1 x2];
ylim(ax8,[0 25])



%%


f2 = figure('Units','pixels','Position',[100 100 1100 900]);


hmargin = 0.1;
vmargin = 0.01;
subwidth = 0.25;
subheigth = 0.25;
vspace = 0.05;
hspace = 0.05;

% subplot A - raw angles
ax1 = axes('Units',  'normalized','Position',[hmargin 1-(vmargin+subheigth+vspace) subwidth subheigth],...
    'Xlim',[x1 x2],'Ylim',[-180 180],...
    'YTick',[-180 -90 0 90 180],'XTick',[x1 x2]);
ax2 = axes('Units', 'normalized', 'Position',[hmargin+(subwidth+hspace) 1-(vmargin+subheigth+vspace) subwidth subheigth]);
ax3 = axes('Units', 'normalized', 'Position',[hmargin+2*(subwidth+hspace) 1-(vmargin+subheigth+vspace) subwidth subheigth]);
ax4 = axes('Units', 'normalized', 'Position',[hmargin 1-vmargin-(2*(subheigth+vspace)) subwidth subheigth]);
ax5 = axes('Units', 'normalized', 'Position',[hmargin+(subwidth+hspace) 1-vmargin-(2*(subheigth+vspace)) subwidth subheigth]);
ax6 = axes('Units', 'normalized', 'Position',[hmargin+2*(subwidth+hspace) 1-vmargin-(2*(subheigth+vspace)) subwidth subheigth]);
ax7 = axes('Units', 'normalized', 'Position',[hmargin 1-vmargin-(3*(subheigth+vspace)) subwidth subheigth]);
ax8 = axes('Units', 'normalized', 'Position',[hmargin+(subwidth+hspace) 1-vmargin-(3*(subheigth+vspace)) subwidth subheigth]);
ax9 = axes('Units', 'normalized', 'Position',[hmargin+2*(subwidth+hspace) 1-vmargin-(3*(subheigth+vspace)) subwidth subheigth]);


%%
x1 = find(General.keep,1,'first');
x2 = find(General.keep,1,'last');


plotdata1 = [];
plotdata2 = [];
plotdata3 = [];
for i = x1:x2
    if ~isempty(Tracker.Traces{i})
        for j = 1:size(Tracker.Traces{i},2)
            pt = Tracker.Traces{i}{j}(end,:);
            plotdata1(end+1,:) = [i, pt(1)];
            plotdata2(end+1,:) = [i, pt(2)];
            
            if Tracker.Side{i}(j) == 'L'
                a = -1;
            else
                a = 1;
            end
            plotdata3(end+1,:) = [i, a*size(Tracker.Traces{i}{j},1)];
                
            
        end
    end
end

scatter(ax1, plotdata1(:,1), plotdata1(:,2), 5 , 'k', 'filled')
scatter(ax4, plotdata2(:,1), plotdata2(:,2), 5, 'k', 'filled')
scatter(ax7, plotdata3(:,1), plotdata3(:,2), 5, 'k', 'filled')


xlim(ax1, [x1,x2])
xlim(ax4, [x1,x2])









































