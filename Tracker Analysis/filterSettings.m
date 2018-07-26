
% Filter parameters for frame rejection
Settings.min_nose_dist = 40; % minimum required distance of nose from border
Settings.frame_density = 0.75; % percentage of neighbouring frames with traces
Settings.max_accel = 5; % Maximum acceleration of nose (px/frameinterval)
Settings.min_length = 20; % minimum required length (# of entries in raw traces ~ approx 1 stepsize per entry)
Settings.max_distance = 120; % Maximum distance from estimated midpoint, to be included

% Filter parameters for trace rejection
Settings.max_dist_trace_nose = 100; % Only inlude traces close to nose
Settings.min_trace_length = 15;


% Fitting settings
Settings.fit_degree = 2;
Settings.cutoff = 3; % cutoff length on both endings of trace before fitting

% Touch detection settings
Settings.dist_object = 5;