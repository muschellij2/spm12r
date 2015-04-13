function [nVolume]=rest_CheckDataDir(ADataDir)
% function [nVolume]=rest_CheckDataDir(ADataDir)
% Check the Volume number of a Data Directory
%Input:
%   ADataDir: where the 3d+time dataset stay
%Output:
%   nVolume: the number of volume;
%___________________________________________________________________________
% By YAN Chao-Gan 110911, Based on a subfunction of REST GUI.
% ycg.yan@gmail.com

theFilenames = dir(ADataDir);
theHdrFiles=dir(fullfile(ADataDir,'*.hdr'));
theImgFiles=dir(fullfile(ADataDir,'*.img'));
if ~length(theHdrFiles)==length(theImgFiles)
    nVolume =-1;
    fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);
    errordlg('*.{hdr,img} should be pairwise. Please re-examin them.');
    return;
end

if strcmpi(theFilenames(3).name,'.DS_Store')  %1109011 YAN Chao-Gan, for MAC OS compatablie
    StartIndex=4;
else
    StartIndex=3;
end
nVolume = 0;
for count = StartIndex:size(struct2cell(theFilenames),2)
    if	(length(theFilenames(count).name)>4) && ...
            strcmpi(theFilenames(count).name(end-3:end) , '.hdr')
        if strcmpi(theFilenames(count).name(1:end-4) ...                %hdr
                , theFilenames(count+1).name(1:end-4) )     %img
            nVolume = nVolume + 1;
        else
            %error('*.{hdr,img} should be pairwise. Please re-examin them.');
            nVolume =-1;
            fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);
            errordlg('*.{hdr,img} should be pairwise. Please re-examin them.');
            break;
        end
    else % add the nii file support DONG 110817  and nii.gz  DONG 111112
        if (length(theFilenames(count).name)>4)
			if (strcmpi(theFilenames(count).name(end-3:end) , '.nii') || strcmpi(theFilenames(count).name(end-2:end), '.gz'))
				imageNii=[ADataDir,filesep,theFilenames(count).name];
				N=rest_ReadNiiNum(imageNii);
				nVolume = nVolume + N;
			end
        end
    end	% end 110817
end
