%% Violin plots of cue location
figure; hold on;

%% Firt for visual cue onset
criteria = unit_table.visual_evoked_p<0.05;

subplot(2,2,1); hold on;
v = violinplot(unit_table.lowH_targ_mean(criteria,:));
ylim([-15,25]);
plot([0,10],[0 0],'--k')
for targ = 1:length(v)
    v(targ).ViolinColor = {[0, 114, 189]./255};
end

subplot(2,2,2); hold on;
v = violinplot(unit_table.highH_targ_mean(criteria,:));
ylim([-15,25]);
plot([0,10],[0 0],'--k')
for targ = 1:length(v)
    v(targ).ViolinColor = {[194, 30, 80]./255};
end


criteria = unit_table.memory_evoked_p<0.05;

subplot(2,2,3); hold on;
v = violinplot(unit_table.Memory_lowH_targ_mean(criteria,:));
ylim([-20,15]);
plot([0,10],[0 0],'--k')
for targ = 1:length(v)
    v(targ).ViolinColor = {[0, 114, 189]./255};
end

subplot(2,2,4); hold on;
v = violinplot(unit_table.Memory_highH_targ_mean(criteria,:));
ylim([-20,15]);
plot([0,10],[0 0],'--k')
for targ = 1:length(v)
    v(targ).ViolinColor = {[194, 30, 80]./255};
end