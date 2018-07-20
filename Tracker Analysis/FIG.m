close all
clc

addpath(genpath(pwd))
x1_tracker = find(General.keep, 1, 'first');
x2_tracker = find(General.keep, 1, 'last');

x1_manual = find( General.manual_keep == 1,1,'first');
x2_manual = find( General.manual_keep == 1,1,'last');

warning('off')
cmap1 = cbrewer('div','RdYlBu',11);
cmap2 = cbrewer('div','RdYlGn',11);
cmap3 = cbrewer('div','PiYG',11);
cmap4 = cbrewer('div','BrBG',11);
cmap5 = cbrewer('seq','YlOrBr',11);

hx = size(Tracker.Objects,1);
hy = size(Tracker.Objects,2);

% Generate colormap
if length(General.tracker_labels) == 6
    cc(1,:) = cmap1(2,:);
    cc(2,:) = cmap1(10,:);
    cc(3,:) = cmap2(10,:);
    cc(4,:) = cmap3(2,:);
    cc(5,:) = cmap5(7,:);
    cc(6,:) = cmap4(2,:);
    
else
    keyboard
end
%
% Setup figure
f1 = figure('Units','pixels','Position',[100 100 1400 900]);

ny = 3;
nx = 4;

margy = 0.05;
margx = 0.05;

spacey = 0.05;
spacex = 0.05;

widthx = (1-2*margx-(nx-1)*spacex)/nx;
heighty = (1-2*margy-(ny-1)*spacey)/ny;


xtick = 1;
ytick = 1;
for i = 1:ny*nx
    
    xpos = margx + (xtick-1)*(widthx+spacex);
    ypos = 1-margy-heighty -(ytick-1)*(heighty+spacey);
    
    ax{i} = axes('Units','normalized','Position',[xpos, ypos, widthx, heighty]);
    
    xtick = xtick+1;
    
    if xtick > nx
        xtick = 1;
        ytick = ytick+1;
    end
    
    hold(ax{i},'on')
    xlim(ax{i},[x1_tracker x2_tracker])
    
    
end


% Generate rawdata plots
rectangle(ax{1},'Position',[x1_manual -1000 x2_manual-x1_manual 2000],'FaceColor',[0 0 0 0.03])
rectangle(ax{5},'Position',[x1_manual -1000 x2_manual-x1_manual 2000],'FaceColor',[0 0 0 0.03])
rectangle(ax{9},'Position',[x1_manual -1000 x2_manual-x1_manual 2000],'FaceColor',[0 0 0 0.03])
rectangle(ax{3},'Position',[x1_manual -1000 x2_manual-x1_manual 2000],'FaceColor',[0 0 0 0.03])
rectangle(ax{7},'Position',[x1_manual -1000 x2_manual-x1_manual 2000],'FaceColor',[0 0 0 0.03])
for i = 1:size(General.tracker_labels,2)
    side = General.tracker_labels{i}(1);
    lnr = str2double(General.tracker_labels{i}(2));
    
    if side == 'L'
        a = -1;
    elseif side == 'R'
        a = 1;
    end
    
    plotdata_x = [];
    plotdata_y = [];
    plotdata_theta_base = [];
    plotdata_theta_tip = [];
    plotdata_length = [];
    
    for j = x1_tracker:x2_tracker
        
        if isempty(Tracker.Clusters{j})
            continue
        end
        idx = find( Tracker.Side{j} == side & Tracker.Clusters{j} == lnr );
        
        for k = 1:length(idx)
            plotdata_x(end+1,:) =[j Tracker.Traces{j}{idx(k)}(end,1)];
            plotdata_y(end+1,:) =[j Tracker.Traces{j}{idx(k)}(end,2)];
            plotdata_theta_base(end+1,:) = [j Tracker.Angles{j}(idx(k))];
            plotdata_length(end+1,:) = [j a*size(Tracker.Traces{j}{idx(k)},1)];
            plotdata_theta_tip(end+1,:) = [j a*Tracker.Curvature.theta{j}(idx(k))];
            
        end
    end
    
    scatter(ax{1}, plotdata_x(:,1), plotdata_x(:,2),'SizeData',5,...
        'MarkerFaceColor',cc(i,:),'MarkerEdgeColor',cc(i,:));
    scatter(ax{5}, plotdata_y(:,1), plotdata_y(:,2),'SizeData',5,...
        'MarkerFaceColor',cc(i,:),'MarkerEdgecolor',cc(i,:));
    scatter(ax{9}, plotdata_theta_base(:,1), plotdata_theta_base(:,2), 'SizeData',5,...
        'MarkerFaceColor',cc(i,:),'MarkerEdgeColor',cc(i,:));
    
    scatter(ax{3}, plotdata_length(:,1), plotdata_length(:,2), 'SizeData',5,...
        'MarkerFaceColor',cc(i,:),'MarkerEdgeColor',cc(i,:));
    scatter(ax{7}, plotdata_theta_tip(:,1), plotdata_theta_tip(:,2), 'SizeData',5,...
        'MarkerFaceColor',cc(i,:),'MarkerEdgeColor',cc(i,:));
    
    
    
end

ylim(ax{1},[0 hx])
ylim(ax{5},[0 hy])
ylim(ax{9},[-180 180])
ylim(ax{3},[-60 60])
ylim(ax{7},[-50 50])



%% Generate filtered data plot

filter_size = 1;



plotdata_x = [];
plotdata_y = [];
plotdata_theta_base = [];
plotdata_theta_tip = [];
plotdata_length = [];

