close all
clear all

startdir = 'C:\olivia\data\savings chapter';
%startdir = 'C:\Users\kimol\Documents\MATLAB';
cd(startdir)
load('190920_compiledForSavingsChapter_dayData.mat')
load('190920_compiledTrialsForSavingsChapter.mat')
load('190920_compiledForSavingsChapter_block20Data.mat')
load('190920_compiledForSavingsChapter_block10Data.mat')

% start out looking at regular extinction
mice = {'OK001';...
    'OK002';...
    'OK003';...
    'OK004';...
    'OK005';...
    'OK006';...
    'OK007';...
    'OK008'};

starthere = 1;
plotdata.mouse = {};
plotdata.cradjamp = nan(8,70);
plotdata.crprob = nan(8,70);
btwnSessDev.mouse = {};
btwnSessDev.cradjamp = nan(8,8);
btwnSessDev.crprob = nan(8,8);
for m = 1:length(mice)
    
    mouseidx = [];
    while strcmpi(block10dat.mouse{starthere}, mice(m,1))
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(block10dat.mouse)
            break
        end
    end
    
    plotdata.mouse(m,1) = mice(m,1);
    btwnSessDev.mouse(m,1) = mice(m,1);
    
    day = block10dat.day(mouseidx,1);
    cradjamp = block10dat.cradjamp(mouseidx,1);
    crprob = block10dat.crprob(mouseidx,1);
    sesstype = {};
    extidx = zeros(length(mouseidx),1);
    for i = 1:length(mouseidx)
        sesstype = [sesstype; block10dat.sesstype{mouseidx(i),1}];
        if strcmpi(block10dat.sesstype{mouseidx(i),1}, 'extinction')
            extidx(mouseidx(i),1) = 1;
        end
    end
    
    
    % we also want to take the blocks from the 2 preceeding days (only had
    % 2 day performance criterion, & extinction proceeds so rapidly that we
    % don't really want to include more than 2 days of extinction training
    % in the analysis)
    %       we are using the block 10 data, so we can expect that there
    %       will be 10 blocks/day (based on the way things were set up in
    %       the getDayData script) --> we want to include another 30 blocks
    %       back from where the first extidx is
    temp = find(extidx);
    startbaseline = temp(1) - 20;
    endbaseline = temp(1) - 1;
    
    bslnidx = zeros(length(mouseidx),1);
    bslnidx(startbaseline:endbaseline, 1) = 1;
    
    %% check CRAdjamp
    % plot the data to make sure things are looking reasonable
    plotme_bsln = block10dat.cradjamp(bslnidx==1);
    plotme_ext = block10dat.cradjamp(extidx==1);
    figure
    scatter(1:length(plotme_bsln), plotme_bsln)
    hold on
    scatter(21:length(plotme_ext)+20, plotme_ext)
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([70.5 70.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([80.5 80.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([90.5 90.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([100.5 100.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([110.5 110.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([120.5 120.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_ext)+21])
    ylim([0 1])
    ylabel('cradjamp')
    title(mice(m,1))
    
    try
        temp = [plotme_bsln', plotme_ext(1:40)'];
        temp = [temp, plotme_ext(end-9:end)'];
    catch ME
        temp = [plotme_bsln', plotme_ext'];
    end
    plotdata.cradjamp(m,1:length(temp)) = temp;
    
    btwnSessDev.cradjamp(m,1) = plotme_bsln(11)-plotme_bsln(10);
    btwnSessDev.cradjamp(m,2) = plotme_ext(1)-plotme_bsln(20);
    iterspot = 3;
    for i = 21:10:length(plotme_ext)
        btwnSessDev.cradjamp(m,iterspot) = plotme_ext(i)-plotme_ext(i-1);
        iterspot = iterspot + 1;
    end
    
    if sum(isnan(plotme_ext))>0
        disp('NAN FOUND IN plotme_ext')
        pause
        % pause here to catch any nan's that made it into the extinction dataset. i
        % don't think there should have been any but just in case
    end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bsln(m, 1) = plotme_bsln(1,1);
    lastBlk_bsln(m, 1) = plotme_bsln(10,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 1) = plotme_bsln(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bsln(m, 2) = plotme_bsln(11,1);
    lastBlk_bsln(m, 2) = plotme_bsln(20,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 2) = plotme_bsln(20-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_ext(m, 1) = plotme_ext(1,1);
    lastBlk_ext(m, 1) = plotme_ext(10,1);
    firstBlk_ext(m, 2) = plotme_ext(11,1);
    lastBlk_ext(m, 2) = plotme_ext(20,1);
    firstBlk_ext(m, 3) = plotme_ext(21,1);
    lastBlk_ext(m, 3) = plotme_ext(30,1);
    
    btwnSessDiffs_bsln(m,1) = firstBlk_bsln(m,2) - lastBlk_bsln(m,1);
    btwnSessDiffs_ext(m,1) = firstBlk_ext(m,2) - lastBlk_ext(m,1);
    btwnSessDiffs_ext(m,2) = firstBlk_ext(m,3) - lastBlk_ext(m,2);
    
    %% repeat for CRProb
    % plot the data to make sure things are looking reasonable
    plotme_bslnprob = block10dat.crprob(bslnidx==1);
    plotme_extprob = block10dat.crprob(extidx==1);
    figure
    scatter(1:length(plotme_bslnprob), plotme_bslnprob)
    hold on
    scatter(21:length(plotme_extprob)+20, plotme_extprob)
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([70.5 70.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([80.5 80.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([90.5 90.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([100.5 100.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([110.5 110.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([120.5 120.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_extprob)+21])
    ylim([0 1])
    ylabel('prob')
    title(mice(m,1))
    
    try
        temp = [plotme_bslnprob', plotme_extprob(1:40)'];
        temp = [temp, plotme_extprob(end-9:end)'];
    catch ME
        temp = [plotme_bslnprob', plotme_extprob'];
    end
    plotdata.crprob(m,1:length(temp)) = temp;
    
    if sum(isnan(plotme_extprob))>0
        disp('NAN FOUND IN plotme_ext')
        pause
        % pause here to catch any nan's that made it into the extinction dataset. i
        % don't think there should have been any but just in case
    end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bslnprob(m, 1) = plotme_bslnprob(1,1);
    lastBlk_bslnprob(m, 1) = plotme_bslnprob(10,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 1) = plotme_bslnprob(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bslnprob(m, 2) = plotme_bslnprob(11,1);
    lastBlk_bslnprob(m, 2) = plotme_bslnprob(20,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 2) = plotme_bslnprob(20-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_extprob(m, 1) = plotme_extprob(1,1);
    lastBlk_extprob(m, 1) = plotme_extprob(10,1);
    firstBlk_extprob(m, 2) = plotme_extprob(11,1);
    lastBlk_extprob(m, 2) = plotme_extprob(20,1);
    firstBlk_extprob(m, 3) = plotme_extprob(21,1);
    lastBlk_extprob(m, 3) = plotme_extprob(30,1);
    
    btwnSessDiffs_bslnprob(m,1) = firstBlk_bslnprob(m,2) - lastBlk_bslnprob(m,1);
    btwnSessDiffs_extprob(m,1) = firstBlk_extprob(m,2) - lastBlk_extprob(m,1);
    btwnSessDiffs_extprob(m,2) = firstBlk_extprob(m,3) - lastBlk_extprob(m,2);
end

[h, p] = ttest(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
[p, h] = signrank(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1)])
for i = 1:8
    plot([1; 2], [btwnSessDiffs_bsln(i,1); btwnSessDiffs_ext(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Amp Beginning (sess n) - CR Amp End (sess n-1)')
% Negative values on y axis means that the animal did worse at the
% beginning of the subsequent session compared to the previous session
% (last block is higher than first block).
% Positive values on the y axis means that the animal did better at the
% beginning of the subsequent session compared to the previous session
% (last block is lower than first block).


[h, p] = ttest(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
[p, h] = signrank(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1)])
for i = 1:8
    plot([1; 2], [btwnSessDiffs_bslnprob(i,1); btwnSessDiffs_extprob(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Prob Beginning (sess n) - CR Prob End (sess n-1)')


[h, p] = ttest([btwnSessDiffs_bslnprob(1,1);btwnSessDiffs_bslnprob(3:end,1)], [btwnSessDiffs_extprob(1,1); btwnSessDiffs_extprob(3:end,1)]);

% plot group performance
idx = ones(8,1);
idx(5,1) = 0;
groupdata = nanmean(plotdata.cradjamp(idx==1,:));
figure
scatter(1:70, groupdata)
hold on
plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])

% plot individual animal changes between days
for i = 1:8
figure
scatter(1:8, [btwnSessDev.cradjamp(i,1),nan,btwnSessDev.cradjamp(i,3:end)])
hold on
plot([0.5 8.5], [0 0], 'LineStyle', '--', 'Color', [0 0 0])
ylabel('- consolidation, + spont rec')
ylim([-0.35 0.35])
title(btwnSessDev.mouse(i))
end

figure
boxplot(btwnSessDev.cradjamp)


clear btwnSessDiffs_bslnprob btwnSessDiffs_extprob btwnSessDiffs_bsln btwnSessDiffs_ext

%% normal extinction mice but check trials blocked into 20
mice = {'OK001';...
    'OK002';...
    'OK003';...
    'OK004';...
    'OK005';...
    'OK006';...
    'OK007';...
    'OK008'};

starthere = 1;
for m = 1:length(mice)
    
    mouseidx = [];
    while strcmpi(block20dat.mouse{starthere}, mice(m,1))
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(block10dat.mouse)
            break
        end
    end
    
    day = block20dat.day(mouseidx,1);
    cradjamp = block20dat.cradjamp(mouseidx,1);
    crprob = block20dat.crprob(mouseidx,1);
    sesstype = {};
    extidx = zeros(length(mouseidx),1);
    for i = 1:length(mouseidx)
        sesstype = [sesstype; block20dat.sesstype{mouseidx(i),1}];
        if strcmpi(block20dat.sesstype{mouseidx(i),1}, 'extinction')
            extidx(mouseidx(i),1) = 1;
        end
    end
    
    
    % we also want to take the blocks from the 2 preceeding days (only had
    % 2 day performance criterion, & extinction proceeds so rapidly that we
    % don't really want to include more than 2 days of extinction training
    % in the analysis)
    %       we are using the block 10 data, so we can expect that there
    %       will be 10 blocks/day (based on the way things were set up in
    %       the getDayData script) --> we want to include another 30 blocks
    %       back from where the first extidx is
    temp = find(extidx);
    startbaseline = temp(1) - 10;
    endbaseline = temp(1) - 1;
    
    bslnidx = zeros(length(mouseidx),1);
    bslnidx(startbaseline:endbaseline, 1) = 1;
    
    %% check CRAdjamp
    % plot the data to make sure things are looking reasonable
    plotme_bsln = block20dat.cradjamp(bslnidx==1);
    plotme_ext = block20dat.cradjamp(extidx==1);
    figure
    scatter(1:length(plotme_bsln), plotme_bsln)
    hold on
    scatter(11:length(plotme_ext)+10, plotme_ext)
    plot([5.5 5.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([15.5 15.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([25.5 25.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([35.5 35.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([45.5 45.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([55.5 55.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_ext)+11])
    ylim([0 1])
    ylabel('cradjamp')
    title(mice(m,1))
    
    if sum(isnan(plotme_ext))>0
        disp('NAN FOUND IN plotme_ext')
        pause
        % pause here to catch any nan's that made it into the extinction dataset. i
        % don't think there should have been any but just in case
    end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bsln(m, 1) = plotme_bsln(1,1);
    lastBlk_bsln(m, 1) = plotme_bsln(5,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 1) = plotme_bsln(5-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bsln(m, 2) = plotme_bsln(6,1);
    lastBlk_bsln(m, 2) = plotme_bsln(10,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 2) = plotme_bsln(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_ext(m, 1) = plotme_ext(1,1);
    lastBlk_ext(m, 1) = plotme_ext(5,1);
    firstBlk_ext(m, 2) = plotme_ext(6,1);
    lastBlk_ext(m, 2) = plotme_ext(10,1);
    firstBlk_ext(m, 3) = plotme_ext(11,1);
    lastBlk_ext(m, 3) = plotme_ext(15,1);
    
    btwnSessDiffs_bsln(m,1) = firstBlk_bsln(m,2) - lastBlk_bsln(m,1);
    btwnSessDiffs_ext(m,1) = firstBlk_ext(m,2) - lastBlk_ext(m,1);
    btwnSessDiffs_ext(m,2) = firstBlk_ext(m,3) - lastBlk_ext(m,2);
    
    %% repeat for CRProb
    % plot the data to make sure things are looking reasonable
    plotme_bslnprob = block20dat.crprob(bslnidx==1);
    plotme_extprob = block20dat.crprob(extidx==1);
    figure
    scatter(1:length(plotme_bslnprob), plotme_bslnprob)
    hold on
    scatter(11:length(plotme_extprob)+10, plotme_extprob)
    plot([5.5 5.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([15.5 15.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([25.5 25.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([35.5 35.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([45.5 45.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([55.5 55.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_ext)+11])
    ylim([0 1])
    ylabel('prob')
    title(mice(m,1))
    
    if sum(isnan(plotme_extprob))>0
        disp('NAN FOUND IN plotme_ext')
        pause
        % pause here to catch any nan's that made it into the extinction dataset. i
        % don't think there should have been any but just in case
    end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bslnprob(m, 1) = plotme_bslnprob(1,1);
    lastBlk_bslnprob(m, 1) = plotme_bslnprob(5,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 1) = plotme_bslnprob(5-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bslnprob(m, 2) = plotme_bslnprob(6,1);
    lastBlk_bslnprob(m, 2) = plotme_bslnprob(10,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 2) = plotme_bslnprob(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_extprob(m, 1) = plotme_extprob(1,1);
    lastBlk_extprob(m, 1) = plotme_extprob(5,1);
    firstBlk_extprob(m, 2) = plotme_extprob(6,1);
    lastBlk_extprob(m, 2) = plotme_extprob(10,1);
    firstBlk_extprob(m, 3) = plotme_extprob(11,1);
    lastBlk_extprob(m, 3) = plotme_extprob(15,1);
    
    btwnSessDiffs_bslnprob(m,1) = firstBlk_bslnprob(m,2) - lastBlk_bslnprob(m,1);
    btwnSessDiffs_extprob(m,1) = firstBlk_extprob(m,2) - lastBlk_extprob(m,1);
    btwnSessDiffs_extprob(m,2) = firstBlk_extprob(m,3) - lastBlk_extprob(m,2);
end

[h, p] = ttest(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
[p, h] = signrank(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1)])
for i = 1:8
    plot([1; 2], [btwnSessDiffs_bsln(i,1); btwnSessDiffs_ext(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Amp Beginning (sess n) - CR Amp End (sess n-1)')
% Negative values on y axis means that the animal did worse at the
% beginning of the subsequent session compared to the previous session
% (last block is higher than first block).
% Positive values on the y axis means that the animal did better at the
% beginning of the subsequent session compared to the previous session
% (last block is lower than first block).


[h, p] = ttest(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
[p, h] = signrank(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1)])
for i = 1:8
    plot([1; 2], [btwnSessDiffs_bslnprob(i,1); btwnSessDiffs_extprob(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Prob Beginning (sess n) - CR Prob End (sess n-1)')


[h, p] = ttest([btwnSessDiffs_bslnprob(1,1);btwnSessDiffs_bslnprob(3:end,1)], [btwnSessDiffs_extprob(1,1); btwnSessDiffs_extprob(3:end,1)]);

clear btwnSessDiffs_bslnprob btwnSessDiffs_extprob btwnSessDiffs_bsln btwnSessDiffs_ext


%% now check the unpaired extinction mice

mice = {'S146';...
    'S147';...
    'S148';...
    'S149';...
    'OK207';...
    'OK208';...
    'OK209';...
    'OK210'};

starthere = 3131; % need to go through the array starting at the index for the first mouse listed. Mouse name list in mice and in the data array ordering must be the same.
plotdata.mouse = {};
plotdata.cradjamp = nan(8,70);
plotdata.crprob = nan(8,70);
btwnSessDev.mouse = {};
btwnSessDev.cradjamp = nan(8, 10);
btwnSessDev.crprob = nan(8, 10);
for m = 1:length(mice)
    starthereOrig = starthere;
    
    mouseidx = [];
    while strcmpi(block10dat.mouse{starthere}, mice(m,1))
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(block10dat.mouse)
            break
        end
    end
    
    plotdata.mouse(m,1) = mice(m,1);
    btwnSessDev.mouse(m,1) = mice(m,1);
    
    day = block10dat.day(mouseidx,1);
    cradjamp = block10dat.cradjamp(mouseidx,1);
    crprob = block10dat.crprob(mouseidx,1);
    sesstype = {};
    extidx = zeros(starthereOrig,1);
    for i = 1:length(mouseidx)
        sesstype = [sesstype; block10dat.sesstype{mouseidx(i),1}];
        if strcmpi(block10dat.sesstype{mouseidx(i),1}, 'extinction')
            extidx = [extidx; 1];
        else
            extidx = [extidx; 0];
        end
    end
    
    
    % we also want to take the blocks from the 2 preceeding days (only had
    % 2 day performance criterion, & extinction proceeds so rapidly that we
    % don't really want to include more than 2 days of extinction training
    % in the analysis)
    %       we are using the block 10 data, so we can expect that there
    %       will be 10 blocks/day (based on the way things were set up in
    %       the getDayData script) --> we want to include another 30 blocks
    %       back from where the first extidx is
    temp = find(extidx);
    startbaseline = temp(1) - 20;
    endbaseline = temp(1) - 1;
    
    bslnidx = zeros(length(mouseidx),1);
    bslnidx(startbaseline:endbaseline, 1) = 1;
    
    %% check CRAdjamp
    % plot the data to make sure things are looking reasonable
    plotme_bsln = block10dat.cradjamp(bslnidx==1);
    plotme_ext = block10dat.cradjamp(extidx==1);
    figure
    scatter(1:length(plotme_bsln), plotme_bsln)
    hold on
    scatter(21:length(plotme_ext)+20, plotme_ext)
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([70.5 70.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([80.5 80.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([90.5 90.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([100.5 100.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([110.5 110.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([120.5 120.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_ext)+21])
    ylim([0 1])
    ylabel('cradjamp')
    title(mice(m,1))
    
    temp = [plotme_bsln', plotme_ext(1:40)'];
    temp = [temp, plotme_ext(end-9:end)'];
    plotdata.cradjamp(m,1:length(temp)) = temp;
    
    btwnSessDev.cradjamp(m,1) = plotme_bsln(11)-plotme_bsln(10);
    btwnSessDev.cradjamp(m,2) = plotme_ext(1) - plotme_bsln(20);
    iternum = 3;
    for i = 21:10:length(plotme_ext)
        btwnSessDev.cradjamp(m,iternum) = plotme_ext(i) - plotme_ext(i-1);
        iternum = iternum + 1;
    end
    
%     if sum(isnan(plotme_ext))>0
%         disp('NAN FOUND IN plotme_ext')
%         pause
%         % pause here to catch any nan's that made it into the extinction dataset. i
%         % don't think there should have been any but just in case
%     end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bsln(m, 1) = plotme_bsln(1,1);
    lastBlk_bsln(m, 1) = plotme_bsln(10,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 1) = plotme_bsln(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bsln(m, 2) = plotme_bsln(11,1);
    lastBlk_bsln(m, 2) = plotme_bsln(20,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 2) = plotme_bsln(20-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_ext(m, 1) = plotme_ext(1,1);
    lastBlk_ext(m, 1) = plotme_ext(10,1);
    firstBlk_ext(m, 2) = plotme_ext(11,1);
    lastBlk_ext(m, 2) = plotme_ext(20,1);
    firstBlk_ext(m, 3) = plotme_ext(21,1);
    lastBlk_ext(m, 3) = plotme_ext(30,1);
    
    btwnSessDiffs_bsln(m,1) = firstBlk_bsln(m,2) - lastBlk_bsln(m,1);
    btwnSessDiffs_ext(m,1) = firstBlk_ext(m,2) - lastBlk_ext(m,1);
    btwnSessDiffs_ext(m,2) = firstBlk_ext(m,3) - lastBlk_ext(m,2);
    
    %% repeat for CRProb
    % plot the data to make sure things are looking reasonable
    plotme_bslnprob = block10dat.crprob(bslnidx==1);
    plotme_extprob = block10dat.crprob(extidx==1);
    figure
    scatter(1:length(plotme_bslnprob), plotme_bslnprob)
    hold on
    scatter(21:length(plotme_extprob)+20, plotme_extprob)
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([70.5 70.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([80.5 80.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([90.5 90.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([100.5 100.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([110.5 110.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([120.5 120.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_extprob)+21])
    ylim([0 1])
    ylabel('prob')
    title(mice(m,1))
    
    temp = [plotme_bslnprob', plotme_extprob(1:40)'];
    temp = [temp, plotme_extprob(end-9:end)'];
    plotdata.crprob(m,1:length(temp)) = temp;
    
    btwnSessDev.crprob(m,1) = plotme_bslnprob(11)-plotme_bslnprob(10);
    btwnSessDev.crprob(m,2) = plotme_extprob(1) - plotme_bslnprob(20);
    iternum = 3;
    for i = 21:10:length(plotme_extprob)
        btwnSessDev.crprob(m,iternum) = plotme_extprob(i) - plotme_extprob(i-1);
        iternum = iternum + 1;
    end
    
%     if sum(isnan(plotme_extprob))>0
%         disp('NAN FOUND IN plotme_ext')
%         pause
%         % pause here to catch any nan's that made it into the extinction dataset. i
%         % don't think there should have been any but just in case
%     end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bslnprob(m, 1) = plotme_bslnprob(1,1);
    lastBlk_bslnprob(m, 1) = plotme_bslnprob(10,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 1) = plotme_bslnprob(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bslnprob(m, 2) = plotme_bslnprob(11,1);
    lastBlk_bslnprob(m, 2) = plotme_bslnprob(20,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 2) = plotme_bslnprob(20-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_extprob(m, 1) = plotme_extprob(1,1);
    lastBlk_extprob(m, 1) = plotme_extprob(10,1);
    firstBlk_extprob(m, 2) = plotme_extprob(11,1);
    lastBlk_extprob(m, 2) = plotme_extprob(20,1);
    firstBlk_extprob(m, 3) = plotme_extprob(21,1);
    lastBlk_extprob(m, 3) = plotme_extprob(30,1);
    
    btwnSessDiffs_bslnprob(m,1) = firstBlk_bslnprob(m,2) - lastBlk_bslnprob(m,1);
    btwnSessDiffs_extprob(m,1) = firstBlk_extprob(m,2) - lastBlk_extprob(m,1);
    btwnSessDiffs_extprob(m,2) = firstBlk_extprob(m,3) - lastBlk_extprob(m,2);
end

[h, p] = ttest(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
[p, h] = signrank(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1)])
for i = 1:8
    plot([1; 2], [btwnSessDiffs_bsln(i,1); btwnSessDiffs_ext(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Amp Beginning (sess n) - CR Amp End (sess n-1)')
% Negative values on y axis means that the animal did worse at the
% beginning of the subsequent session compared to the previous session
% (last block is higher than first block).
% Positive values on the y axis means that the animal did better at the
% beginning of the subsequent session compared to the previous session
% (last block is lower than first block).


[h, p] = ttest(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
[p, h] = signrank(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
%boxplot([btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1)])
for i = 1:8
    plot([1; 2], [btwnSessDiffs_bslnprob(i,1); btwnSessDiffs_extprob(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Prob Beginning (sess n) - CR Prob End (sess n-1)')
ylim([-1 1])

[h, p] = ttest([btwnSessDiffs_bsln(1,1);btwnSessDiffs_bsln(3:end,1)], [btwnSessDiffs_ext(1,1); btwnSessDiffs_ext(3:end,1)]);
[h, p] = ttest([btwnSessDiffs_bslnprob(1,1);btwnSessDiffs_bslnprob(3:end,1)], [btwnSessDiffs_extprob(1,1); btwnSessDiffs_extprob(3:end,1)]);

% biggest spontaneous recovery
figure
scatter(1:70, plotdata.crprob(2,:))
hold on
plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('CR Probability')
title(plotdata.mouse(2,1))

% biggest consolidation
figure
scatter(1:70, plotdata.crprob(6,:))
hold on
plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('CR Probability')
title(plotdata.mouse(6,1))

% median mouse
figure
scatter(1:70, plotdata.crprob(1,:))
hold on
plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('CR Probability')
title(plotdata.mouse(1,1))

% plot group performance: cradjamp
idx = ones(8,1);
idx(5,1) = 0;
groupdata = nanmean(plotdata.cradjamp(idx==1,:));
figure
scatter(1:70, groupdata)
hold on
plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('CR Amplitude')

% plot group performance: cr probability
idx = ones(8,1);
idx(5,1) = 0;
groupdata = nanmean(plotdata.crprob(idx==1,:));
groupsem = nanstd(plotdata.crprob(idx==1,:))./sum(~isnan(plotdata.crprob(idx==1,:)));
figure
errorbar([1:length(groupdata)],groupdata, groupsem, '.')
hold on
plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('CR Probability')

% plot animals changes between days
figure
hold on
for i = 1:size(btwnSessDev.crprob,2)
    if i ~= 2
        quantiles = quantile(btwnSessDev.crprob(:,i),3);
        plot([i-0.25 i+0.25], [quantiles(1) quantiles(1)], 'Color', [0 0 1])
        plot([i-0.25 i+0.25], [quantiles(3) quantiles(3)], 'Color', [0 0 1])
        plot([i-0.25 i+0.25], [quantiles(2) quantiles(2)], 'Color', [1 0 0])
        plot([i-0.25 i-0.25], [quantiles(1) quantiles(3)], 'Color', [0 0 1])
        plot([i+0.25 i+0.25], [quantiles(1) quantiles(3)], 'Color', [0 0 1])
        plot([i i], [quantiles(3) max(btwnSessDev.crprob(:,i))], 'Color', [0 0 1])
        plot([i i], [quantiles(1) min(btwnSessDev.crprob(:,i))], 'Color', [0 0 1])
    end
end

% plot individual animal changes between days
for i = 1:8
figure
scatter(1:6, [btwnSessDev.cradjamp(i,1),nan,btwnSessDev.cradjamp(i,3:6)])
hold on
plot([0.5 6.5], [0 0], 'LineStyle', '--', 'Color', [0 0 0])
ylabel('- consolidation, + spont rec')
ylim([-0.35 0.35])
title(btwnSessDev.mouse(i))
end

figure
boxplot(btwnSessDev.cradjamp)

clear btwnSessDiffs_bslnprob btwnSessDiffs_extprob btwnSessDiffs_bsln btwnSessDiffs_ext

%% try unpaired extinction but exclude the mice that had weak puffs for extinction

mice = {'S146';...
    'S147';...
    'S148';...
    'S149'};

starthere = 3131; % need to go through the array starting at the index for the first mouse listed. Mouse name list in mice and in the data array ordering must be the same.
for m = 1:length(mice)
    starthereOrig = starthere;
    
    mouseidx = [];
    while strcmpi(block10dat.mouse{starthere}, mice(m,1))
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(block10dat.mouse)
            break
        end
    end
    
    day = block10dat.day(mouseidx,1);
    cradjamp = block10dat.cradjamp(mouseidx,1);
    crprob = block10dat.crprob(mouseidx,1);
    sesstype = {};
    extidx = zeros(starthereOrig,1);
    for i = 1:length(mouseidx)
        sesstype = [sesstype; block10dat.sesstype{mouseidx(i),1}];
        if strcmpi(block10dat.sesstype{mouseidx(i),1}, 'extinction')
            extidx = [extidx; 1];
        else
            extidx = [extidx; 0];
        end
    end
    
    
    % we also want to take the blocks from the 2 preceeding days (only had
    % 2 day performance criterion, & extinction proceeds so rapidly that we
    % don't really want to include more than 2 days of extinction training
    % in the analysis)
    %       we are using the block 10 data, so we can expect that there
    %       will be 10 blocks/day (based on the way things were set up in
    %       the getDayData script) --> we want to include another 30 blocks
    %       back from where the first extidx is
    temp = find(extidx);
    startbaseline = temp(1) - 20;
    endbaseline = temp(1) - 1;
    
    bslnidx = zeros(length(mouseidx),1);
    bslnidx(startbaseline:endbaseline, 1) = 1;
    
    %% check CRAdjamp
    % plot the data to make sure things are looking reasonable
    plotme_bsln = block10dat.cradjamp(bslnidx==1);
    plotme_ext = block10dat.cradjamp(extidx==1);
    figure
    scatter(1:length(plotme_bsln), plotme_bsln)
    hold on
    scatter(21:length(plotme_ext)+20, plotme_ext)
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([70.5 70.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([80.5 80.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([90.5 90.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([100.5 100.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([110.5 110.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([120.5 120.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_ext)+21])
    ylim([0 1])
    ylabel('cradjamp')
    title(mice(m,1))
    pause
    
    if sum(isnan(plotme_ext))>0
        disp('NAN FOUND IN plotme_ext')
        pause
        % pause here to catch any nan's that made it into the extinction dataset. i
        % don't think there should have been any but just in case
    end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bsln(m, 1) = plotme_bsln(1,1);
    lastBlk_bsln(m, 1) = plotme_bsln(10,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 1) = plotme_bsln(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bsln(m, 2) = plotme_bsln(11,1);
    lastBlk_bsln(m, 2) = plotme_bsln(20,1);
    subtr = 1;
    while isnan(lastBlk_bsln(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bsln(m, 2) = plotme_bsln(20-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_ext(m, 1) = plotme_ext(1,1);
    lastBlk_ext(m, 1) = plotme_ext(10,1);
    firstBlk_ext(m, 2) = plotme_ext(11,1);
    lastBlk_ext(m, 2) = plotme_ext(20,1);
    firstBlk_ext(m, 3) = plotme_ext(21,1);
    lastBlk_ext(m, 3) = plotme_ext(30,1);
    
    btwnSessDiffs_bsln(m,1) = firstBlk_bsln(m,2) - lastBlk_bsln(m,1);
    btwnSessDiffs_ext(m,1) = firstBlk_ext(m,2) - lastBlk_ext(m,1);
    btwnSessDiffs_ext(m,2) = firstBlk_ext(m,3) - lastBlk_ext(m,2);
    
    %% repeat for CRProb
    % plot the data to make sure things are looking reasonable
    plotme_bslnprob = block10dat.crprob(bslnidx==1);
    plotme_extprob = block10dat.crprob(extidx==1);
    figure
    scatter(1:length(plotme_bslnprob), plotme_bslnprob)
    hold on
    scatter(21:length(plotme_extprob)+20, plotme_extprob)
    plot([10.5 10.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([20.5 20.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([30.5 30.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([40.5 40.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([50.5 50.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([60.5 60.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([70.5 70.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([80.5 80.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([90.5 90.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([100.5 100.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([110.5 110.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    plot([120.5 120.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    xlim([0 length(plotme_extprob)+21])
    ylim([0 1])
    ylabel('prob')
    title(mice(m,1))
    
%     if sum(isnan(plotme_extprob))>0
%         disp('NAN FOUND IN plotme_ext')
%         pause
%         % pause here to catch any nan's that made it into the extinction dataset. i
%         % don't think there should have been any but just in case
%     end
    
    % there are nans in the final baseline data blocks, maybe due to
    % squinting?
%     if sum(isnan(plotme_bsln))>0
%         disp('NAN FOUND IN plotme_bsln')
%         pause
%         % pause here to catch whether any nans made it into this part of
%         % the dataset. it is possible but unlikely at this point
%     end
    
    % Get the differences between performance in the first block and the
    % last block during baseline days and during extinction days.
    %       recall that each day has 10 blocks
    %       recall that the last block for a day might be a nan
    firstBlk_bslnprob(m, 1) = plotme_bslnprob(1,1);
    lastBlk_bslnprob(m, 1) = plotme_bslnprob(10,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,1)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 1) = plotme_bslnprob(10-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_bslnprob(m, 2) = plotme_bslnprob(11,1);
    lastBlk_bslnprob(m, 2) = plotme_bslnprob(20,1);
    subtr = 1;
    while isnan(lastBlk_bslnprob(m,2)) % this will break if all the data from the day are nans, but that shouldn't happen anyway so if it breaks here it will be something like a good catch for that problem in the dataset
        lastBlk_bslnprob(m, 2) = plotme_bslnprob(20-subtr,1);
        subtr = subtr+1;
    end
    
    firstBlk_extprob(m, 1) = plotme_extprob(1,1);
    lastBlk_extprob(m, 1) = plotme_extprob(10,1);
    firstBlk_extprob(m, 2) = plotme_extprob(11,1);
    lastBlk_extprob(m, 2) = plotme_extprob(20,1);
    firstBlk_extprob(m, 3) = plotme_extprob(21,1);
    lastBlk_extprob(m, 3) = plotme_extprob(30,1);
    
    btwnSessDiffs_bslnprob(m,1) = firstBlk_bslnprob(m,2) - lastBlk_bslnprob(m,1);
    btwnSessDiffs_extprob(m,1) = firstBlk_extprob(m,2) - lastBlk_extprob(m,1);
    btwnSessDiffs_extprob(m,2) = firstBlk_extprob(m,3) - lastBlk_extprob(m,2);
end

[h, p] = ttest(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
[p, h] = signrank(btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bsln, btwnSessDiffs_ext(:,1)])
for i = 1:4
    plot([1; 2], [btwnSessDiffs_bsln(i,1); btwnSessDiffs_ext(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Amp Beginning (sess n) - CR Amp End (sess n-1)')
% Negative values on y axis means that the animal did worse at the
% beginning of the subsequent session compared to the previous session
% (last block is higher than first block).
% Positive values on the y axis means that the animal did better at the
% beginning of the subsequent session compared to the previous session
% (last block is lower than first block).


[h, p] = ttest(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
[p, h] = signrank(btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1));
figure
plot([0 3], [0 0], '--', 'Color', [0.5 0.5 0.5])
hold on
boxplot([btwnSessDiffs_bslnprob, btwnSessDiffs_extprob(:,1)])
for i = 1:4
    plot([1; 2], [btwnSessDiffs_bslnprob(i,1); btwnSessDiffs_extprob(i,1)], '--o', 'Color', [0 0 0])
end
ylabel('CR Prob Beginning (sess n) - CR Prob End (sess n-1)')

[h, p] = ttest([btwnSessDiffs_bslnprob(1,1);btwnSessDiffs_bslnprob(3:end,1)], [btwnSessDiffs_extprob(1,1); btwnSessDiffs_extprob(3:end,1)]);


