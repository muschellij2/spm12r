function [] = rest_bandpass(ADataDir, ...
							ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, ...
							AAddMeanBack, ...
							AMaskFilename)
%Ideal Band pass filter for REST by Xiao-Wei Song
% rest_bandpass(ADataDir, ...
% 							ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, ...
% 							AAddMeanBack, ...
% 							AMaskFilename)
% Use Ideal rectangular filter to filter a 3d+time dataset
% Input:
% 	ADataDir			where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
% 	ASamplePeriod		TR, or like the variable name
% 	ALowPass_HighCutoff			low pass, high cutoff of the band, eg. 0.08
% 	AHighPass_LowCutoff			high pass,  low cutoff of the band, eg. 0.01
%	AAddMeanBack			'Yes' or 'No'. 	if yes, then add the mean back after filtering
% 	AMaskFilename		the mask file name, compatible with old reho or reho_gui, can be 'Default' or 1, '' or 0, 'mask.mat', '../mask.img'
% Output:
%	 Create a new sibling-directory with ADataDir, and name as 'ADataDir_filtered', then put all filted images to the new sibling-directory
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%-----------------------------------------------------------
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">SONG Xiao-Wei</a>; <a href="ycg.yan@gmail.com">YAN Chao-Gan</a> 
%	Version=1.4;
%	Release=20100420;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Revised by YAN Chao-Gan, 090321. Data in processing will not be converted to the format 'int16'.
%   Revised by YAN Chao-Gan, 090919. Data will be saved in single format.
%   Last Revised by YAN Chao-Gan, 100420. Fixed a bug in calculating the frequency band. And now will not remove the linear trend in bandpass filter (as fourier_filter.c in AFNI), but just save the mean and can add the mean back after filtering.


	if nargin~=6, help('rest_bandpass');error(' Error using ==> rest_bandpass. 6 arguments wanted.'); end
    	
	tic;
	fprintf('\nIdeal rectangular filter:\t"%s"', ADataDir);
	[AllVolume,vsize,theImgFileList, Header,nVolumn] =rest_to4d(ADataDir);

    thePrecision ='single';%'double'; %Revised by YAN Chao-Gan, 090321. Data will not be converted to the format 'int16'. %thePrecision ='int16';
    tmpData =double(squeeze(AllVolume(:, :, :, round(size(AllVolume, 4)/2))));
	if mean(abs(tmpData(0~=tmpData)))<100,	%I can't use mean because It use too much memory!
		thePrecision ='single';%'double';
	end
	% examine the dimensions of the functional images and set mask 
	nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3);
	isize = [nDim1 nDim2 nDim3]; 
		
	%20070512	Saving a big 3D+time Dataset to small pieces by its first dimension to make this process run at least
	% put pieces of 4D dataset to the temp dir determined by the current time
	theTempDatasetDirName =sprintf('BandPass_%d_%s', fix((1e4) *rem(now, 1) ),rest_misc('GetCurrentUser'));	
	theTempDatasetDir =[tempdir theTempDatasetDirName] ;
	ans=rmdir(theTempDatasetDir, 's');%suppress the error msg
	mkdir(tempdir, theTempDatasetDirName);	%Matlab 6.5 compatible
	
	Save1stDimPieces(theTempDatasetDir, AllVolume, 'dim1_');
	clear AllVolume;%Free large memory

	%mask selection, added by Xiaowei Song, 20070421
	fprintf('\n\t Load mask "%s".', AMaskFilename);	
	mask=rest_loadmask(nDim1, nDim2, nDim3, AMaskFilename);
	
	fprintf('\n\t Build band pass filtered mask.\tWait...');
	sampleFreq 	 = 1/ASamplePeriod; 
	sampleLength =nVolumn;
	paddedLength = rest_nextpow2_one35(sampleLength); %2^nextpow2(sampleLength);
	%paddedLength =sampleLength; %Don't pad any zero
	freqPrecision= sampleFreq/paddedLength;
	if rest_misc( 'GetMatlabVersion')<7.3
		warning off MATLAB:conversionToLogical;	
	end
	mask =logical(mask);%Revise the mask to ensure that it contain only 0 and 1	
	if rest_misc( 'GetMatlabVersion')<7.3
		warning on MATLAB:conversionToLogical;
	end
	maskLowPass =	repmat(mask, [1, 1, 1, paddedLength]);
	maskHighPass=	maskLowPass;
	clear mask;
	%% GENERATE LOW PASS WINDOW	20070514, reference: fourier_filter.c in AFNI
    %http://afni.nimh.nih.gov/afni/doc/source/fourier__filter_8c-source.html
    %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band.
	if (ALowPass_HighCutoff>=(sampleFreq/2))||(ALowPass_HighCutoff==0)		
		maskLowPass(:,:,:,:)=1;	%All pass
	elseif (ALowPass_HighCutoff>0)&&(ALowPass_HighCutoff< freqPrecision)		
		maskLowPass(:,:,:,:)=0;	% All stop
	else
		% Low pass, such as freq < 0.08 Hz
		idxCutoff	=round(ALowPass_HighCutoff *paddedLength *ASamplePeriod + 1); % Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %idxCutoff	=round(ALowPass_HighCutoff *paddedLength *ASamplePeriod);
		idxCutoff2	=paddedLength+2 -idxCutoff;				%Center Index =(paddedLength/2 +1)
		%maskLowPass(:,:,:,1:idxCutoff)=1;			%Low pass, contain DC
		maskLowPass(:,:,:,idxCutoff+1:idxCutoff2-1)=0; %High eliminate
		%maskLowPass(:,:,:,idxCutoff2:paddedLength)=1;	%Low pass
	end
	%%GENERATE HIGH PASS WINDOW
	if (round(AHighPass_LowCutoff *paddedLength *ASamplePeriod) == 0) %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %if (AHighPass_LowCutoff < freqPrecision)	
		maskHighPass(:,:,:,:)=1;	%All pass
	elseif (AHighPass_LowCutoff >= (sampleFreq/2))
		maskHighPass(:,:,:,:)=0;	% All stop
	else
		% high pass, such as freq > 0.01 Hz
		idxCutoff	=round(AHighPass_LowCutoff *paddedLength *ASamplePeriod + 1); % Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %idxCutoff	=round(AHighPass_LowCutoff *paddedLength *ASamplePeriod);
		idxCutoff2	=paddedLength+2 -idxCutoff;				%Center Index =(paddedLength/2 +1)
		maskHighPass(:,:,:,1:idxCutoff-1)=0;	%Low eliminate
		%maskHighPass(:,:,:,idxCutoff:idxCutoff2)=1;	%High Pass
		maskHighPass(:,:,:,idxCutoff2+1:paddedLength)=0;	%Low eliminate
	end	
	%Combine the low pass mask and the high pass mask
	%maskLowPass(~maskHighPass)=0; %Don't combine because filter will not work when I only want low-pass or high-pass after combination, 20070517
	%Save mask pieces to disk to make this program at least run
	Save1stDimPieces(theTempDatasetDir, maskLowPass, 'fmLow_');	
	Save1stDimPieces(theTempDatasetDir, maskHighPass, 'fmHigh_');	
	clear maskLowPass maskHighPass; %Free large memory
	
