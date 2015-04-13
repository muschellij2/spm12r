function rest_detrend (ADataDir, APostfix , CUTNUMBER)
%Removing the linear trend for REST by Xiao-Wei Song
%Usage: rest_detrend(ADataDir, APostfix)
%ADataDir			where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
%------------------------------------------------------------------------------------------------------------------------------
% Remove linear trend 
% Save to ADataDir_APostfix	
%
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
% Dawnwei.Song@gmail.com, Copyright 2007~2010
%------------------------------------------------------------------------------------------------------------------------------
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.3;
%	Release=20090321;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Last Revised by YAN Chao-Gan, 090321. Data in processing will not be converted to the format 'int16'.
%   Last Revised by Sandy Wang, 120719. Saving and loading pieces has been removed.
    
    tic;
	fprintf(['\nRemoving the linear trend: ',ADataDir,'\n']);
    if ~exist('CUTNUMBER','var')
        CUTNUMBER = 10;
    end
	[AllVolume,VoxelSize,theImgFileList, Header] =rest_to4d(ADataDir);

	%thePrecision ='double'; %Revised by YAN Chao-Gan, 090321. Data will not be converted to the format 'int16'. %thePrecision ='int16';
    %tmpData =double(squeeze(AllVolume(:, :, :, round(size(AllVolume, 4)/2))));
	%if mean(abs(tmpData(0~=tmpData)))<100,	%I can't use mean because It use too much memory!
	%	thePrecision ='double';
	%end
	
	% examin the dimensions of the functional images and set mask 
	nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3); nDimTimePoint =size(AllVolume,4);
		
	%Change by Sandy Wang to increase detrend speed
    AllVolume=reshape(AllVolume,[],nDimTimePoint)';
    theMean=mean(AllVolume);
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    fprintf('\n\t Detrend working.\tWait...');
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
    
        AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
    
        fprintf('.');
    end
    %AllVolume=detrend(AllVolume);
    AllVolume=AllVolume+repmat(theMean,[nDimTimePoint,1]);
    AllVolume=reshape(AllVolume',[nDim1, nDim2, nDim3, nDimTimePoint]);
    % I have to create a for loop because detrend can support 2-dim at most
	%for x=1:nDim1,
	%	%rest_waitbar(x/nDim1, ...
	%	%		'Removing Linear Trend, wait...', ...
	%	%		'Detrend','Child','NeedCancelBtn');			
	%	
	%	%oneAxialSlice =double(AllVolume(x, :, :, :));
	%	%oneAxialSlice =reshape(oneAxialSlice, 1*nDim2*nDim3, nDimTimePoint)';
	%	%oneAxialSlice =detrend(oneAxialSlice) +repmat(mean(oneAxialSlice), [size(oneAxialSlice,1), 1]);
	%	%oneAxialSlice =reshape(oneAxialSlice', 1,nDim2,nDim3, nDimTimePoint);
	%	if strcmpi(thePrecision, 'int16'),
	%		AllVolume(x, :, :, :) =uint16(oneAxialSlice);
	%	else
	%		AllVolume(x, :, :, :) =(oneAxialSlice);
	%	end
	%	
	%	% dim3PlusTimeCourse =squeeze( AllVolume(x, :, :, :) );
	%	% theTimeCourse =double(dim3PlusTimeCourse'); %detrend only can do along the column, before detrend
	%	% dim3PlusTimeCourse =detrend(theTimeCourse);
	%	% dim3PlusTimeCourse =dim3PlusTimeCourse + ...
	%				% repmat(mean(theTimeCourse), [size(dim3PlusTimeCourse,1), 1]);
	%	% dim3PlusTimeCourse =dim3PlusTimeCourse'; %detrend only can do along the column, go back
	%	%% AllVolume(x, y, :, :) =uint16(dim3PlusTimeCourse);	%20071031, Dawnwei.Song revised!
	%	% if strcmpi(thePrecision, 'int16'),
	%		% AllVolume(x, :, :, :) =uint16(dim3PlusTimeCourse);
	%	% else
	%		% AllVolume(x, :, :, :) =(dim3PlusTimeCourse);
	%	% end
		
	%end;

	%if strcmp(ADataDir(end),filesep)==1,
	%	ADataDir=ADataDir(1:end-1);
	%end	
	
	%ADataDir =sprintf('%s%s',ADataDir,APostfix);
	%ans=rmdir(ADataDir, 's');%suppress the error msg	
% 	[theParentDir,theOutputDirName]=fileparts(ADataDir);	
% 	mkdir(theParentDir, theOutputDirName);	%Matlab 6.5 compatible	
    %mkdir(ADataDir); %YAN Chao-Gan, 110911. For Matlab future release compatible.
	
	%sampleLength =nVolumn;
	%Save 4D nii Sandy Wang 20120518
    fprintf('\n\n\t Saving detrended images.\tWait...');
    if strcmp(ADataDir(end),filesep)==1
        ADataDir=ADataDir(1:end-1);
    end
    
    theResultOutputDir =sprintf('%s%s',ADataDir,APostfix);

    ans=rmdir(theResultOutputDir, 's');%suppress the error msg
    mkdir(theResultOutputDir); %YAN Chao-Gan, 110911. For Matlab future release compatible.


    Header_Out = Header;
    Header_Out.pinfo = [1;0;0];
    Header_Out.dt    =[16,0];


    rest_Write4DNIfTI(AllVolume,Header_Out,sprintf('%s%sdetrend_4DVolume.nii', theResultOutputDir ,filesep));

fprintf('\n\t Detrend over.\n\t');
toc;
    
    %for x=1:sampleLength,
	%	rest_waitbar(x/sampleLength, ...
	%				sprintf('Saving to {hdr/img} pair files\nwait...'), ...
	%				'Remove linear trend Over','Child','NeedCancelBtn');
	%	rest_writefile(single(AllVolume(:, :, :, x)), ...
	%		sprintf('%s%s%.8d', ADataDir, filesep,x), ...
	%		[nDim1,nDim2,nDim3],VoxelSize, Header,'single'); %Revised by YAN Chao-Gan, 090321. Detrended data will be stored in 'single' format. %'int16');
	%	if (mod(x,5)==0) %progress show
	%		fprintf('.');
	%	end
	%end	  