function rest_NormalityTest(ADataDir,Method,AResultFilename,AMaskFilename)
% NormalityTest
% ADataDir:          The set of data (.img, .hdr) that rest_NormalityTest import
%
% Method:            We suggest users to view MATLAB "help" for Lilliefors and
%                    Jarque-Bera goodness-of-fit tests. In rest_NormalityTest, Method = 1, Lilliefors test
%                    function will be applied; else Jarque-Bera test will functio will be applied.
%
% AResultFilename:   AResultFilename will be a combination of the raw data
%                    name and the Method name.
%
% AMaskFilename:     The brain mask (e.g. 61*73*61 mask file) that rest_NormalityTest applied before computing. 

% Output: p value map (Normally distributed if p is larger than a threshold)
%_________________________________________________________________
% Zang Zhen-Xiang (zangzx416@sina.com); Dong Zhang-Ye (dongzy08@gmail.com);
% 2011-12-18

	theElapsedTime =cputime;
	fprintf('\nComputing with:\t"%s"', ADataDir);
    [AllVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(ADataDir);
	% examin the dimensions of the functional images and set mask 
	nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3);
	BrainSize = [nDim1 nDim2 nDim3]; 
	sampleLength = nVolumn;
    
    if Method ==1,
       AResultFilename=[AResultFilename,'_','Lilliefors'];
    else
        AResultFilename=[AResultFilename,'_','JB'];
    end
	
	%20070512	Saving a big 3D+time Dataset to small pieces by its first dimension to make this process run at least
	% put pieces of 4D dataset to the temp dir determined by the current time
	theTempDatasetDirName =sprintf('Norm_%d_%s', fix((1e4) *rem(now, 1) ),rest_misc('GetCurrentUser'));	
	theTempDatasetDir =[tempdir theTempDatasetDirName] ;
	ans=rmdir(theTempDatasetDir, 's');%suppress the error msg
	mkdir(tempdir, theTempDatasetDirName);	%Matlab 6.5 compatible
		
		%Save 3D+time Dataset's pieces to disk after ROI time course retrieved
		Save1stDimPieces(theTempDatasetDir, AllVolume, 'dim1_');
		clear AllVolume;%Free large memory
		
		%mask selection, added by Xiaowei Song, 20070421
		fprintf('\n\t Load mask "%s".', AMaskFilename);	
		mask=rest_loadmask(nDim1, nDim2, nDim3, AMaskFilename);
		
		fprintf('\n\t Build mask.\tWait...');
		mask =logical(mask);%Revise the mask to ensure that it contain only 0 and 1	
		mask =	repmat(mask, [1, 1, 1, sampleLength]);	
		%Save mask pieces to disk to make this program at least run
		Save1stDimPieces(theTempDatasetDir, mask, 'mask_');	


		fprintf('\n\t Normality is computing.\tWait...');		
	    NumPieces_Dim1 =4;	%Constant number to divide the first dimension to "NumPieces_Dim1" pieces
		NumComputingCount =floor(nDim1/NumPieces_Dim1);
		if NumComputingCount< (nDim1/NumPieces_Dim1),
			NumComputingCount =NumComputingCount +1;
		else
		end
		for x=1:(NumComputingCount),	%20071129
		%for x=1:(floor(nDim1/NumPieces_Dim1) +1)
			rest_waitbar(x/(floor(nDim1/NumPieces_Dim1) +1), ...
						'Performing Normality Tests. Please wait...', ...
						'REST working','Child','NeedCancelBtn');
						
			%Load cached pieces of Datasets
			theFilename =fullfile(theTempDatasetDir, sprintf('dim1_%.8d', x));
			theDim1Volume4D =Load1stDimVolume(theFilename);
			theDim1Volume4D =double(theDim1Volume4D);
					
			%Load and Apply the pieces' mask
			theFilename =fullfile(theTempDatasetDir, sprintf('mask_%.8d', x));
			theDim1Mask4D =Load1stDimVolume(theFilename);
			theDim1Volume4D(~theDim1Mask4D)=0;
               
             ResultNormalityBrain=rest_Normality(theDim1Volume4D,Method);
				
				%Save to file
				theFilename =fullfile(theTempDatasetDir, sprintf('result%.2d_%.8d', x));		
				save(theFilename, 'ResultNormalityBrain');
			end
			fprintf('.');
		clear theDim1Volume4D   theDim1Mask4D	ResultNormalityBrain;
		
		%Construct the 3D+time Dataset from files again
		fprintf('\n\t ReConstructing 3D Dataset.\tWait...');
		%Construct the Normality map's filenames, 20070905
