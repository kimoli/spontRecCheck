close all
clear all

% get data for all days each mouse
mouse = getMouseInfo();
basedir = 'L:\users\okim\behavior';
basedir_alt = 'L:\users\okim\data';

dat.eyelidpos = [];
dat.mouse = {};
dat.csdur = [];
dat.usdur = [];
dat.isi = [];
dat.day = [];
dat.lasdur = [];
dat.lasdel = [];
dat.lasfreq = [];

for m = 1:length(mouse)
   tempstring = mouse(m,1).name;
   goMouse = [basedir,'\',tempstring];
   try
       cd(goMouse)
   catch ME
       goMouse = [basedir_alt,'\',tempstring];
       cd(goMouse)
   end
   disp(['Fetching data from ', tempstring])
   
   days = dir('1*');
   for d = 1:length(days)
       tempstring = days(d,1).name;
       goDay = [goMouse, '\', tempstring];
       cd(goDay)
       
       disp(['...Fetching data from ', tempstring])
       if exist('trialdata.mat', 'file')==2
           load('trialdata.mat')
           dat.eyelidpos = [dat.eyelidpos; trials.eyelidpos];
           dat.csdur = [dat.csdur; trials.c_csdur];
           dat.usdur = [dat.usdur; trials.c_usdur];
           dat.isi = [dat.isi; trials.c_isi];
           
           thisDay = str2num(tempstring);
           tempday = ones(length(trials.c_csdur),1);
           tempday = tempday * thisDay;
           dat.day = [dat.day; tempday];
           
           temp = cell(length(trials.c_csdur),1);
           [temp{:}] = deal(mouse(m,1).name);
           dat.mouse = [dat.mouse; temp];
           
           if isfield('trials', 'laser')
               dat.lasdur = [dat.lasdur; trials.laser.dur];
               dat.lasdel = [dat.lasdel; trials.laser.delay];
               dat.lasfreq = [dat.lasfreq; trials.laser.freq];
           else
               tempzeros = zeros(length(trials.c_csdur),1);
               dat.lasdur = [dat.lasdur; tempzeros];
               dat.lasdel = [dat.lasdel; tempzeros];
               dat.lasfreq = [dat.lasfreq; tempzeros];
               clear tempzeros
           end
           
           clear temp tempday thisDay
       end
   end
end


stable = nan(length(dat.mouse),1);
cradjamp = nan(length(dat.mouse),1);
for i = 1:length(dat.mouse)
    baseline = mean(dat.eyelidpos(i, 1:40));
    if max(dat.eyelidpos(i, 1:40))>0.3
        stable(i,1) = 0;
    else
        stable(i,1) = 1;
    end
    usbin = (dat.isi(i,1)/5) + 40;
    cramp = max(dat.eyelidpos(i, usbin-3:usbin)); % max eyelid position in the 20ms before puff is delivered
    cradjamp(i,1) = cramp - baseline;
    
end

dat.stable = stable;
dat.cradjamp = cradjamp;

savedir = 'C:\olivia\data\savings chapter';
cd(savedir)
save('190920_compiledTrialsForSavingsChapter.mat', 'dat')
