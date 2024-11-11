%For a 3-circle venn, Z is a 7 element vector [z1 z2 z3 z12 z13 z23 z123]
z(1) = sum(unit_table.visual_evoked_p<0.05/3 & unit_table.memory_evoked_p>0.05/3 & unit_table.saccade_evoked_p>0.05/3);
z(2) = sum(unit_table.memory_evoked_p<0.05/3 & unit_table.visual_evoked_p>0.05/3 & unit_table.saccade_evoked_p>0.05/3);
z(3) = sum(unit_table.saccade_evoked_p<0.05/3 & unit_table.memory_evoked_p>0.05/3 & unit_table.visual_evoked_p>0.05/3);
z(4) = sum(unit_table.visual_evoked_p<0.05/3 & unit_table.memory_evoked_p<0.05/3 & unit_table.saccade_evoked_p>0.05/3);
z(5) = sum(unit_table.visual_evoked_p<0.05/3 & unit_table.saccade_evoked_p<0.05/3 & unit_table.memory_evoked_p>0.05/3);
z(6) = sum(unit_table.memory_evoked_p<0.05/3 & unit_table.saccade_evoked_p<0.05/3 & unit_table.visual_evoked_p>0.05/3);
z(7) = sum(unit_table.visual_evoked_p<0.05/3 & unit_table.memory_evoked_p<0.05/3 & unit_table.saccade_evoked_p<0.05/3);

figure;
v = venn(z,'FaceColor',{[27 158 119]./255,[217 95 2]./255,[117 112 179]./255});
% axis square;
