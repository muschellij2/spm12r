 function [Outdata,VoxDim,Header]=rest_readfile(imageIN,volumeIndex)
% Read file(ANALYZE 7.5, NIFTI, ...) for REST by YAN Chao-Gan
% FORMAT function [Outdata,VoxDim,Header]=rest_readfile(imageIN,volumeIndex)
%                 filename - Analyze file (*.{hdr, img, nii})
%                 volumeIndex - the volume index for 4D NIfTI file. Default: 'all' means read all the volumes.
%                 Outdata  - data file.                            
%                 VoxDim   - the size of the voxel.
%                 Header   - It's decided by the format of data file:
%                            for ANALYZE 7.5 - Header.Origin - the origin of the image;
%                            for NIFTI  - Head.fname - the filename of the image.
%                                         Head.dim   - the x, y and z dimensions of the volume
%                                         Head.dt    - A 1x2 array.  First element is datatype (see spm_type).
%                                                      The second is 1 or 0 depending on the endian-ness.
%                                         Head.mat   - a 4x4 affine transformation matrix mapping from
%                                                      voxel coordinates to real world coordinates.
%                                         Head.pinfo - plane info for each plane of the volume.
%                                         Head.pinfo(1,:) - scale for each plane
%                                         Head.pinfo(2,:) - offset for each plane
%                                                      The true voxel intensities of the jth image are given
%                                                      by: val*Head.pinfo(1,j) + Head.pinfo(2,j)
%                                         Head.pinfo(3,:) - offset into image (in bytes).
%                                                     If the size of pinfo is 3x1, then the volume is assumed
%                                                     to be contiguous and each plane has the same scalefactor
%                                                     and offset.
%                                         Head.private - a structure containing complete information in the 
%                                                     header
%                                         Header.Origin - the origin of the image;
%-----------------------------------------------------------
%	Copyright(c) 2008~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by YAN Chao-Gan
%	http://resting-fmri.sourceforge.net
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.2;
%	Release=20080926;
%   Revised by YAN Chao-Gan 080926, fixed the bug when process ANALYZE format data.
%   Revised by YAN Chao-Gan, 111111. Add the support for .nii.gz files.
%   Last Revised by YAN Chao-Gan, 120814. Default format is .nii, and then .img if the former doesn't exist.
%-----------------------------------------------------------
if ~exist('volumeIndex', 'var')
    volumeIndex='all';
end

[pth,nam,ext] = fileparts(imageIN);
switch ext
    case {'.img','.hdr'}
        hname = fullfile(pth,[nam '.hdr']);
    case {'.nii'}
        hname = fullfile(pth,[nam '.nii']);
    case {'.gz'}  % YAN Chao-Gan, 111111. Add the support for .nii.gz files.
        gunzip(imageIN);
        hname = fullfile(pth,[nam]);
    otherwise
        hname = fullfile(pth,[nam '.nii']);
        if ~exist(hname,'file')
            hname = fullfile(pth,[nam '.hdr']);
        end
end;

if ~exist(hname,'file')
    error(['File doesn''t exist: ',hname]);
end

fp  = fopen(hname,'r','native');
if(fp>0)
    fseek(fp,344,'bof');
    mgc = deblank(char(fread(fp,4,'uint8')'));
    fclose(fp);   %YAN Chao-Gan 080926, fixed the bug when process ANALYZE format data.
    switch mgc
        case {'ni1','n+1'}
            [Outdata,Header]= rest_ReadNiftiImage(hname,volumeIndex);
            if (length(imageIN)>7) && strcmpi(imageIN(end-6:end), '.nii.gz')  %YAN Chao-Gan, 111111. Delete the uncompressed version after reading for .nii.gz file. %YAN Chao-Gan, 120525. Fixed a bug for file name length.
                delete(hname);
            end
            
            if sum(sum(Header.mat(1:3,1:3)-diag(diag(Header.mat(1:3,1:3)))~=0))==0 % If image has been normalized (no non-diagnol element), then transform to RPI coordination. %YAN Chao-Gan, 101013
                if Header.mat(1,1)>0 % Because the Song's former edition use the radiology convention, So I treat all the Img and Head in RPI coordination. Chaogan Yan 080610
                    Outdata = flipdim(Outdata,1);
                    Header.mat(1,:) = -1*Header.mat(1,:);
                end
                if Header.mat(2,2)<0
                    Outdata = flipdim(Outdata,2);
                    Header.mat(2,:) = -1*Header.mat(2,:);
                end
                if Header.mat(3,3)<0
                    Outdata = flipdim(Outdata,3);
                    Header.mat(3,:) = -1*Header.mat(3,:);
                end
            end
            temp=inv(Header.mat)*[0,0,0,1]';
            Header.Origin=temp(1:3)';
            %VoxDim=abs([Header.mat(1,1),Header.mat(2,2),Header.mat(3,3)]);
            VoxDim = sqrt(sum(Header.mat(1:3,1:3).^2)); %YAN Chao-Gan, 111127. Change the way to calculate voxel size.
        otherwise
            [Outdata,VoxDim,Origin]= rest_ReadAnalyzeImage(imageIN);
            Header.Origin=Origin;
            VoxDim=VoxDim'; %YAN Chao-Gan, 100420. Change the VoxDim to a row.
    end;
else
    error(sprintf('Error opening header file. Please check whether the %s file exist.',hname));
    fclose(fp);  %YAN Chao-Gan 080926, fixed the bug when process ANALYZE format data.
end
%fclose(fp);  %YAN Chao-Gan 080926, fixed the bug when process ANALYZE format data.