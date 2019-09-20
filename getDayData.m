close all
clear all

%startdir = 'C:\olivia\data\savings chapter';
startdir = 'C:\Users\kimol\Documents\MATLAB';
cd(startdir)

load('190920_compiledTrialsForSavingsChapter.mat')

mousearray = getMouseInfo();

daydat.mouse = {};
daydat.day = [];
daydat.cradjamp = [];
daydat.crprob = [];
daydat.sesstype = {};

block20dat.mouse = {};
block20dat.day = [];
block20dat.cradjamp = [];
block20dat.crprob = [];
block20dat.sesstype = [];

block10dat.mouse = {};
block10dat.day = [];
block10dat.cradjamp = [];
block10dat.crprob = [];
block10dat.sesstype = [];

starthere = 1;

for m = 1:length(mousearray)
    
    mouseidx = [];
    while strcmpi(dat.mouse{starthere}, mousearray(m,1).name)
        mouseidx = [mouseidx;starthere];
        starthere = starthere+1;
        if starthere > length(dat.mouse)
            break
        end
    end
%     mouseidx = strfind(dat.mouse, mousearray(m,1).name);
%     mouseidx = find(cell2mat(mouseidx));
    
    eyelidpos = dat.eyelidpos(mouseidx,:);
    mouse = dat.mouse{mouseidx};
    csdur = dat.csdur(mouseidx,1);
    usdur = dat.usdur(mouseidx,1);
    isi = dat.isi(mouseidx,1);
    day = dat.day(mouseidx,1);
    lasdur = dat.lasdur(mouseidx,1);
    lasdel = dat.lasdel(mouseidx,1);
    lasfreq = dat.lasfreq(mouseidx,1);
    stable = dat.stable(mouseidx,1);
    cradjamp = dat.cradjamp(mouseidx,1);
    
    days = unique(day);
    
    for d = 1:length(days)
        dayidx = find(day==days(d));
        
        tdeyelidpos = eyelidpos(dayidx,:);
        tdcsdur = csdur(dayidx,:);
        tdusdur = usdur(dayidx,:);
        tdisi = isi(dayidx,:);
        tdlasdur = lasdur(dayidx,:);
        tdlasfreq = lasfreq(dayidx,:);
        tdlasdel = lasdel(dayidx,:);
        tdstable = stable(dayidx,:);
        tdcradjamp = cradjamp(dayidx,:);
       
        numtrials = sum(tdstable & tdcsdur>0);
        numcrs = sum(tdstable & tdcsdur>0 & tdcradjamp>=0.1);
        crprob = numcrs./numtrials;
        meancradjamp = mean(tdcradjamp(tdstable & tdcsdur>0));
        
        daydat.mouse = [daydat.mouse; mousearray(m,1).name];
        daydat.day = [daydat.day; days(d)];
        daydat.cradjamp = [daydat.cradjamp; meancradjamp];
        daydat.crprob = [daydat.crprob; crprob];
        
        if strcmpi(mousearray(m,1).name, 'OK007') && days(d) == 150402
            sesstype = 'extinction'; % see notes; basically there was a problem with neuroblinks that day so I unplugged the puffer to get extinction trials
        elseif  strcmpi(mousearray(m,1).name, 'OK008') && days(d) == 150402
            sesstype = 'extinction'; % see notes; basically there was a problem with neuroblinks that day so I unplugged the puffer to get extinction trial
        elseif sum(tdcsdur>0 & tdusdur>0)>0
            sesstype = 'training';
        elseif sum(tdcsdur>0 & tdusdur>0)==0
            sesstype = 'extinction';
        end
        
        daydat.sesstype = [daydat.sesstype; sesstype];
        
        %% get blocked data
        
        % block 20
        cstrials = 
        blockbeg = 1;
        blockend = 20;
        for b = 1:5
            addme = (b-1)*20;
            tbbeg = blockbeg + addme;
            tbend = blockend + addme;
            if b == 5
                tbend = length(
            end
        end
        
        % block 10
        
        clear numtrials numcrs crprob meancradjamp tdeyelidpos tdcsdur...
            tdusdur tdisi tdlasdur tdlasfreq tdlasdel tdstable tdcradjamp...
            sesstype mouseidx
    end
    
end

save('190920_compiledForSavingsChapter_dayData.mat', 'daydat')