% 	%20070513	remove trend --> FFT --> filter --> inverse FFT --> retrend 
    % YAN Chao-Gan, 100401. remove the mean --> FFT --> filter --> inverse FFT --> add mean back
	if rest_misc( 'GetMatlabVersion')>=7.3
		fftw('dwisdom');		
	else		
	end	
	fprintf('\n\t Band Pass Filter working.\tWait...');		
	NumPieces_Dim1 =4;	%Constant number to divide the first dimension to "NumPieces_Dim1" pieces
	NumComputingCount =floor(nDim1/NumPieces_Dim1);
	if NumComputingCount< (nDim1/NumPieces_Dim1),
		NumComputingCount =NumComputingCount +1;
	else
	end
	for x=1:(NumComputingCount),
		rest_waitbar(x/(floor(nDim1/NumPieces_Dim1) +1), ...
					'wait...', ...
					'Filter is working','Child','NeedCancelBtn');
	
% 		%%Remove the linear trend first, ref: fourier_filter.c in AFNI, 20070509
% 		%Get every slope and intercept within the mask
        % YAN Chao-Gan 100401, now will not remove the linear trend in bandpass filter.
		theFilename =fullfile(theTempDatasetDir, sprintf('dim1_%.8d', x));
		theDim1Volume4D =Load1stDimVolume(theFilename);
		theDim1Volume4D =double(theDim1Volume4D);
				
