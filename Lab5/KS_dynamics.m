close all;
clear;
clc;

%% Load database, normalizaton and feature extraction
db = load('keydyn_db.mat');

%{
  Time normalization:
    1. start time is 0
    2. milliseconds to seconds -> divided by 1000
  Keycode normalization:
    keycodes divided by 255
  Feature extraction:
    Down(Press) - 68, Up(Release) - 85
    HL: Hold Latency (dt between press and release)
    IL: Inter-key Latency (dt between releasing previous and pressing next -> 85-68 pairs)
    PL: Press Latency (dt between 2 consecutive presses)
    RL: Release Latency (dt between 2 consecutive releases)
%}

HL = [];
IL = [];
PL = [];
RL = [];

%{
  I delete records, that doesn't make any sense.
  There is consecutively 4 press for the same keycode
  and I can't handle it another way now, so I delete the first 3.
  This was the only one, where I found error.
%}
db.recordings{20,2}(:,1:3) = [];

for i = 1:size(db.recordings, 1)
    start_time = db.recordings{i,2}(2,1);
    press_time = [];
    release_time = [];
    press_key_wth_time = [];
    release_key_wth_time = [];
    ik_prev_code = 0;
    hl_idx = 1;
    il_idx = 1;
    for j = 1:size(db.recordings{i,2}, 2)
        db.recordings{i,2}(2,j) = (db.recordings{i,2}(2,j) - start_time)/1000;
        db.recordings{i,2}(3,j) = db.recordings{i,2}(3,j)/255;
        if db.recordings{i,2}(1,j) == 68
            if ik_prev_code == 85
                IL(i,il_idx) = db.recordings{i,2}(2,j) - db.recordings{i,2}(2,j-1);
                il_idx = il_idx + 1;
            end
            press_time = [press_time db.recordings{i,2}(2,j)];
            press_key_wth_time = [press_key_wth_time db.recordings{i,2}(3,j) db.recordings{i,2}(2,j)];
            ik_prev_code = 68;
        else
            release_time = [release_time db.recordings{i,2}(2,j)];
            release_key_wth_time = [release_key_wth_time db.recordings{i,2}(3,j) db.recordings{i,2}(2,j)];
            ik_prev_code = 85;
        end
        if length(press_key_wth_time) == 4 && length(release_key_wth_time) == 2
            if press_key_wth_time(3) == release_key_wth_time(1)
                HL(i,hl_idx) = release_key_wth_time(2) - press_key_wth_time(4);
                press_key_wth_time(end-1:end) = [];
                release_key_wth_time(end-1:end) = [];
                hl_idx = hl_idx + 1;
            elseif press_key_wth_time(1) == release_key_wth_time(1)
                HL(i,hl_idx) = release_key_wth_time(2) - press_key_wth_time(2);
                press_key_wth_time(1:2) = [];
                release_key_wth_time(end-1:end) = [];
                hl_idx = hl_idx + 1;
            end
        elseif length(press_key_wth_time) == 2 && length(release_key_wth_time) == 2
            if press_key_wth_time(1) == release_key_wth_time(1)
                HL(i,hl_idx) = release_key_wth_time(2) - press_key_wth_time(2);
                press_key_wth_time(end-1:end) = [];
                release_key_wth_time(end-1:end) = [];
                hl_idx = hl_idx + 1;
            end
        end
    end
    act_press = press_time(1);
    act_release = release_time(1);
    for k = 2:length(press_time)
        PL(i,k-1) = press_time(k) - act_press;
        act_press = press_time(k);
        RL(i,k-1) = release_time(k) - act_release;
        act_release = release_time(k);
    end
end

%% Classification and Recognition
%{
  1. Holdout - 1 sentence randomly
  2. Find two closest pair with distance metrics
  3. Validate it with unique IDs
%}
rng(1);
HL_kmeans = kmeans(HL,10);
IL_kmeans = kmeans(IL,10);
PL_kmeans = kmeans(PL,10);
RL_kmeans = kmeans(RL,10);

%{
  Here a visualisation would be great, but from the data it can be seen,
  that for same people often the cluster numbers are the same.
  I also tried it with one feature vector(all features together in one row
  for one sample), but a lot of them got the same cluster number.
%}

holdout_idx = 7
HL_distance = [];
IL_distance = [];
PL_distance = [];
RL_distance = [];
dist = [];

HL_out = HL(holdout_idx);
IL_out = IL(holdout_idx);
PL_out = PL(holdout_idx);
RL_out = RL(holdout_idx);
HL(holdout_idx) = [];
IL(holdout_idx) = [];
PL(holdout_idx) = [];
RL(holdout_idx) = [];

for idx = 1:size(db.recordings, 1)
    HL_distance(idx) = pdist2(HL_out,HL(idx),'euclidean');
    IL_distance(idx) = pdist2(IL_out,IL(idx),'euclidean');
    PL_distance(idx) = pdist2(PL_out,PL(idx),'euclidean');
    RL_distance(idx) = pdist2(RL_out,RL(idx),'euclidean');
    dist(idx) = HL_distance(idx) + IL_distance(idx) + PL_distance(idx) + RL_distance(idx);
end

[min_dist, min_idx] = min(dist);
% The min_idx is always one less after the holded out, so corrected it.
if min_idx >= holdout_idx
    min_idx = min_idx + 1;
end

min_idx

%{
  I calculated the Euclidean distance for all features compared to the left
  out, then summed the distances and chose the minimum one.

  It is not the best, also not the nicest solution, and not works for all,
  but works for some of them. :)
  Also, I didn't have time for validation and visualisation. For me
  validation was the index comparison with eyes.
  Indexes belonging together:
    1. (1,2,3)
    2. (4,5,6)
    3. (7,8,9)
    4. (10,11,12)
    5. (13,14,15)
    6. (16,17,18)
    7. (19,20,21)
    8. (22,23,24)
    9. (25,26,27)
    10. (28,29,30)
%}
