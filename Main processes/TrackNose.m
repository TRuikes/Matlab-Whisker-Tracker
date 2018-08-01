function Output = TrackNose(Settings,Output)
%% Track direction
% - Find base of silhouette in each frame
% - Use derivative of position of base to deterine base movement
% - Find average movement vector, its largest component marks moving
%   direction
%
% Track Nose
% - If enough previous nose were tracked, define ROI
% - Find as point furthest away from base
%
% Track Angle
% - Define circle around Nose
% - Find intersection of circle with Nose
% - Find normal to vector inbetween intersections
%
%
%
% Adds the fields 'Direction, Nose, AngleVector' to output, describing
% movement direction, noseposition per frame and headangle per frame.
%% Diretion Tracking

%%
% Setup parameters
h = waitbar(0,'Tracking nose');
video = Settings.Video;
nframes = Settings.Nframes;


stepsize = Settings.nose_interval;
Base = [];

tick = 1;
% Loop with interval over all frames
for framenr = 1:stepsize:nframes
    
    
    
    % Load and process frames
    Settings.Current_frame = framenr;
    frame = LoadFrame(Settings);    
    frame(frame > Settings.Silhouettethreshold) = 0;
    frame(find(frame)) = 1;
    frame(find(Output.Objects)) = 0;   
    frame_x = sum(frame,1);
    frame_y = sum(frame,2);
    
    
    
    % Find base if possible
    if numel(find(frame)) > 1000
        Base(tick,2) = (find(frame_x>0.2*max(frame_x),1,'first')+...
            find(frame_x>0.2*max(frame_x),1,'last'))/2;
        Base(tick,1) = (find(frame_y>0.2*max(frame_y),1,'first')+...
            find(frame_y>0.2*max(frame_y),1,'last'))/2;
    else
        Base(tick,1:2) = [NaN NaN];
    end
    tick=tick+1;
end
b1 = Base
% Get derivative of base position
movement = diff(Base,1);
delta = sum(movement,1,'omitnan');

% Find major axis of movement
if abs(delta(1)) > abs(delta(2))
    Directionaxis = 'X';
elseif abs(delta(2)) > abs(delta(1))
    Directionaxis = 'Y';
end
Directionaxis = 'Y';

% Find direction of movement along major axis
switch(Directionaxis)
    case 'X'
        if delta(2) > 0
            Direction = 'Right';
        elseif delta(2) < 0
            Direction = 'Left';
        end
    case 'Y'
        if delta(1) >= 0
            Direction = 'Down';
        elseif delta(1) < 0
            Direction = 'Up';
        end
end

% Store output
Output.Direction = Direction;


%% Track Nose