% 		%Save the linear trend
        % YAN Chao-Gan 100401, now will not remove the linear trend in bandpass filter, but just save the mean.
% 		theTrend_Intercept=theDim1Volume4D(:,:,:, 1);
% 		theTrend_Slope= (theDim1Volume4D(:,:,:, end) -theTrend_Intercept) /double(sampleLength-1);
        theMean=mean(theDim1Volume4D,4);
% 		for y=1:sampleLength
% 			%remove the linear trend first
% 			theDim1Volume4D(:,:,:, y)=theDim1Volume4D(:,:,:, y) -(theTrend_Intercept + y*theTrend_Slope);
%         end
% 		Remove the mean. YAN Chao-Gan 100401.
        theDim1Volume4D=theDim1Volume4D-repmat(theMean,[1,1,1, sampleLength]);
		theDim1Volume4D =cat(4,theDim1Volume4D,zeros(size(theDim1Volume4D,1),nDim2,nDim3,paddedLength -sampleLength));	%padded with zero
		
		%FFT	
		theDim1Volume4D =fft(theDim1Volume4D, [], 4);
		%Low-pass Filter mask
		theFilename =fullfile(theTempDatasetDir, sprintf('fmLow_%.8d', x));
		theDim1FilterMask4D =Load1stDimVolume(theFilename);	        
		%Apply the filter Low Pass
		theDim1Volume4D(~theDim1FilterMask4D)=0;
		
		%High-pass Filter mask
		theFilename =fullfile(theTempDatasetDir, sprintf('fmHigh_%.8d', x));
		theDim1FilterMask4D =Load1stDimVolume(theFilename);	        
		%Apply the filter High Pass
		theDim1Volume4D(~theDim1FilterMask4D)=0;
		
		%inverse FFT
		theDim1Volume4D =ifft(theDim1Volume4D, [], 4);
		theDim1Volume4D =theDim1Volume4D(:,:,:, 1:sampleLength);%remove the padded parts
        %YAN Chao-Gan 100401, now will not remove the linear trend in bandpass filter, but just save the mean and then add back after filter.
