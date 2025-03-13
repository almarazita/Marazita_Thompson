%% Plot_Low_v_High_DI
visual = true;
responsive_only = true;

LowH_DI = [unit_data.LowH_DI];
HighH_DI = [unit_data.HighH_DI];
if responsive_only
    visual_evoked_p = [unit_data.visual_evoked_p];
    criteria = (visual_evoked_p < 0.05) & ~isnan(LowH_DI) & ~isnan(HighH_DI); % responsive only
else
    criteria = ~isnan(LowH_DI) & ~isnan(HighH_DI);
end

% Plot Visual
figure; hold on;
ax = gca;
ax.LineWidth = 2;
set(ax, 'FontSize', 14);

plot(LowH_DI(criteria), HighH_DI(criteria), 'ok',...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w', 'MarkerSize', 10);
m = round(max([LowH_DI(criteria); HighH_DI(criteria)]), 1);
xlim([0, 0.6]);
ylim([0, 0.6]);
yticks(xticks());
plot([0, 0.6],[0, 0.6], '--k', 'LineWidth', 2);
box on; axis square;
xlabel('Low Hazard Cue DI');
ylabel('High Hazard Cue DI');
if visual
    title('Visual Epoch');
else
    title('Memory Epoch');
end

% Annotations
n_upper = sum(LowH_DI(criteria) < HighH_DI(criteria));
n_lower = sum(LowH_DI(criteria) > HighH_DI(criteria));

dim = [.3 .5 .3 .3];
annotation('textbox', dim, 'String', ['N = ' num2str(n_upper)], 'FitBoxToText', 'on');
dim = [.7 0 .3 .3];
annotation('textbox', dim, 'String', ['N = ' num2str(n_lower)], 'FitBoxToText', 'on');