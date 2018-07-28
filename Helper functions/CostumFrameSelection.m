function frame_idx = CostumFrameSelection(Settings, Output)
%%
% Return a binary array of size 1 x nframes, 1 indicates the frame should
% be tracked

%%
mode = 'DEFAULT';

switch(mode)
    case 'DEFAULT' 
        frame_idx = ones(1,Settings.Nframes);
        
        
    case 'NOSE_REQUIRED'
        % Only track frames where a nose position is found at least 5px
        % from border
        frame_idx = ones(1,Settings.Nframes);
        
        Nose  = Output.Nose;

        for i = 1:length(frame_idx)
            if Nose(i,1) <= 5 | Nose(i,2) <= 5 | ...
                    Nose(i,1) >= Settings.Video_width-5 | ...
                    Nose(i,2) >= Settings.Video_heigth-5
                
                frame_idx(i) = 0;
            end
        end
end
        
        
