clear all; clc; close all
saveImage = 0;
ImagesOn = 1;
ylimits = [0 125];
ylimits_2 = [0 150];
font_Size = 20;
marker_size = font_Size;

scene_order = {'Seminar Room/ Example 1','Seminar Room/ Example 2'};
stimuli_order = {'Reference','Example 1','Example 2'};

% download from: https://github.com/bastibe/Violinplot-Matlab
addpath('./resources_/Violinplot-Matlab-master')
% download from: https://github.com/raacampbell/sigstar
addpath('./resources_/sigstar-master')
fileName_= {'example.json'; ...
            'example2.json'};
for i =1:size(fileName_,1)
    str = fileread(fileName_{i}); 
    data = jsondecode(str);
    for j = 1:length(scene_order)
        results_(i,j,:,:) = cell2mat({data.experimentData.sessions.groups(j).stimuli.responses});
    end 
end

Reshaped_results = reshape(results_(:,:,2,:),size(fileName_,1),6,6);

%% Friedman Tests

% This removes the outliers if any. Example shows an outlier at position 5
% Reshaped_results(5,:,:)= [];
% fileName_(5) = [];

%% Test if results conform to a gaussian curve
% for i=1:5
%     h=jbtest(results_(:,i)) % use appropriate indexing
% end

% %% Medians
% 
% for i = 1:6
%     Medians(i,:) = median(squeeze(Reshaped_results(i,:,:)));
% end

%% Friedman test

for i=1:6
    % This does the equivalent of the ANOVA analysis. I've only included
    % 1:4 columns (all stimuli except the reference) here because of the paper we used it for. 
    % But you should do all the columns (stimuli)
   [p_friedman_(i),tbl,stats]=friedman(squeeze(Reshaped_results(:,i,:)));

   % This does the ad-hoc anaylsis. 'Ctype' refers to the correction type.
   % It's new name is CriticalValueType
   % The default correction for the alpha value is Tukey’s honesty
   % significant difference procedure, which is usually the most forgiving.
   % Bonferroni in my experience is usually the most harsh
   [c_(:,:,i),m_(:,:,i)]= multcompare(stats); %,'CType','bonferroni');


end

%% If I remember right, this was done so I could look at the results for
% % each method for the different stimuli side by side. 
%    squeeze(c_(1,:,:))'
%    squeeze(c_(2,:,:))'
%    squeeze(c_(3,:,:))'
%    squeeze(c_(4,:,:))'
   
% % This did the same as the above bits of code. I was doing a sanity check.    
% [~,~,stats]=friedman(res_scene1(:,1:4));
% c_test(:,:,1) = multcompare(stats);
% [~,~,stats]=friedman(res_scene2(:,1:4));
% c_test(:,:,2)= multcompare(stats);
% 
%    squeeze(c_test(1,:,:))'
%    squeeze(c_test(6,:,:))'
%    squeeze(c_test(5,:,:))'
% close all;

%% This is the hardcoded way to indicate significance
% further down is the way to do it automatically
% significance_groups = {{[1,4],[1,5],[1,6]} ...
%                                {[1,3],[1,4],[1,5],[1,6]} ...
%                                {[1,4],[1,5],[1,6]} ...
%                                {[1,4],[1,5],[1,6]} ...
%                                {[1,3],[1,4],[1,5],[1,6]} ...
%                                {[1,4],[1,5],[1,6]}};

%%
for i=1:length(scene_order)
    % this section computes the plot for just reference comparisons
    temp = squeeze(c_(1:5,end,i))';
    significance_values{1,i} = temp(find(temp(end,:)<=0.05));
    temp = squeeze(c_(1:5,end,i))';
    temp_idx = find(temp(end,:)<=0.05);
    significance_values{1,i} = temp(temp_idx); %#ok


    % this section compares all groups
    temp_2 = squeeze(c_(:,[1 2 end],i))';
    temp_idx = find(temp_2(end,:)<=0.05);
    significance_values_2{1,i} = temp_2(end,temp_idx); %#ok
    if(size(significance_values_2{i},2)==0) significance_groups_2{i}{1} = {}; end %#ok
    for idx=1:size(significance_values_2{i},2)
        significance_groups_2{i}{idx} = temp_2(1:2,temp_idx(idx)); %#ok
    end
    [check, idx]=ismember(significance_values_2{1,i},0);
    for temp_idx=1:(size(check,2))
        if check(temp_idx) 
            significance_values_2{1,i}(temp_idx)=[]; 
            significance_groups_2{i}(temp_idx)=[]; 
            if (size(idx)==1) significance_groups_2{i}={}; end
        end
    end
end

%%
if(ImagesOn)
%     close all
    for i = 1:length(scene_order)
        figure(999)
        subplot(2,1,i) % change this according to the number of sound scenes
        hold on
        violinplot(reshape(Reshaped_results(:,i,:),size(fileName_,1),6))
        title([scene_order{i}],'FontSize',font_Size)
        xticklabels([])
        yticklabels([0 20 40 60 80 100])
        ylim(ylimits)
        ax = gca;
        ax.FontSize = font_Size;
        sigstar(significance_groups_2{1,i},significance_values_2{1,i},0,marker_size);
        hold on
    
    end
    set(gcf, 'Position',  [0, 0, 1750, 1500])
    ha=get(gcf,'children');
%     This was done for a 6 scene MUSHRA. This will have to be changed for
%     other numbers of scenes.
%     set(ha(1),'position',[.68 .11 .3 .4])
%     set(ha(2),'position',[.355 .11 .3 .4])
%     set(ha(3),'position',[.03 .11 .3 .4])
%     set(ha(4),'position',[.68 .55 .3 .4])
%     set(ha(5),'position',[.355 .55 .3 .4])
%     set(ha(6),'position',[.03 .55 .3 .4])
    if(saveImage)
        set(gcf, 'Position',  [0, 0, 1750, 1500]) % set to make image as big as possible
        saveas(gcf, '/Results/Example.jpeg')
        saveas(gcf, '/Results/Example','epsc')
    end
% \end{table}