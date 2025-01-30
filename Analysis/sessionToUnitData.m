function [unit_data, unit_table] = sessionToUnitData(data)
%% function [unit_data, unit_table] = sessionToUnitData(data,unit_idx,baseline_sub)
% converts data structs, where spike data for multiple units is stored in
% matrices for each session, into a unit struct where each element is a
% single unit, and a unit table which documents information about each
% unit.

% LWT 10/13/24

%% Loop through the data structure
fprintf(2,'\nConverting %i sessions of data into unit format...\n',length(data))
unit_table = table();
unit_num = 0;
for ifile = 1:length(data)
    n_units = size(data{ifile}.spike_time_mat,1);
    for u = 1:n_units
        unit_idx = u;
        unit_num = unit_num+1;
        % Only trials with a sample are valid!!!
        event_idx = ~isnan(data{ifile}.times.('sample_on'));
        unit_data(unit_num).header = data{ifile}.header;
        unit_data(unit_num).fileName = data{ifile}.header.filename;
        unit_data(unit_num).ids = data{ifile}.ids(event_idx,:);
        unit_data(unit_num).values = data{ifile}.values(event_idx,:);
        unit_data(unit_num).times = data{ifile}.times(event_idx,:);
        unit_data(unit_num).spikes.channel = data{ifile}.spikes.channel(unit_idx);
        unit_data(unit_num).spikes.id = data{ifile}.spikes.id(unit_idx);
        % unit_data(unit_num).spikes.data = data{ifile}.spikes.data(event_idx,unit_idx);
        % unit_data(unit_num).spike_time_mat = data{ifile}.spike_time_mat(unit_idx,:,event_idx);
        unit_data(unit_num).binned_spikes = data{ifile}.binned_spikes(unit_idx,:,event_idx);
        unit_data(unit_num).baseline_pupil = data{ifile}.baseline_pupil;
        unit_data(unit_num).cleaned_pupil = data{ifile}.cleaned_pupil;
        unit_data(unit_num).bs_evoked_pupil = data{ifile}.bs_evoked_pupil;
        % unit_data(unit_num).analog = data{ifile}.analog;
        % unit_data(unit_num).analog.data = data{ifile}.analog.data(event_idx,:);
        % unit_data(unit_num).GridHole = data{ifile}.GridHole;

        unit_table.unit_id(unit_num) = data{ifile}.spikes.id(unit_idx);
        unit_table.channel_num(unit_num) = data{ifile}.spikes.channel(unit_idx);
        unit_table.fileName(unit_num,:) = {data{ifile}.header.filename};
        % unit_table.GridHole(unit_num,:) = data{ifile}.GridHole;
    end
end
fprintf(2,'\nComplete\n')
end