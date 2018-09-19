

%%%%%%%%%%%%%%%%%%%% LICENCE TEXT %%%%%%%%%%%%%%%%%%%%%%%%%%
% This program remove_silence.m is part of the MATLAB Speaker Diarization Toolkit 
% <https://github.com/parthe/Speaker-Diarization-toolkit-MATLAB>
% Copyright (C) 2015 Parthe Pandit
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or 
% any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%% LICENCE TEXT %%%%%%%%%%%%%%%%%%%%%%%%%%
 


tic
S = MFCC{1};

E = S(:,1); 
[~,energy_sort_d] = sort(E,'descend');
sp = S(energy_sort_d(1:round(length(S)*.2)),:);
energy_sort_a = flipud(energy_sort_d);
nsp = S(energy_sort_a(1:round(length(S)*.2)),:);
nG.nnG = 8;     nG.snG = 8;
[~,Msp] = evalc('GMM_matlab2cluster(GMM_MSR2matlab(gmm_em({transpose(sp)},nG.snG,10,1,12)))');
[~,Mnsp] = evalc('GMM_matlab2cluster(GMM_MSR2matlab(gmm_em({transpose(nsp)},nG.nnG,10,1,12)))');

I_old = length(sp);
J_old = length(nsp);
percent_change = 100;
counter = 0;
while(percent_change > 1)
    counter = counter + 1;
    LLsp = GMClassLikelihood(Msp,S);
    LLnsp = GMClassLikelihood(Mnsp,S);

    % Variable J is dedicated to storing indices of frames classified as
    % non-speech. Variable I for storing indices of frames classified as speech
    I = find(LLsp > LLnsp);
    J = find(LLnsp > LLsp);
    sp = S(I,:);
    nsp = S(J,:);
    nG.nnG = 16;     nG.snG = 32;
    [~,Msp] = evalc('GMM_matlab2cluster(GMM_MSR2matlab(gmm_em({transpose(sp)},nG.snG,10,1,4)))');
    [~,Mnsp] = evalc('GMM_matlab2cluster(GMM_MSR2matlab(gmm_em({transpose(nsp)},nG.nnG,10,1,4)))');

    I_new = length(I);
    J_new = length(J);
    percent_change = abs((I_new - I_old)/I_old)*100;
%         disp(['counter = ' num2str(counter) '  ' num2str(percent_change) '%change'] );
    I_old = I_new;
    J_old = J_new;
end

% save('G:\Parthe\Dropbox\Acads\DDP\Demo\silence_removal_LL','LLsp','LLnsp')
save([file_path  'Output_files' filesep filename filesep 'silence_removal_LL'],'LLsp','LLnsp')
% Continuity constraint
min_length = 100;
L = LLsp - LLnsp;
[J_start,J_stop] = SAD_boolind2array(L<0,min_length);

% save('G:\Parthe\Dropbox\Acads\DDP\Demo\silence_removal_1000ms','J_start','J_stop')
save([file_path 'Output_files' filesep filename filesep 'silence_removal_1000ms'],'J_start','J_stop')
disp(['Silence removal complete. Time taken = ' num2str(toc)])