% 		[pathstr, name, ext, versn] = fileparts(AResultFilename);
% 		ResultMaps =[];
% 		ResultMaps =[ResultMaps;{[pathstr, filesep ,name, ext]}];
		%Reconstruct the Result correlation map from pieces
			theDataset3D=zeros(nDim1, nDim2, nDim3);
			for x=1:(NumComputingCount)
				rest_waitbar(x/(floor(nDim1/NumPieces_Dim1)+1), ...
							'3D Brain reconstructing. Please wait...', ...
							'REST working','Child','NeedCancelBtn');
				
				theFilename =fullfile(theTempDatasetDir,sprintf('result%.2d_%.8d', x));
				%fprintf('\t%d',x);% Just for debugging
				if x~=(floor(nDim1/NumPieces_Dim1)+1),
					theDataset3D(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:)=Load1stDimVolume(theFilename);
				else
					theDataset3D(((x-1)*NumPieces_Dim1+1):end,:,:)=Load1stDimVolume(theFilename);
				end		
				fprintf('.');
			    
				fprintf('\n\t Saving Normality map.\tWait...');	
				rest_writefile(single(theDataset3D), ...
					AResultFilename, ...
					BrainSize,VoxelSize,Header, 'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');
		end%end for	
	

	theElapsedTime =cputime - theElapsedTime;
	fprintf('\n\t Normality compution over, elapsed time: %g seconds.\n', theElapsedTime);
	

	%After Band pass filter, remove the temporary files
	ans=rmdir(theTempDatasetDir, 's');%suppress the error msg
%end

%Save the 1st dimension of the 4D dataset to files
function Save1stDimPieces(ATempDir, A4DVolume, AFilenamePrefix)
    NumPieces_Dim1 =4;	%Constant number to divide the first dimension to "NumPieces_Dim1" pieces
	NumComputingCount =floor(size(A4DVolume,1)/NumPieces_Dim1);
	if NumComputingCount< (size(A4DVolume,1)/NumPieces_Dim1),
		NumComputingCount =NumComputingCount +1;
	else
	end
	for x = 1:(NumComputingCount),
	%for x = 1:(floor(size(A4DVolume,1)/NumPieces_Dim1)+1)
		rest_waitbar(x/(floor(size(A4DVolume,1)/NumPieces_Dim1)+1), ...
					'Cut one Big 3D+time Dataset into pieces of 3D+time Dataset. Please wait...', ...
					'REST working','Child','NeedCancelBtn');
					
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

%Normality Tests
function ResultNormalityBrain=rest_Normality(ABrain4D,Method);
	[nDim1, nDim2, nDim3, nDim4]=size(ABrain4D);
    ABrain4D=reshape(ABrain4D,nDim1*nDim2*nDim3,nDim4);
    A=zeros(nDim1*nDim2*nDim3,1);
	%Remove the mean
    for i=1:nDim1*nDim2*nDim3,
        T=ABrain4D(i,:);
        if var(T)~=0,
           if Method==1,
              [h,p]=lillietest(T);
           else
              [h,p]=jbtest(T); 
           end
        A(i,:)=p;
        else A(i,:)=0;
        end
    end
	ResultNormalityBrain=reshape(A,nDim1,nDim2,nDim3);
	