xlim(ax{2},[x1_manual x2_manual])
xlim(ax{4},[x1_manual x2_manual])
xlim(ax{8},[x1_manual x2_manual])
xlim(ax{6},[x1_manual x2_manual])
xlim(ax{10},[x1_manual x2_manual])

% manual data
for i = 1:size(General.manual_labels,2)
    side = General.manual_labels{i}(1);
    lnr = General.manual_labels{i}(2);
    
    if side == 'L'
        a = -1;
    elseif side == 'R'
        a = 1;
    end
    
    
    plotdata_x(1:numel(x1_manual:x2_manual)) = NaN;
        plotdata_y(1:numel(x1_manual:x2_manual)) = NaN;
        plotdata_theta_base(1:numel(x1_manual:x2_manual)) = NaN;

    
    for j = x1_manual:x2_manual   

            idx = find( Manual.Side{j} == side & Manual.Clusters{j} == lnr);            
            plotdata_x(j+1-x1_manual) = Manual.Traces{j}{idx}(end,1);
            plotdata_y(j+1-x1_manual) = Manual.Traces{j}{idx}(end,2);
            plotdata_theta_base(j+1-x1_manual) = Manual.Angles{j}(idx);
            plotdata_theta_tip(j+1-x1_manual) = a*Manual.Curvature.theta{j}(idx);
            plotdata_length(j+1-x1_manual) = a*size(Manual.Traces{j}{idx},1);

            


    end
    plotdata_x = medfilt1(plotdata_x,filter_size);
      plotdata_y = medfilt1(plotdata_y,filter_size);
      plotdata_theta_base = medfilt1(plotdata_theta_base, filter_size);
      plotdata_theta_tip = medfilt1(plotdata_theta_tip, filter_size);
      plotdata_length = medfilt1(plotdata_length, filter_size);
      

     plot(ax{2},x1_manual:x2_manual,plotdata_x,'color','k','LineWidth',1)
     plot(ax{6},x1_manual:x2_manual,plotdata_y,'color','k','LineWidth',1)
     plot(ax{10},x1_manual:x2_manual,plotdata_theta_base,'color','k','LineWidth',1)  
     plot(ax{4},x1_manual:x2_manual,plotdata_theta_tip,'color','k','LineWidth',1)
 %    plot(ax{8},x1_manual:x2_manual,plotdata_length,'color','k','LineWidth',1)



         


end




plotdata_x = [];
plotdata_y = [];
plotdata_theta_base = [];
plotdata_theta_tip = [];
plotdata_length = [];


% tracker data
for i = 1:size(General.tracker_labels,2)
    side = General.tracker_labels{i}(1);
    lnr = str2double(General.tracker_labels{i}(2));
    
    if side == 'L'
        a = -1;
    elseif side == 'R'
        a = 1;
    end
    
    plotdata_x(1:numel(x1_manual:x2_manual)) = NaN;
    plotdata_y(1:numel(x1_manual:x2_manual)) = NaN;
    plotdata_theta_base(1:numel(x1_manual:x2_manual)) = NaN;
    plotdata_theta_tip(1:numel(x1_manual:x2_manual)) = NaN;
    plotdata_length(1:numel(x1_manual:x2_manual)) = NaN;
    
    
    for j = x1_manual:x2_manual
        
        if isempty(Tracker.Clusters{j})
            continue
        end
        idx = find( Tracker.Side{j} == side & Tracker.Clusters{j} == lnr );
        
        loopdata_x = [];
        loopdata_y = [];
        loopdata_theta_base = [];
        loopdata_theta_tip = [];
        loopdata_length = [];
        
        for k = 1:length(idx)
            loopdata_x(end+1) = Tracker.Traces{j}{idx(k)}(end,1);
            loopdata_y(end+1) = Tracker.Traces{j}{idx(k)}(end,2);
            loopdata_theta_base(end+1) = Tracker.Angles{j}(idx(k));
            loopdata_theta_tip(end+1) = a*size(Tracker.Traces{j}{idx(k)},1);
            loopdata_length(end+1) = a*Tracker.Curvature.theta{j}(idx(k));
        end
        
        plotdata_x(j-x1_manual+1) = mean(loopdata_x);
        plotdata_y(j-x1_manual+1) = mean(loopdata_y);
        plotdata_theta_base(j-x1_manual+1) = mean(loopdata_theta_base);
        plotdata_theta_tip(j-x1_manual+1) = mean(loopdata_theta_tip);
        plotdata_length(j-x1_manual+1) = mean(loopdata_length);
        
    end
    
    plotdata_x = medfilt1(plotdata_x, filter_size);
    plotdata_y = medfilt1(plotdata_y, filter_size);
    plotdata_theta_base = medfilt1(plotdata_theta_base, filter_size);
    plotdata_theta_tip = medfilt1(plotdata_theta_tip, filter_size);
    plotdata_length = medfilt1(plotdata_length, filter_size);
    
    
    plot(ax{2},x1_manual:x2_manual,plotdata_x,'color',cc(i,:),'LineWidth',2)
    plot(ax{6},x1_manual:x2_manual,plotdata_y,'color',cc(i,:))
    plot(ax{10},x1_manual:x2_manual,plotdata_theta_base,'color',cc(i,:))
    plot(ax{4},x1_manual:x2_manual,plotdata_theta_tip,'color',cc(i,:))
    plot(ax{8},x1_manual:x2_manual,plotdata_length,'color',cc(i,:))
    
    
    
    
end


























