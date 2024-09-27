function data = new_plotAODR_sessionNeural_Overview(session_struct, axs)
% MEGA figure
% Author: Annie, adapted from Victoria Subritzky Katz (with a little help from chatgpt)
% Date: September 2024

%% Get data
arguments
    session_struct = []; % Cell in cell array loaded in by new_loadClean
    axs = [];
end
%data = session_struct.data;
data = session_struct;
n_units = length(data.spikes.id);

%% Run subplot plotting functions feeding them specfic axes, ax_cur for each neuron
for u = 1:n_units

    % Set up Plot
    % Set up mega figure specs and get axes
    wid     = 18; 
    hts     = 4.5.*ones(1,4);
    cols    = {4,4,4,4}; % 4 rows with 4 subplots in each
    [axs, fig, ~] = new_getPLOT_axes(1, wid, hts, cols, 2.2, [], [], [], false);
    
    set(axs, 'Units', 'normalized');
    
    %Set the position of the figure
    %fig.Position = [10 30 40 30];

    %All trials across hazards
    ax_cur = [axs(1), axs(5)]; 
    new_plotHazardPSTH(data, u, ax_cur); 

    %Switch in low hazard
    ax_cur = [axs(2), axs(6)]; 
    new_plotSwitchPSTH(data, u, ax_cur); 

    %spatial tuning using ODR task (when present)
    ax_cur = [axs(3), axs(7)]; 
    new_plotPolarTask(data,u,ax_cur); 

    %average firing rate for each cue across hazards
    ax_cur = [axs(4), axs(8)]; 
    new_plotHazardCueAvgFR(data,u,ax_cur)

    %ambiguous cue across hazards
    ax_cur = [axs(9), axs(13)]; 
    new_plotCueLocPSTH(data,u,ax_cur,0); 

    %strong evidence cues across hazards
    ax_cur = [axs(10), axs(14)]; 
    new_plotCueLocPSTH(data,u,ax_cur,[-4,-3,4,3]); 

    %mixed evidence cue across hazards
    ax_cur = [axs(11), axs(15)]; 
    new_plotCueLocPSTH(data,u,ax_cur,[-1,1]); 

    %baseline drift
    ax_cur = axs(12); 
    new_plotBaselineDrift_AODR(data,u,'sample_on',300,ax_cur,[]);

    % 
    % %delete the axis and instead plot the grid hole information as text
    % delete(axs(16))
    % annotation('textbox', [0.75 0.15 0.3 0.03], ...
    %     'String', ['Grid Hole: '], 'EdgeColor', 'none', ...
    %     'HorizontalAlignment', 'left', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');
    % 
    %set custom title so it doesn't overlap polar plot figure
    filename = data.header.filename;
    startIdx = strfind(filename, 'MM');
    endIdx = strfind(filename, '.hdf5') - 1;
    sessionName = filename(startIdx:endIdx);
    %annotation('textbox', [0.05 0.97 0.3 0.03], ...
        %'String', [sessionName ' Unit: ' num2str(data.spikes.id(u))], 'EdgeColor', 'none', ...
        %'HorizontalAlignment', 'left', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');

    % Save as PDF
    pdfFileName = sessionName+"_Unit"+num2str(data.spikes.id(u))+".pdf";
    %print(fig, pdfFileName, '-dpdf', '-r0');
    exportgraphics(fig, pdfFileName, 'ContentType', 'vector');
    close(fig);

end