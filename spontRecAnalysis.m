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



% NEED TO GO THROUGH AND GET DAILY BLOCK DATA
starthere = 1;
for m = 1:length(mice)
    
    mouseidx = [];
    while strcmpi(block10dat.mouse{starthere}, mice(m,1))
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(block10dat.mouse)
            break
        end
    end
    
    day = block10dat.day(mouseidx,1);
    cradjamp = block10dat.day(mouseidx,1);
    crprob = block10dat.day(mouseidx,1);
    sesstype = {};
    extidx = zeros(length(mouseidx),1);
    for i = 1:length(mouseidx)
        sesstype = [sesstype; block10dat.sesstype{mouseidx(i),1}];
        if strcmpi(block10dat.sesstype{mouseidx(i),1}, 'extinction')
            extidx(mouseidx(i),1) = 1;
        end
    end
    
    plotme = block10dat.cradjamp(extidx==1);
    figure
    scatter(1:length(plotme), plotme)
    hold on
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
    xlim([0 length(plotme)+1])
    ylim([0 1])
    
    
end