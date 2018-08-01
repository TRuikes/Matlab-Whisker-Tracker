function colors = makeColor()
%%
warning('off')
% Color pallet for visual output
cc = cbrewer('div','RdYlGn',12);
colors.tracker_light = cc(10,:);
colors.tracker_dark = cc(12,:);
colors.tracker_touch = cc(10,:);
colors.tracker_touch_style = 'o';

colors.manual_light = cc(4,:);
colors.manual_dark = cc(2,:);
colors.manual_touch = cc(4,:);
colors.manual_touch_style = 'x';


cc =cbrewer('seq','YlOrRd',8);

colors.raw = cc(7,:);
warning('on')