% Select a method, 'automated' or 'manual' (manual has not been updated)
Settings.TRnosemode = 'Automated';
switch(Settings.TRnosemode)
    case 'Automated'
        %% Automated nose tracking
        
        % Setup parameters
        interval = 10; % tracking interval
        ntotrack = round(nframes/interval); % total nr of frames
        tick = 0;
        ntracked = 0;
        
        
        % Loop over all frames at interval
        for framenr = 1:interval:nframes
            
            waitbar(framenr/nframes,h)
            % Load and process frames
            Settings.Current_frame = framenr;
            frame = LoadFrame(Settings);
           
            frame = ~imbinarize(frame,Settings.Silhouettethreshold);
            frame(find(frame)) = 1; %#ok<*FNDSB>
            frame(find(Output.Objects)) = 0;
         
          
            % Filter mouse based on area size
            stats = regionprops(frame,'Area');
            NR = 0;
            for i = 1:size(stats,1)
                if stats(i).Area > 2000
                    NR = NR + 1;
                end
            end
            
            if NR > 0
                frame = bwareafilt(frame,NR,'largest');
                f3 = frame;
                frame_x = sum(frame,1);
                frame_y = sum(frame,2);
            else
                Nose(framenr,1:2) = [NaN NaN];
                
                if framenr > 1+interval && any(isnan(Nose(framenr-interval,:)))
                    Nose(framenr-interval:framenr,:) = NaN;
                end
                continue
            end
            
            
            % Find nose if possible
            if NR > 0
                % Find base
                Base(framenr,2) = (find(frame_x>0.2*max(frame_x),1,'first')+...
                    find(frame_x>0.2*max(frame_x),1,'last'))/2;
                Base(framenr,1) = (find(frame_y>0.2*max(frame_y),1,'first')+...
                    find(frame_y>0.2*max(frame_y),1,'last'))/2;
                
                % Create ROI based on previous points
                if ntracked > 3
                    PTS = [];
                    PTS(1:3,1:2) = Nose(framenr-interval*3:interval:...
                        framenr-interval,1:2);
                    
                    if ~any(any(isnan(PTS)))
                        dP = diff(PTS,1);
                        dV = diff(dP,1);
                        V = dP(2,1:2) + dV;
                        P = round(PTS(3,1:2) + V);
                        
                        dark = zeros(size(frame));
                        psize = 60;
                        X1 = P(1)-psize; if X1<1; X1=1;end
                        X2 = P(1)+psize; if X2>size(frame,1);X2=size(frame,1);end
                        Y1 = P(2)-psize; if Y1<1; Y1=1;end
                        Y2 = P(2)+psize; if Y2>size(frame,2);Y2=size(frame,2);end
                        dark(X1:X2,Y1:Y2) = 1;
                    end
                    % Extract ROI
                    frame = dark.*frame;
                else
                    dark = ones(size(frame));
                    switch(Direction)
                        case 'Up'
                            dark(round(Base(framenr,1)) :size(frame,1),:) = 0;
                        case 'Down'
                            
                            dark(1:round(Base(framenr,1)),:) = 0;
                        case 'Left'
                            dark(:,round(Base(framenr,2)):size(frame,2)) = 0;
                        case 'Right'
                            dark(:,1:round(Base(framenr,2))) = 0;
                    end
                    frame = dark.*frame;
                end
                
                % If mouse is present
                if numel(find(frame > 0)) < 1000
                    Nose(framenr,1:2) = [NaN NaN];
                    if framenr > 1+interval && any(isnan(Nose(framenr-interval,:)))
                        Nose(framenr-interval:framenr,:) = NaN;
                    end
                    
                    ntracked = 0;
                    continue
                end
                
                % Find nose as lowest pont;
                switch(Direction)
                    case 'Up'
                        Noselow(framenr,1) = find(frame_y> ...
                            0.05*max(frame_y),1,'first');
                        Noselow(framenr,2) = mean(...
                            find(frame(Noselow(framenr,1)+5,:)));
                    case 'Down'
                        Noselow(framenr,1) = find(frame_y> ...
                            0.05*max(frame_y),1,'last');
                        Noselow(framenr,2) = mean(...
                            find(frame(Noselow(framenr,1)-5,:)));
                    case 'Left'
                        Noselow(framenr,2) = find(frame_x> ...
                            0.05*max(frame_x),1,'first');
                        Noselow(framenr,1) = mean(...
                            find(frame(:,Noselow(framenr,2)+5)));
                    case 'Right'
                        Noselow(framenr,2) = find(frame_x> ...
                            0.05*max(frame_x),1,'last');
                        Noselow(framenr,2) = mean(...
                            find(frame(:,Noselow(framenr,2)-5)));
                end
                
                
                % Get edge of nose
                frame = edge(frame);%edge(framefull);
                dist = [];
                PTS = [];
                [PTS(:,1),PTS(:,2)] = find(frame);
                for k = 1:size(PTS,1)
                    dist(k) = sqrt(sum( (PTS(k,:)-Base(framenr,:)).^2));
                end
                
                id = find(dist == max(dist),1,'first');
                NoseFar(framenr,:) = PTS(id,:);
                if ntracked < 4
                    Nose(framenr,1:2) = Noselow(framenr,1:2);
                else
                    Nose(framenr,1:2) = NoseFar(framenr,1:2);
                    
                end
                ntracked = ntracked+1;
                % Find Angle
                Cx = []; Cy = []; IDX = []; C =[];
                PTS = []; Vp = [];
                
                % Make circle round the nose
                theta = 1:1:360;
                Cx = [round(Nose(framenr,2) + 40*sind(theta))];
                Cx = [Cx, Cx+1];
                Cy = [round(Nose(framenr,1) + 40*cosd(theta))];
                Cy = [Cy, Cy+1];
                IDX = find(Cx>1 & Cx<size(frame,2) & Cy >1 & Cy <size(frame,1));
                C = sub2ind(size(frame),Cy(IDX),Cx(IDX));
                
                
                
                % Find points on edge
                PTS(:,1) = find(frame(C));
                [PTS(1:length(PTS),2),PTS(1:length(PTS),1)] = ind2sub(size(frame),C(PTS));
                
                for id = 1:size(PTS,1)
                    dist = [];
                    if isnan(PTS(id,1))
                        continue
                    end
                    for i = 1:size(PTS,1)
                        if id == i || isnan(PTS(i,1))
                            continue
                        end
                        dist(i) = finddist(PTS(id,:)',PTS(i,:));
                        if dist(i) < 25
                            PTS(i,:) = [NaN,NaN];
                        end
                        
                    end
                end
                IDX = find( ~isnan(PTS(:,1)));
                PTS = PTS(IDX,:);
                
                
                
                % Determine vector between points
                if ~isempty(PTS) && size(PTS,1) == 2
                    PTS = PTS(1:2,:); % Lazy
                    Vp = PTS(2,:) - PTS(1,:);
                    
                    % Headangle described as vector, normal to Vp
                    AngleVector(framenr,1:2) = [-Vp(1),Vp(2)];
                    
                    % Normalise
                    AngleVector(framenr,1:2) = AngleVector(framenr,1:2)...
                        ./sqrt(sum(AngleVector(framenr,1:2).^2));
                    
                    
                    % Determine if facing right direction (towards tail)
                    switch(Direction)
                        case 'Up'
                            if AngleVector(framenr,1) < 0
                                AngleVector(framenr,:) = -AngleVector(framenr,:);
                            end
                        case 'Down'
                            if AngleVector(framenr,1) > 0
                                AngleVector(framenr,:) = -AngleVector(framenr,:);
                            end
                        case 'Left'
                            if AngleVector(framenr,2) > 0
                                AngleVector(framenr,:) = -AngleVector(framenr,:);
                            end
                        case 'Right'
                            if AngleVector(framenr,2) < 0
                                AngleVector(framenr,:) = -AngleVector(framenr,:);
                            end
                    end
                    
                    
                else
                    AngleVector(framenr,1:2) = [NaN NaN];
                end
                
            else
                Base(framenr,1:2) = [NaN NaN];
                Nose(framenr,1:2) = [NaN NaN]; %#ok<*AGROW>
                ntracked = 0;
            end
            %{
            tick = tick+1;
            if rem(tick,round(ntotrack/20)) == 0
                disp([num2str((round(tick/295*100,0))) '%'])
                
            end
            %}
            %{
            % Show live output
            figure(1)
            clf
            imshow(frame)
            hold on
            scatter(Nose(framenr,2),Nose(framenr,1),'r','filled')
            if exist('P','var')
            scatter(P(2),P(1),'b','filled')
            end
            quiver(Nose(framenr,2),Nose(framenr,1),10*AngleVector(framenr,2),...
                AngleVector(framenr,1)*10,'r')
            drawnow
            %}
            %}
            
           
        end
        close(h)
        % Fit nose
        Nan_frames = find(isnan(Nose(:,1)));
        
        
        Nose(Nose == 0) = NaN;
        rawaxis = find(~isnan(Nose(:,1)));
        fitaxis = 1:nframes;
        Nose(1:nframes,1) = spline(rawaxis,Nose(rawaxis,1),fitaxis);
        Nose(1:nframes,2) = spline(rawaxis,Nose(rawaxis,2),fitaxis);
        
        Nose(Nan_frames,:) = NaN;
        Output.Nose = Nose;
        
        % Fit Angle
        AngleVector(AngleVector == 0) = NaN;
        rawaxis = find(~isnan(AngleVector(:,1)));
        fitaxis = 1:nframes;
        AngleVector(1:nframes,1) = spline(rawaxis,AngleVector(rawaxis,1),fitaxis);
        AngleVector(1:nframes,2) = spline(rawaxis,AngleVector(rawaxis,2),fitaxis);
        AngleVector(Nan_frames,:) = NaN;
        Output.AngleVector = AngleVector;
        
        
        
    case 'Manual'
        video = Output.Video;
        nframes = video.Duration*video.FrameRate;
        for framenr = 1:ceil(nframes/30):nframes-1
            frame = LoadFrame(video,framenr);
            figure(1)
            clf
            imshow(frame)
            try
                [Nose(framenr,1),Nose(framenr,2)] = getpts(figure(1));
            end
        end
        tick = 1;
        for framenr = 1:ceil(nframes/30):nframes-1
            frame = LoadFrame(video,framenr);
            figure(1)
            clf
            
            imshow(frame)
            hold on
            scatter(Nose(framenr,1),Nose(framenr,2),'r','filled')
            try
                [Angle(framenr,1),Angle(framenr,2)] = getpts(figure(1));
            end
        end
        
        
        xaxis = 0:250;%nframes-1;
        Nose(Nose == 0) = NaN;
        Angle(Angle == 0) = NaN;
        a = (1:ceil(nframes/30):250);
        Nosen(:,1) = spline(a,Nose(a,1),...
            xaxis);
        Nosen(:,2) = spline(a,Nose(a,2),...
            xaxis);
        Anglen(:,1)= spline(a,Angle(a,1),...
            xaxis);
        Anglen(:,2)= spline(a,Angle(a,2),...
            xaxis);
        %Nose = Nosen;
        %Angle = Anglen;
        for i = 1:250%nframes - 1
            video.CurrentTime = i/video.FrameRate;
            frame = readFrame(video);
            figure(1)
            clf
            imshow(frame)
            hold on
            scatter(Nosen(i,1),Nosen(i,2),'r','filled')
            scatter(Anglen(i,1),Anglen(i,2),'g')
            
            drawnow
        end
        Output.Output.Nose = Nose;
        Output.Output.Angle = Angle;
        
        
end


