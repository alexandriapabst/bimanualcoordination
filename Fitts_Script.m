%load data in with .zip file, analyzes data and outputs spreadsheet

data = zip_load('*.zip');									% Loads the named file into a new structure called 'data'.
data = KINARM_add_hand_kinematics(data);						% Add hand velocity, acceleration and commanded forces to the data structure
data = filter_double_pass(data, 'enhanced', 'fc', 10);	
    
%%
peak_vel_RightHand = []; %peak velocity of right hand
peak_vel_LeftHand = []; %peak velocity of left hand

reach_diff = []; %storing the difference in reaches (b/w L & R hand) per trial

vel_inxL = []; %storing the index of peak velocity per trial
vel_inxR = [];

trial_len2 = []; %total trial length of second limb

mo_timeR = []; %movement onset of right limb
mo_timeL = []; %movement onset of left limb

for k = 1:length(data.c3d)
    trial_len1(k) = round(1000 * data.c3d(k).EVENTS.TIMES(1,2)); %change to ms
    trial_len2(k) = round(1000 * data.c3d(k).EVENTS.TIMES(1,3)); %change to ms
    reach_diff(k) = trial_len2(k) - trial_len1(k); %calculate difference in reach time per trial in ms
    
    peak_vel_RightHand(k) = max(abs(data.c3d(k).Right_L2Vel(1:trial_len2(k))));
    peak_vel_LeftHand(k) = max(abs(data.c3d(k).Left_L2Vel(1:trial_len2(k))));
    
    vel_inxL(k) = find((abs(data.c3d(k).Left_L2Vel(1:trial_len2(k))))==(peak_vel_LeftHand(k)),1,'first');
    vel_inxR(k) = find((abs(data.c3d(k).Right_L2Vel(1:trial_len2(k))))==(peak_vel_RightHand(k)),1,'first');
    
    mo_timeL(k) = find((abs(data.c3d(k).Left_L2Vel(1:trial_len2(k))))>=(0.05*peak_vel_LeftHand(k)),1,'first');
    mo_timeR(k) = find((abs(data.c3d(k).Right_L2Vel(1:trial_len2(k))))>=(0.05*peak_vel_RightHand(k)),1,'first');
    %using velocity threshold for determining movement onset time
    k = k+1;
end

T = table(trial_len1',trial_len2',reach_diff',peak_vel_RightHand',peak_vel_LeftHand',vel_inxR',vel_inxL',mo_timeR',mo_timeL');
filename = 'Fitts35.csv'; %write to whatever filename you want
writetable(T,filename)

