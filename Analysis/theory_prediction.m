%% Definitions
% Convert LLR to probability
pFromBelief = @(beliefs) 1./(1+exp(-beliefs));

% Divergence
dkl = @(p1,p2) sum(p1.*log(p1./p2));
dklFromBelief = @(b1,b2) dkl([pFromBelief(b1) 1-pFromBelief(b1)], [pFromBelief(b2) 1-pFromBelief(b2)]);

% Certainty
negentropy = @(ps) ps.*log(ps)+(1-ps).*log(1-ps);
neFromBelief = @(belief) negentropy(pFromBelief(belief));

%% Calculate
% Setup
h = 0.05;
prior = log(h ./ (1 - h));
cues = [-inf, -0.4771, 0, 0.4771, inf]; % true values
%cues = [-3.1781, -0.4771, 0, 0.4771, 3.1781]; % no infinities for illustrative purposes (P(T1|extreme T1 cue) = 0.96
cue_names = ["Strong T1", "Weak T1", "Ambiguous", "Weak T2", "Strong T2"];

% Update belief
hScale = (1-h)./h;
prior_belief = prior + log(hScale+exp(-prior)) - ...
    log(hScale+exp(prior));
cur_beliefs = prior_belief + cues;

% Certainty
ic = neFromBelief(cur_beliefs) - neFromBelief(prior);

% Disparity and KL
for cue_loc = 1:5
    %kl = dklFromBelief(cur_beliefs(cue_loc), neFromBelief(prior)); % line
    %from previous version that I think is wrong
    kl(cue_loc) = dklFromBelief(cur_beliefs(cue_loc), prior);
    ir(cue_loc) = kl(cue_loc)-ic(cue_loc);
end

% Redo for extreme cue locations that threw NaNs
negentropy_ref = negentropy(h);
ic(1) = 0 - negentropy_ref;
ic(5) = 0 - negentropy_ref;
xaxis = 0:0.001:1;
yaxis = negentropy(xaxis);
dy = diff(yaxis); dx = diff(xaxis); dy_dx = dy ./ dx;
grad_ref = dy_dx(xaxis == h);

dx = pFromBelief(cur_beliefs(1)) - h;
ir(1) = -1*grad_ref*dx;
kl(1) = ic(1) + ir(1);

dx = pFromBelief(cur_beliefs(5)) - h;
ir(5) = -1*grad_ref*dx;
kl(5) = ic(5) + ir(5);

%% Print results
for cue_loc = 1:5
    disp(cue_names(cue_loc));
        fprintf('%.3f DKL = %.3f ic + %.3f ir\n', kl(cue_loc), ...
            ic(cue_loc), ir(cue_loc));
end

%% Plot
% Bar graphs with quantities grouped together in rows
%colors = ["#20419A", "#437DB7", "#000000", "#79ABC5", "#70CDDD"]; % low-switch
% colors = ["#8C191B", "#CB2027", "#000000", "#E32026", "#EF8480"]; % high-switch
% 
% figure;
% t = tiledlayout(8, 1, 'TileSpacing', 'tight');
% nexttile(1, [2 1]);
% b = bar(ic, 'EdgeColor', 'flat');
% b.FaceColor = 'flat';
% for cue_loc = 1:5
%     b.CData(cue_loc,:) = hex2rgb(colors(cue_loc));
% end
% ylim([-0.3, 0.7]); % based on overall max/min values
% ax = gca;
% ax.LineWidth = 1;
% set(ax,'Xtick',[]);
% set(ax, 'XColor', 'k', 'YColor', 'k');
% 
% nexttile();
% b = bar(ir, 'EdgeColor', 'none');
% b.FaceColor = 'flat';
% for cue_loc = 1:5
%     b.CData(cue_loc,:) = hex2rgb(colors(cue_loc));
% end
% ylim([2.6, 3]);
% ax = gca;
% ax.LineWidth = 1;
% set(ax,'Xtick',[]);
% set(ax, 'XColor', 'k', 'YColor', 'k');
% nexttile(4, [2 1]);
% b = bar(ir, 'EdgeColor', 'flat');
% b.FaceColor = 'flat';
% for cue_loc = 1:5
%     b.CData(cue_loc,:) = hex2rgb(colors(cue_loc));
% end
% ylim([-0.3, 0.7]);
% ax = gca;
% ax.LineWidth = 1;
% set(ax,'Xtick',[]);
% set(ax, 'XColor', 'k', 'YColor', 'k');
% 
% nexttile;
% b = bar(kl, 'EdgeColor', 'flat');
% b.FaceColor = 'flat';
% for cue_loc = 1:5
%     b.CData(cue_loc,:) = hex2rgb(colors(cue_loc));
% end
% ylim([2.6, 3]);
% ax = gca;
% ax.LineWidth = 1;
% set(ax,'Xtick',[]);
% set(ax, 'XColor', 'k', 'YColor', 'k');
% nexttile(7, [2 1]);
% b = bar(kl, 'EdgeColor', 'flat');
% b.FaceColor = 'flat';
% for cue_loc = 1:5
%     b.CData(cue_loc,:) = hex2rgb(colors(cue_loc));
% end
% ylim([-0.3, 0.7]);
% ax = gca;
% ax.LineWidth = 1;
% set(ax,'Xtick',[]);
% set(ax, 'XColor', 'k', 'YColor', 'k');

% % Bar graph for each cue location
% for cue_loc = 1:5
%     figure;
%     bar([ic(cue_loc), ir(cue_loc), kl(cue_loc)], 'FaceColor', ...
%         colors(cue_loc), 'EdgeColor', edge_colors(cue_loc, :), ...
%         'DisplayName', cue_names(cue_loc));
%     ylim([1.1*-0.2406, 1.1*0.3616]);
%     xticklabels(["Certainty", "Disparity", "DKL"]);
%     legend();
% end
% 
% 1D belief updates
% figure;
% hold on;
% 
% p1 = plot([0, 1], [0, 0], 'k-', 'LineWidth', 2);
% p2 = plot([0, 0], [-0.1, 0.1], 'k-', 'LineWidth', 2);
% p3 = plot([0.5, 0.5], [-0.1, 0.1], 'k-', 'LineWidth', 2);
% p4 = plot([1, 1], [-0.1, 0.1], 'k-', 'LineWidth', 2);
% 
% for cue_loc = 1:5
%     scatter(pFromBelief(cur_beliefs(cue_loc)), 0, 100, ...
%         'filled', 'MarkerFaceColor', colors(cue_loc), ...
%         'DisplayName', cue_names(cue_loc));
% end
% 
% ylim([-1 1]);
% set(gca, 'XColor', 'k', 'YColor', 'k');
% p1.HandleVisibility = 'off';
% p2.HandleVisibility = 'off';
% p3.HandleVisibility = 'off';
% p4.HandleVisibility = 'off';
% legend();

% % 2D negentropy curve
% figure;
% set(gcf, 'Units', 'inches', 'Position', [0, 0, 14.2158, 7.33]);
% hold on;
% 
% xaxis = 0:0.001:1;
% yaxis = negentropy(xaxis);
% p = plot(xaxis, yaxis, 'DisplayName', '');
% scatter(h, negentropy(h), 'DisplayName', 'Prior = 0.50');
% certaintys = neFromBelief(cur_beliefs);
% certaintys(1) = 0; certaintys(5) = 0;
% for cue_loc = 1:5
%     scatter(pFromBelief(cur_beliefs(cue_loc)), ...
%         certaintys(cue_loc), ...
%         'DisplayName', cue_names(cue_loc));
% end
% 
% p.HandleVisibility = 'off';
% legend();
% xlabel('P(Target 2)');
% ylabel('Negative entropy ("certainty")');