function [start_frame,stop_frame] = SAD_boolind2array(array,min_size)
 



%%%%%%%%%%%%%%%%%%%% LICENCE TEXT %%%%%%%%%%%%%%%%%%%%%%%%%%
% This program SAD_boolind2array.m is part of the MATLAB Speaker Diarization Toolkit 
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
 


    if (nargin < 2)
        min_size = 0;
    end
    
    start_frame = [];
    stop_frame = [];
    
%     nsp = zeros(length(array),1);
%     nsp(array) = 1;
    nsp = array;
    nsp_diff = diff(nsp);
    
    start_frame = find(nsp==1,1);
    stop_frame = find(nsp_diff==-1,1);
    temp = nsp_diff(stop_frame+1:end);
    old_temp = nsp_diff;
    while (~isequal(old_temp,temp) && ~isempty(find(temp==1,1)))
        old_temp = temp;
        start_frame = [start_frame ; 1 + stop_frame(end) + find(temp==1,1)];
        temp2 = nsp_diff(start_frame(end):end);
        stop_frame = [stop_frame ; start_frame(end) + find(temp2==-1,1) - 1];
        temp = nsp_diff(stop_frame(end)+1:end);
    end
%     stop_frame = [stop_frame ; array(end)];
    if (length(start_frame) - length(stop_frame) == 1)
        stop_frame = [stop_frame; length(nsp)];
    elseif (length(start_frame) - length(stop_frame) == 0)
%         disp('All OK. No correction needed')
    else
        disp('Error in Enforce Continuity. Needs URGENT Attention !')
        disp(length(start_frame) - length(stop_frame))
        return
    end
    ind = find((stop_frame - start_frame) < min_size);
%     disp([stop_frame start_frame stop_frame-start_frame])
    start_frame(ind) = [];
    stop_frame(ind) = [];
end