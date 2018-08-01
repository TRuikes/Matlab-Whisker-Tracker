clear
path = 'E:\Studie\Stage Neurobiologie\Videos\VideoDatabase\Tracker Performance'

vids = dir(fullfile(path,'*.dat'));

for i = 1:10 %:size(vids,1)
    clear Settings
    makeSettings;
    Settings.Video = fullfile( vids(i).folder, vids(i).name);
    Settings.PathName = vids(i).folder;
    Settings.FileName = vids(i).name;
    mfile = Settings.Video;
    mfile(end-2) = 'm';
    load(mfile)
    Settings.Video_width = Data.Resolution(1);
    Settings.Video_heigth = Data.Resolution(2);
    Settings.Nframes = Data.NFrames;
    Settings.batch_mode = 1;
    
    [Objects{i}, ~] = ObjectDetection(Settings);
    
end


%%
figure(1)
clf
for i = 1:10
     clear Settings
    makeSettings;
    Settings.Video = fullfile( vids(i).folder, vids(i).name);
    Settings.PathName = vids(i).folder;
    Settings.FileName = vids(i).name;
    mfile = Settings.Video;
    mfile(end-2) = 'm';
    load(mfile)
    Settings.Video_width = Data.Resolution(1);
    Settings.Video_heigth = Data.Resolution(2);
    Settings.Nframes = Data.NFrames;
    Settings.Current_frame = round(Settings.Nframes*0.8);
    frame = LoadFrame(Settings);
    
    subplot(3,4,i)
    imagesc(frame)
    colormap gray
    
    
    [ia,ib] = find(edge(Objects{i}));
    hold on
    scatter(ib,ia,1,'r','filled')
end