% 		%retrend the time course
% 		if strcmpi(ARetrend, 'Yes')
% 			for y=1:sampleLength
% 				%add the linear trend after filter
% 				theDim1Volume4D(:,:,:, y)=theDim1Volume4D(:,:,:, y) +double(theTrend_Intercept+y*theTrend_Slope);
% 			end
% 		end	
        % Add the mean back after filter.
        if strcmpi(AAddMeanBack, 'Yes')
            theDim1Volume4D=theDim1Volume4D+repmat(theMean,[1,1,1, sampleLength]);
        end
		%theDim1Volume4D =uint16(round(theDim1Volume4D));
		
		%Save to file
		theFilename =fullfile(theTempDatasetDir, sprintf('result_%.8d', x));		
		save(theFilename, 'theDim1Volume4D'); 		
		fprintf('.');
	end
	%clear theDim1Volume4D theTrend_Intercept theTrend_Slope theDim1FilterMask4D;
    clear theDim1Volume4D theMean theDim1FilterMask4D;
	
	%Construct the 3D+time Dataset from files again
	fprintf('\n\t ReConstructing 3D+time Dataset.\tWait...');
    %YAN Chao-Gan, 090919
	%theDataset4D=zeros(nDim1, nDim2, nDim3, sampleLength);
    theDataset4D=single(zeros(nDim1, nDim2, nDim3));
    theDataset4D =repmat(theDataset4D, [1,1,1, sampleLength]);
	for x=1:(NumComputingCount)
		rest_waitbar(x/(floor(nDim1/NumPieces_Dim1)+1), ...
					'wait...', ...
					'After filter','Child','NeedCancelBtn');
					
		theFilename =fullfile(theTempDatasetDir, sprintf('result_%.8d', x));
		%fprintf('\t%d',x);% Just for debugging
		if x~=(floor(nDim1/NumPieces_Dim1)+1)
			theDataset4D(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:,:)=single(Load1stDimVolume(theFilename));
		else
			theDataset4D(((x-1)*NumPieces_Dim1+1):end,:,:,:)=single(Load1stDimVolume(theFilename));
		end		
		fprintf('.');
	end
	
	%Save all images to disk
	fprintf('\n\t Saving filtered images.\tWait...');
	if strcmp(ADataDir(end),filesep)==1
		ADataDir=ADataDir(1:end-1);
	end	
	theResultOutputDir =sprintf('%s_filtered',ADataDir);
	ans=rmdir(theResultOutputDir, 's');%suppress the error msg	
% 	[theParentDir,theOutputDirName]=fileparts(theResultOutputDir);	
% 	mkdir(theParentDir, theOutputDirName);	%Matlab 6.5 compatible
    mkdir(theResultOutputDir); %YAN Chao-Gan, 110911. For Matlab future release compatible.
    
	
	%theDataset4D =uint16(theDataset4D);	%20071031 revised! Dawnwei.Song
	for x=1:sampleLength
		rest_waitbar(x/sampleLength, ...
					sprintf('Saving to {hdr/img} pair files\nwait...'), ...
					'Filter Over','Child','NeedCancelBtn');
		rest_writefile(single(theDataset4D(:, :, :, x)), ...
			sprintf('%s_filtered%s%.8d', ADataDir, filesep,x), ...
			isize,vsize,Header, 'single');  %Revised by YAN Chao-Gan, 090321. Filtered data will be stored in 'single' format. %thePrecision);
		if (mod(x,5)==0) %progress show
			fprintf('.');
		end
	end	    	
	fprintf('\n\t Band pass filter over.\n\t');
	toc;

	%After Band pass filter, remove the temporary files
	ans=rmdir(theTempDatasetDir, 's');%suppress the error msg

%Save the 1st dimension of the 4D dataset to files	
function Save1stDimPieces(ATempDir, A4DVolume, AFilenamePrefix)
	NumPieces_Dim1 =4;	%Constant number to divide the first dimension to "NumPieces_Dim1" pieces
	NumComputingCount =floor(size(A4DVolume,1)/NumPieces_Dim1);
	if NumComputingCount< (size(A4DVolume,1)/NumPieces_Dim1),
		NumComputingCount =NumComputingCount +1;
	else
	end
	for x = 1:(NumComputingCount)
		rest_waitbar(x/(floor(size(A4DVolume,1)/NumPieces_Dim1)+1), ...
					'wait...', ...
					'Before Filter','Child','NeedCancelBtn');
		theFilename =fullfile(ATempDir, sprintf('%s%.8d',AFilenamePrefix, x));
		if x~=(floor(size(A4DVolume,1)/NumPieces_Dim1)+1)
			the1stDim = A4DVolume(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1), :,:,:);
		else
			the1stDim = A4DVolume(((x-1)*NumPieces_Dim1+1):end, :,:,:);
		end
		save(theFilename, 'the1stDim'); 		
	end	
	
%Load the 1st dimension of the 4D dataset from files, return a Matrix not a struct
function Result=Load1stDimVolume(AFilename)	
	Result =load(AFilename);
	theFieldnames=fieldnames(Result);	
	% Result =eval(sprintf('Result.%s',the1stField));%remove the struct variable to any named variable with a matrix
	Result = Result.(theFieldnames{1});

