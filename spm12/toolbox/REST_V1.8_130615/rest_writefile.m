function [] = rest_writefile(data,filename,isize,vsize,Header,dtype)
%Write ANALYZE 7.5 or NIFTI file by YAN Chao-Gan
% FORMAT function [] = rest_writefile(data,filename,isize,vsize,dtype)
%              data  - data file.   
%           filename - Analyze or NIFTI file (*.{hdr, img, nii})
%              isize - the size of the data
%              vsize - the size of the voxel
%              dtype - the data type.
%             Header - It will decide to write ANALYZE7.5 or NIFTI file by
%                      whether Header has the field 'mat'.
%                      Analyze format - Header just has one subfield: Header.Origin - the origin of the images.
%                      NIFTI format   -   Head.fname - the filename of the image.
%                                         Head.dim   - the x, y and z dimensions of the volume
%                                         Head.dt    - A 1x2 array.  First element is datatype (see spm_type).
%                                                      The second is 1 or 0 depending on the endian-ness. (must)
%                                         Head.mat   - a 4x4 affine transformation matrix mapping from
%                                                      voxel coordinates to real world coordinates. (must)
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
%	Version=1.3;
%	Release=20080420;
%   Revised by YAN Chao-Gan 080807: The NIFTI images would be saved in RPI coordination as the same as SPM5 usually did.
%   Revised by YAN Chao-Gan, 090420. rest_WriteAnalyzeImage.m only recognize 'float', thus change the parameter 'single' to 'float'.
%   Revised by YAN Chao-Gan, 100225. Check if vsize is a 1 by 3 array.
%   Last Revised by YAN Chao-Gan, 100814. No longer need to change to RPI before writing.  
%-----------------------------------------------------------

if isfield(Header,'mat')
    switch lower(dtype)
        case 'uint32'
            datatype = 768;
        case 'uint16'
            datatype = 512;
        case 'int8'
            datatype = 256;
        case {'float64','double'}
            datatype = 64;
        case {'float32','single'}
            datatype = 16;
        case 'int32'
            datatype = 8;
        case 'int16'
            datatype = 4;
        case 'uint8'
            datatype = 2;
        otherwise % need to add other decription
            error('unsupported data format now.');
    end
    
%   YAN Chao-Gan, 100814. No longer need to change to RPI before writing.  
%     if Header.mat(1,1)>0 %The NIFTI images would be saved in RPI coordination as the same as SPM5 usually did. YAN Chao-Gan 080807 % <0 % I'd like to save the file in LPI coordination. Chaogan Yan 080610
%         data = flipdim(data,1);
%         Header.mat(1,:) = -1*Header.mat(1,:);
%     end
%     if Header.mat(2,2)<0
%         data = flipdim(data,2);
%         Header.mat(2,:) = -1*Header.mat(2,:);
%     end
%     if Header.mat(3,3)<0
%         data = flipdim(data,3);
%         Header.mat(3,:) = -1*Header.mat(3,:);
%     end   
    
    Header.dt    =[datatype,0];
    Header.vox   =vsize;
    Header.dim   =isize;
    Header.pinfo = [1;0;0];
    rest_WriteNiftiImage(data,Header,filename);
else
    if strcmp(dtype,'single')
        dtype='float';  %Revised by YAN Chao-Gan, 090420. rest_WriteAnalyzeImage.m only recognize 'float', thus change the parameter 'single' to 'float'.
    end
    if strcmpi(num2str(size(vsize)),'3  1')
        vsize=vsize';   %Revised by YAN Chao-Gan, 100225. Check if vsize is a 1 by 3 array.
    end
    rest_WriteAnalyzeImage(data,filename,isize,vsize,Header.Origin,dtype);
end
    
    