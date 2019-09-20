close all
clear all

startdir = 'C:\Users\kimol\Documents\MATLAB';
cd(startdir)
load('190920_compiledForSavingsChapter_dayData.mat')
load('190920_compiledTrialsForSavingsChapter.mat')

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
for m = 1:length(mice)
    starthere = 1;
    mouseidx = [];
    while strcmpi(dat.mouse{starthere}, mousearray(m,1).name)
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(dat.mouse)
            break
        end
    end
end