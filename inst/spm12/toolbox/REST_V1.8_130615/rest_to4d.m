function [AllVolume, VoxelSize, ImgFileList, Header, nVolumn] =rest_to4d(ADataDir)
%Build a 4D matrix for REST from series of Brain's volume/(time point). By Xiao-Wei Song
%------------------------------------------------------------------------------------------------------------------------------
% Input:
%     ADataDir  -  The informatino of the dataset, could be:
%                  1. The directory of 3D image data 
%                  2. The filename of one 4D data file
%                  3. a Cell (nFile * 1 cells) of filenames of 3D image data
% Output:
%     AllVolume    - The 4D data matrix (DimX*DimY*DimZ*DimTimePoints)
%     VoxelSize    - The voxel size
%     ImgFileList  - The list of files of image data
%     Header       - The header information of NIfTI image
%     nVolumn      - The number of volumns
%___________________________________________________________________________
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song
%	http://resting-fmri.sourceforge.net
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a>
%	Version=1.3;
%	Release=20090321;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Revised by YAN Chao-Gan, 090321. Data in processing will not be converted to the format 'int16'.
%   Revised by YAN Chao-Gan, 091001. If data has too huge or too many volumes, then it will be loaded into memory in 'single' format.
%   Revised by DONG Zhang-ye, 110817. add 3d/4d *.nii file support, add two funcitons 'Construct4DVolume' for construct the 4D volume and 'initAllvolume' to initialize the 4D volume, add an output: nVolume just for the estimation to the sample length.
%   Revised by YAN Chao-Gan, 111111. Add the support for .nii.gz files.
%   Revised by YAN Chao-Gan, 120119. Also support one 4d file other than a directory.
%   Last revised by YAN Chao-Gan, 120217. Also support a cell of image filenames

if iscell(ADataDir)  ||  (~iscell(ADataDir)&&isdir(ADataDir))
    if iscell(ADataDir) % YAN Chao-Gan, 120217. Also support a cell of image filenames
        if size(ADataDir,1)==1
            ADataDir=ADataDir';
        end
        ImgFileList = ADataDir;
        nVolumn = length(ADataDir);
        ADataDir='';
    else
        theFileList = dir(ADataDir);
        ImgFileList ={};
        nVolumn=0; % add counter
        for x = 3:size(struct2cell(theFileList),2)
            if (length(theFileList(x).name)>4) && strcmpi(theFileList(x).name(end-3:end), '.hdr')
                if strcmpi(theFileList(x).name(1:end-4), theFileList(x+1).name(1:end-4))
                    ImgFileList=[ImgFileList; {theFileList(x).name}];
                    nVolumn = nVolumn + 1; % add counter
                else
                    error('*.{hdr,img} should be pairwise. Please re-examin them.');
                end
            else % add *.nii file support DONG 110817
                if ((length(theFileList(x).name)>4) && strcmpi(theFileList(x).name(end-3:end) , '.nii')) || ...
                        ((length(theFileList(x).name)>7) && strcmpi(theFileList(x).name(end-6:end) , '.nii.gz')) %YAN Chao-Gan, 120525. Fixed a bug for file name length.

                    imageNii=[ADataDir,filesep,theFileList(x).name];
                    N=rest_ReadNiiNum(imageNii);
                    nVolumn = nVolumn + N;
                    ImgFileList=[ImgFileList; {theFileList(x).name}];
                end
            end
        end
        clear theFileList;
        
%         if nVolumn <10,
%             warning('There are too few time points.(i.e. The number of the time points is less than 10)');
%         end
        
        %read the normalized functional images
        % -------------------------------------------------------------------------
        fprintf('\n\t Read 3D EPI functional images: "%s".', ADataDir);
    end
    
    
    theDataType ='double';	%Default data-type I assumed!
    
    readVolume=0;% record the current volume in the cycle
%     rest_waitbar(0.001, ...
%         ImgFileList{1}, ...
%         'Build 3D+time Dataset','Child','NeedCancelBtn');   % initialize the waiting bar,
    for x = 1:size(ImgFileList,1),
        theFilename = fullfile(ADataDir,ImgFileList{x});
        
        if (length(theFilename)>4) && (strcmpi(theFilename(end-3:end), '.hdr') || strcmpi(theFilename(end-3:end), '.img'))
            [theOneTimePoint, VoxelSize, Header] = rest_readfile(theFilename);
            if readVolume==0
                [AllVolume,theDataType]=initAllvolume(theOneTimePoint,nVolumn);
                AllVolume =repmat(AllVolume, [1,1,1, nVolumn]);
            else
                if theDataType=='uint16',
                    AllVolume(:,:,:,x) = uint16(theOneTimePoint);
                elseif	theDataType=='single',
                    AllVolume(:,:,:,x) = single(theOneTimePoint);
                elseif	theDataType=='double',
                    AllVolume(:,:,:,x) = (theOneTimePoint);
                else
                    rest_misc('ComplainWhyThisOccur');
                end
            end
            readVolume=readVolume+1;
        else % add *.nii file support
            if ((length(theFilename)>4) && strcmpi(theFilename(end-3:end) , '.nii')) || ...
                    ((length(theFilename)>7) && strcmpi(theFilename(end-6:end) , '.nii.gz')) %YAN Chao-Gan, 120525. Fixed a bug for file name length.
                [theOneNiiFileTimePoint, VoxelSize, Header] = rest_readfile(theFilename, 'all');
                N = size(theOneNiiFileTimePoint, 4);
                if readVolume==0
                    [AllVolume,theDataType]=initAllvolume(theOneNiiFileTimePoint,nVolumn);
                    AllVolume =repmat(squeeze(AllVolume(:,:,:,1)), [1,1,1, nVolumn]);
                end
                if	theDataType=='single'
                    theOneNiiFileTimePoint=single(theOneNiiFileTimePoint);
                end
                %AllVolume=cat(4,AllVolume,theOneNiiFileTimePoint);
                AllVolume(:,:,:,readVolume+1:readVolume+N) = theOneNiiFileTimePoint;
                readVolume=readVolume+N;
            end
        end
%         rest_waitbar(readVolume/nVolumn, ...
%             ImgFileList{x}, ...
%             'Build 3D+time Dataset','Child','NeedCancelBtn');
        
        if ~mod(x,5)
            fprintf('.');
        end
    end
    VoxelSize = VoxelSize';
    fprintf('\n');
    
else % YAN Chao-Gan, 120119. Also support one 4d file other than a directory.
    fprintf('\n\t Read images: "%s".', ADataDir);
    
    [AllVolume, VoxelSize, Header] = rest_readfile(ADataDir);
    ImgFileList=ADataDir;
    nVolumn=size(AllVolume,4);
end



function [AllVolume,theDataType]=initAllvolume(theOneTimePoint,nVolumn)
%To initialize the AllVolume
%110819 DONG
AllVolume=theOneTimePoint;
theDataType ='double';
Size_AllVolume=size(AllVolume);
if prod([Size_AllVolume(1:3), nVolumn,8])>1024*1024*1024 % YAN Chao-Gan 091001, If data is with two many volumes, then it will be converted to the format 'single'.
    theDataType ='single';
    AllVolume=single(AllVolume);
end



