function [] = rest_RegressOutCovariates(ADataDir,ACovariablesDef,APostfix,AMaskFilename)
% FORMAT rest_RegressOutCovariates(ADataDir,ACovariablesDef,APostfix,AMaskFilename)
% Input:
%   ADataDir - where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
%   ACovariablesDef - A struct which defines the coviarbles.
%                 ACovariablesDef.polort - The order of the polynomial which adding to baseline model according to 3dfim+.pdf. Recommend: 1.
%                 ACovariablesDef.ort_file - The filename of the text file which contains the covaribles.
%   APostfix - Post fix of the resulting data directory. e.g. '_Covremoved'
% Output:
%   *.img/hdr - data removed the effect of covariables.
%___________________________________________________________________________
% By YAN Chao-Gan 080610 for DPARSF, based on fc.m.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if nargin<4
    AMaskFilename='';
end


[AllVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(ADataDir);

% AllVolume=double(AllVolume); %YAN 110505


% examin the dimensions of the functional images and set mask
nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3); nDim4 =size(AllVolume,4);
sampleLength =nVolumn;

fprintf('\n\t Load mask "%s".', AMaskFilename);	
		mask=rest_loadmask(nDim1, nDim2, nDim3, AMaskFilename);
		
		fprintf('\n\t Build mask.\tWait...');
		mask =logical(mask);%Revise the mask to ensure that it contain only 0 and 1	
		mask =	repmat(mask, [1, 1, 1, sampleLength]);	
AllVolume=AllVolume.*mask;
theCovariables =[];
if exist(ACovariablesDef.ort_file, 'file')==2,
    theCovariables =load(ACovariablesDef.ort_file);
    %Add polynomial in the baseline model according to 3dfim+.pdf
    thePolOrt=[];
    if ACovariablesDef.polort>=0,
        thePolOrt =(1:sampleLength)';
        thePolOrt =repmat(thePolOrt, [1, (1+ACovariablesDef.polort)]);
        for x=1:(ACovariablesDef.polort+1),
            thePolOrt(:, x) =thePolOrt(:, x).^(x-1) ;
        end
    end
    theCovariables =[thePolOrt, theCovariables];

elseif ~isempty(ACovariablesDef.ort_file) && ~all(isspace(ACovariablesDef.ort_file)),
    warning(sprintf('\n\nCovariables definition text file "%s" doesn''t exist, please check! I won''t regress out the covariables this time.', ACovariablesDef.ort_file));
end

for x=1:nDim1,
    rest_waitbar(x/nDim1, ...
        'Regressing Out Covariables, wait...', ...
        'Regressing Out Covariables','Child','NeedCancelBtn');
    
    oneAxialSlice =double(AllVolume(x, :, :, :));
    oneAxialSlice =Brain4D_RegressOutCovariables(oneAxialSlice, theCovariables);
    AllVolume(x, :, :, :) =(oneAxialSlice);
end;

if strcmp(ADataDir(end),filesep)==1,
    ADataDir=ADataDir(1:end-1);
end

ADataDir =sprintf('%s%s',ADataDir,APostfix); %YAN 110505. ADataDir =sprintf('%s%s',ADataDir,strcat('_',APostfix));
ans=rmdir(ADataDir, 's');%suppress the error msg
[theParentDir,theOutputDirName]=fileparts(ADataDir);
mkdir(theParentDir,theOutputDirName);	%Matlab 6.5 compatible

for x=1:sampleLength,
    rest_waitbar(x/sampleLength, ...
        sprintf('Saving to {hdr/img} pair files\nwait...'), ...
        'Regressing Out Covariables','Child','NeedCancelBtn');
    rest_writefile(AllVolume(:, :, :, x), ...
        sprintf('%s%s%.8d', ADataDir, filesep,x), ...
        [nDim1,nDim2,nDim3],VoxelSize, Header,'double');
    if (mod(x,5)==0) %progress show
        fprintf('.');
    end
end
fprintf('\n');






function Result =Brain4D_RegressOutCovariables(ABrain4D, ABasisFunc)
%20070926, Regress some covariables out first	
	%Result =( E - X(X'X)~X')Y
	[nDim1, nDim2, nDim3, nDim4]=size(ABrain4D);
	
	%Make sure the 1st dim of ABasisFunc is nDim4 long
	if size(ABasisFunc,1)~=nDim4, error('The length of Covariables don''t match with the volume.'); end
	
	% (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)
	ABrain4D =reshape(ABrain4D, nDim1*nDim2*nDim3, nDim4)';
	Result =(eye(nDim4) - ABasisFunc * inv(ABasisFunc' * ABasisFunc)* ABasisFunc') * ABrain4D;
	%20071102 Bug fixed squeeze must not be excluded because nDim1 may be ONE !!!
	%Result =squeeze(reshape(Result', nDim1, nDim2, nDim3, nDim4));
	Result =reshape(Result', nDim1, nDim2, nDim3, nDim4);

function Result =Brain1D_RegressOutCovariables(ABrain1D, ABasisFunc)
%20070926, Regress some covariables out first	
	%Result =( E - X(X'X)~X')Y
	%Make sure the input is a column vector
	% ABrain1D =reshape(ABrain1D, prod(size(ABrain1D)), 1);
	
	%Make sure the 1st dim of ABasisFunc is nDim4 long
	if size(ABasisFunc,1)~=length(ABrain1D), error('The length of Covariables don''t match with the volume.'); end
	
	% (1*sampleLength) A matrix * B matrix (sampleLength * VoxelCount)	
	Result =(eye(size(ABrain1D, 1)) - ABasisFunc * inv(ABasisFunc' * ABasisFunc)* ABasisFunc') * ABrain1D;
	
    
