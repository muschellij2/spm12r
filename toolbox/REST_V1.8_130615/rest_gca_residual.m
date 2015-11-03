function [ResultMap1,ResultMap2,ResultMap3,ResultMap4,ResultMap5] = rest_gca_residual(DataDir,AMaskFilename, AROIDef,AResultFilename, ACovariablesDef,Order)
% Granger Causality Analysis on Residual
% AROIList would be treated as a mask in which time courses would be averaged to produce a new time course representing the ROI area
% Input:
% 	DataDir			where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
% 	AMaskFilename		the mask file name, I only compute the point within the mask
% 	AROIList		the mask list , ROI list definition
%	AResultFilename		the output filename
%	ACovariablesDef
%   Order: the number of time points that needed to be deleted  
% Output:
%	AResultFilename	the filename of GCA result
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Zhenxiang Zang 
%	http://www.restfmri.net
%-----------------------------------------------------------
% 	Mail to Authors:  <a href="zangzx416@gmail.com">Zhenxiang Zang</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%   Revised by ZANG Zhen-Xiang, 110504. Provides a method that could transform the residual-based F into normally distributed Z score.


	theElapsedTime =cputime;
	fprintf('\nComputing GCA with:\t"%s"',DataDir);
	[AllVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(DataDir);
	% examin the dimensions of the functional images and set mask 
	nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3);nDim4 = size(AllVolume,4);
	BrainSize = [nDim1 nDim2 nDim3]; 
	sampleLength = nVolumn;%sampleLength = 230
	
	%20070512	Saving a big 3D+time Dataset to small pieces by its first dimension to make this process run at least
	% put pieces of 4D dataset to the temp dir determined by the current time
	theTempDatasetDirName =sprintf('GCA_%d_%s', fix((1e4) *rem(now, 1) ),rest_misc('GetCurrentUser'));%fc_creattime
	theTempDatasetDir =[tempdir theTempDatasetDirName] ;
	ans=rmdir(theTempDatasetDir, 's');%suppress the error msg
	mkdir(tempdir, theTempDatasetDirName);	%Matlab 6.5 compatible
	
	AROIList =AROIDef;	
	if iscell(AROIDef),	%ROI wise, compute corelations between regions	
		%ROI time course retrieving, 20070903	
		theROITimeCourses =zeros(sampleLength, size(AROIDef,1));
		for x=1:size(AROIDef,1),
			fprintf('\n\t ROI time courses retrieving through "%s".', AROIDef{x});				
			IsDefinedROITimeCourse =0;
			if rest_SphereROI( 'IsBallDefinition', AROIDef{x})
				%The ROI definition is a Ball definition
				maskROI =rest_SphereROI( 'BallDefinition2Mask' , AROIDef{x}, BrainSize, VoxelSize, Header);
			elseif exist(AROIDef{x},'file')==2	% Make sure the Definition file exist
				[pathstr, name, ext] = fileparts(AROIDef{x});
				if strcmpi(ext, '.txt'),
					tmpX=load(AROIDef{x});
					if size(tmpX,2)>1,
						%Average all columns to make sure tmpX only contain one column
						tmpX = mean(tmpX')';
					end
					theROITimeCourses(:, x) =tmpX;
					IsDefinedROITimeCourse =1;
				elseif strcmpi(ext, '.img') || strcmpi(ext, '.nii') || strcmpi(ext, '.nii.gz')   %elseif strcmpi(ext, '.img')
					%The ROI definition is a mask file
					maskROI =rest_loadmask(nDim1, nDim2, nDim3, AROIDef{x});		
				else
					error(sprintf('REST doesn''t support the selected ROI definition now, Please check: \n%s', AROIDef{x}));
				end
			else
				error(sprintf('Wrong ROI definition, Please check: \n%s', AROIDef{x}));
			end
			
			if ~IsDefinedROITimeCourse,% I need retrieving the ROI averaged time course manualy
				maskROI =find(maskROI);
				% [rangeX, rangeY, rangeZ] = ind2sub(size(maskROI), find(maskROI));
				% theTimeCourses =zeros(length(unique(rangeX)), length(unique(rangeY)), length(unique(rangeZ)));	
				for t=1:sampleLength,
					theTimePoint = squeeze(AllVolume(:,:,:, t));
					theTimePoint = theTimePoint(maskROI);
					if ~isempty(theTimePoint),
						theROITimeCourses(t, x) =mean(theTimePoint);
					end
				end	%The Averaged Time Course within the ROI now comes out! 20070903				
			end%if ~IsDefinedROITimeCourse
		end%for
		%Save the ROI averaged time course to disk for further study
		[pathstr, name, ext] = fileparts(AResultFilename);
		theROITimeCourseLogfile =[fullfile(pathstr,['ROI_', name]), '.txt'];
		save(theROITimeCourseLogfile, 'theROITimeCourses', '-ASCII', '-DOUBLE','-TABS')
		
		%If there are covariables
        theCovariables =[];
		if exist(ACovariablesDef.ort_file, 'file')==2,
			theCovariables =load(ACovariablesDef.ort_file);
        else
            theCovariables=ones(nDim4,1);
        end
		
		
		%Calcute the corelation matrix and save to a text file
        if size(theROITimeCourses,2)~=2,
           error ('Two ROI series needed. Please recheck');
        else
           [ResultMap1,ResultMap2,ResultMap3,ResultMap4,ResultMap5] = restgca_FROI(theROITimeCourses,Order,theCovariables);
        end
        AResultFilename1 = [AResultFilename,sprintf('result_x2y')];
        AResultFilename2 = [AResultFilename,sprintf('result_y2x')];
        AResultFilename3 = [AResultFilename,sprintf('result_x2y_transformed')];
        AResultFilename4 = [AResultFilename,sprintf('result_y2x_transformed')];
        AResultFilename5 = [AResultFilename,sprintf('result_NetFx2y')];
        save([AResultFilename1, '.txt'], 'ResultMap1', '-ASCII', '-DOUBLE','-TABS');
        save([AResultFilename2, '.txt'], 'ResultMap2', '-ASCII', '-DOUBLE','-TABS');
        save([AResultFilename3, '.txt'], 'ResultMap3', '-ASCII', '-DOUBLE','-TABS');
        save([AResultFilename4, '.txt'], 'ResultMap4', '-ASCII', '-DOUBLE','-TABS');
        save([AResultFilename5, '.txt'], 'ResultMap5', '-ASCII', '-DOUBLE','-TABS');
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	 
	else		%Voxel wise, compute corelations between one ROI time course and the whole brain
		%ROI time course retrieving, 20070903	
		fprintf('\n\t ROI time course retrieving through "%s".', AROIDef);		
		AROITimeCourse = zeros(sampleLength, 1);
		IsDefinedROITimeCourse =0;
		if rest_SphereROI( 'IsBallDefinition', AROIDef)
			%The ROI definition is a Ball definition
			maskROI =rest_SphereROI( 'BallDefinition2Mask' , AROIDef, BrainSize, VoxelSize, Header);
		elseif exist(AROIDef,'file')==2	% Make sure the Definition file exist
			[pathstr, name, ext] = fileparts(AROIDef);
			if strcmpi(ext, '.txt'),
				tmpX=load(AROIDef);
				if size(tmpX,2)>1,
					%Average all columns to make sure tmpX only contain one column
					tmpX = mean(tmpX')';
				end
				AROITimeCourse =tmpX;
				IsDefinedROITimeCourse =1;
			elseif strcmpi(ext, '.img')
				%The ROI definition is a mask file
				maskROI =rest_loadmask(nDim1, nDim2, nDim3, AROIDef);		
			else
				error(sprintf('REST doesn''t support the selected ROI definition now, Please check: \n%s', AROIDef));
			end
		else
			error(sprintf('Wrong ROI definition, Please check: \n%s', AROIDef));
		end
		if ~IsDefinedROITimeCourse,% I need retrieving the ROI averaged time course manualy
			maskROI =find(maskROI);
			% [rangeX, rangeY, rangeZ] = ind2sub(size(maskROI), find(maskROI));
			% theTimeCourses =zeros(length(unique(rangeX)), length(unique(rangeY)), length(unique(rangeZ)));	
			for t=1:sampleLength,
				theTimePoint = squeeze(AllVolume(:,:,:, t));
				theTimePoint = theTimePoint(maskROI);
				AROITimeCourse(t) =mean(theTimePoint);
			end	%The Averaged Time Course within the ROI now comes out! 20070903
			%Make sure the ROI averaged time course is an col vector
			AROITimeCourse =reshape(AROITimeCourse, sampleLength,1);
		end
		%Save the ROI averaged time course to disk for further study
		[pathstr, name, ext] = fileparts(AResultFilename);
		theROITimeCourseLogfile =[fullfile(pathstr,['ROI_', name]), '.txt'];
		save(theROITimeCourseLogfile, 'AROITimeCourse', '-ASCII', '-DOUBLE','-TABS')
		
		%Save 3D+time Dataset's pieces to disk after ROI time course retrieved
		Save1stDimPieces(theTempDatasetDir, AllVolume, 'dim1_');
		clear AllVolume;%Free large memory
		
		%mask selection, added by Xiaowei Song, 20070421
		fprintf('\n\t Load mask "%s".', AMaskFilename);	
		mask=rest_loadmask(nDim1, nDim2, nDim3, AMaskFilename);
		
		fprintf('\n\t Build GCA mask.\tWait...');
		mask =logical(mask);%Revise the mask to ensure that it contain only 0 and 1	
		mask =	repmat(mask, [1, 1, 1, sampleLength]);	
		%Save mask pieces to disk to make this program at least run
		Save1stDimPieces(theTempDatasetDir, mask, 'mask_');	
		
		fprintf('\n\t Build Covariables time course.\tWait...');
		%If there are covariables, 20071002
		theCovariables =[];
		if exist(ACovariablesDef.ort_file, 'file')==2,
			theCovariables =load(ACovariablesDef.ort_file);
        else
            theCovariables=ones(nDim4,1);
        end
        
		fprintf('\n\t GCA is computing.\tWait...');		
	    NumPieces_Dim1 =4;	%Constant number to divide the first dimension to "NumPieces_Dim1" pieces
		NumComputingCount =floor(nDim1/NumPieces_Dim1);
		if NumComputingCount< (nDim1/NumPieces_Dim1),
			NumComputingCount =NumComputingCount +1;
		else
		end
		for x=1:(NumComputingCount),	%20071129
		%for x=1:(floor(nDim1/NumPieces_Dim1) +1)
			rest_waitbar(x/(floor(nDim1/NumPieces_Dim1) +1), ...
						'Computing GCA. Please wait...', ...
						'REST working','Child','NeedCancelBtn');
						
			%Load cached pieces of Datasets
			theFilename =fullfile(theTempDatasetDir, sprintf('dim1_%.8d', x));
			theDim1Volume4D =Load1stDimVolume(theFilename);
			theDim1Volume4D =double(theDim1Volume4D);
            
            
								
			%Load and Apply the pieces' mask
			theFilename =fullfile(theTempDatasetDir, sprintf('mask_%.8d', x));
			theDim1Mask4D =Load1stDimVolume(theFilename);
			theDim1Volume4D(~theDim1Mask4D)=0;
           

			
			%I support multiple reference time course, and I will give each Ideals a Pearson correlation brain
			for y=1:size(AROITimeCourse, 2),
				
				%Compute the Granger Causality of ROI with a 3D+time Brain, return a 3D brain whose elements are the coefficients between the ROI averaged time course and the full 3D+time Brain
				[ResultMap1,ResultMap2,ResultMap3,ResultMap4,ResultMap5] = restgca_residual(AROITimeCourse(:, y), theDim1Volume4D,Order,theCovariables);
				
				%Save to file
				theFilename1 =fullfile(theTempDatasetDir, sprintf('result_x2y%.2d_%.8d', y, x));
                theFilename2 =fullfile(theTempDatasetDir, sprintf('result_y2x%.2d_%.8d', y, x));
                theFilename3 =fullfile(theTempDatasetDir, sprintf('result_x2y_Transformed%.2d_%.8d', y, x));
                theFilename4 =fullfile(theTempDatasetDir, sprintf('result_y2x_Transformed%.2d_%.8d', y, x));
                theFilename5 =fullfile(theTempDatasetDir, sprintf('result_NetFx2y%.2d_%.8d',y,x));
				save(theFilename1, 'ResultMap1');
                save(theFilename2, 'ResultMap2');
                save(theFilename3, 'ResultMap3');
                save(theFilename4, 'ResultMap4');
                save(theFilename5, 'ResultMap5');
			end
			fprintf('.');
		end
		clear theDim1Volume4D theDim1Mask4D ResultMap1 ResultMap2 ResultMap3 ResultMap4 ResultMap5;
		
		%Construct the 3D+time Dataset from files again
		fprintf('\n\t ReConstructing 3D Dataset GCA.\tWait...');
		%Construct the correlation map's filenames, 20070905
		[pathstr, name, ext] = fileparts(AResultFilename);
		ResultMap1 =[];
        ResultMap2 =[];
        ResultMap3 =[];
        ResultMap4 =[];
        ResultMap5 =[];
		for  y=1:size(AROITimeCourse, 2),
			ResultMap1 =[ResultMap1;{[pathstr, filesep ,name, sprintf('%.2d',y), ext]}];
            ResultMap2 =[ResultMap2;{[pathstr, filesep ,name, sprintf('%.2d',y), ext]}];
            ResultMap3 =[ResultMap3;{[pathstr, filesep ,name, sprintf('%.2d',y), ext]}];
            ResultMap4 =[ResultMap4;{[pathstr, filesep ,name, sprintf('%.2d',y), ext]}];
            ResultMap5 =[ResultMap5;{[pathstr, filesep ,name, sprintf('%.2d',y), ext]}];
		end
		%Reconstruct the Result correlation map from pieces
		for  y=1:size(AROITimeCourse, 2),
			theDataset3D1=zeros(nDim1, nDim2, nDim3);
            theDataset3D2=zeros(nDim1, nDim2, nDim3);
            theDataset3D3=zeros(nDim1, nDim2, nDim3);
            theDataset3D4=zeros(nDim1, nDim2, nDim3);
            theDataset3D5=zeros(nDim1, nDim2, nDim3);
			for x=1:(NumComputingCount)
				rest_waitbar(x/(floor(nDim1/NumPieces_Dim1)+1), ...
							'GCA 3D Brain reconstructing. Please wait...', ...
							'REST working','Child','NeedCancelBtn');
				
				theFilename1 =fullfile(theTempDatasetDir, sprintf('result_x2y%.2d_%.8d', y, x));
                theFilename2 =fullfile(theTempDatasetDir, sprintf('result_y2x%.2d_%.8d', y, x));
                theFilename3 =fullfile(theTempDatasetDir, sprintf('result_x2y_Transformed%.2d_%.8d', y, x));
                theFilename4 =fullfile(theTempDatasetDir, sprintf('result_y2x_Transformed%.2d_%.8d', y, x));
                theFilename5 =fullfile(theTempDatasetDir, sprintf('result_NetFx2y%.2d_%.8d', y, x));
				%fprintf('\t%d',x);% Just for debugging
                      if x~=(floor(nDim1/NumPieces_Dim1)+1)
					     theDataset3D1(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:)=Load1stDimVolume(theFilename1);
                         theDataset3D2(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:)=Load1stDimVolume(theFilename2);
                         theDataset3D3(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:)=Load1stDimVolume(theFilename3);
                         theDataset3D4(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:)=Load1stDimVolume(theFilename4);
                         theDataset3D5(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1),:,:)=Load1stDimVolume(theFilename5);
                      else
					     theDataset3D1(((x-1)*NumPieces_Dim1+1):end,:,:)=Load1stDimVolume(theFilename1);
                         theDataset3D2(((x-1)*NumPieces_Dim1+1):end,:,:)=Load1stDimVolume(theFilename2);
                         theDataset3D3(((x-1)*NumPieces_Dim1+1):end,:,:)=Load1stDimVolume(theFilename3);
                         theDataset3D4(((x-1)*NumPieces_Dim1+1):end,:,:)=Load1stDimVolume(theFilename4);
                         theDataset3D5(((x-1)*NumPieces_Dim1+1):end,:,:)=Load1stDimVolume(theFilename5);
                      end		
				fprintf('.');
         
        end
			
			if size(AROITimeCourse, 2)>1,
				%Save every maps from result maps
				%fprintf('\n\t Saving GCA maps: %s\tWait...', ResultMaps{y, 1});	
				    rest_writefile(single(theDataset3D1), ...
					   ResultMap1{y, 1}, ...
					   BrainSize,VoxelSize,Header, 'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');
                    rest_writefile(single(theDataset3D2), ...
					   ResultMap2{y, 1}, ...
					   BrainSize,VoxelSize,Header, 'single'); 
                   rest_writefile(single(theDataset3D3), ...
					   ResultMap3{y, 1}, ...
					   BrainSize,VoxelSize,Header, 'single');
                   rest_writefile(single(theDataset3D4), ...
					   ResultMap4{y, 1}, ...
					   BrainSize,VoxelSize,Header, 'single');
                   rest_writefile(single(theDataset3D5), ...
					   ResultMap5{y, 1}, ...
					   BrainSize,VoxelSize,Header, 'single');
			elseif size(AROITimeCourse, 2)==1,
				%There will be no y loop, just one saving
				%Save Functional Connectivity image to disk
				fprintf('\n\t Saving GCA map.\tWait...');	
                    AResultFilename1=[AResultFilename,'_x2y'];
                    AResultFilename2=[AResultFilename,'_y2x'];    
                    AResultFilename3=[AResultFilename,'_x2y_Transformed']; 
                    AResultFilename4=[AResultFilename,'_y2x_Transformed']; 
                    AResultFilename5=[AResultFilename,'_NetFx2y'];
				    rest_writefile(single(theDataset3D1), ...
					      AResultFilename1, ...
					      BrainSize,VoxelSize,Header, 'single'); 
                    rest_writefile(single(theDataset3D2), ...
					      AResultFilename2, ...
					      BrainSize,VoxelSize,Header, 'single'); 
                    rest_writefile(single(theDataset3D3), ...
					      AResultFilename3, ...
					      BrainSize,VoxelSize,Header, 'single');
                    rest_writefile(single(theDataset3D4), ...
					      AResultFilename4, ...
					      BrainSize,VoxelSize,Header, 'single');
                    rest_writefile(single(theDataset3D5), ...
					      AResultFilename5, ...
					      BrainSize,VoxelSize,Header, 'single');
                %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');
			end%end if
		end%end for	
	end%voxel/region wise
	

	theElapsedTime =cputime - theElapsedTime;
	fprintf('\n\t GCA compution over, elapsed time: %g seconds.\n', theElapsedTime);
	

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
					'Cut one Big 3D+time Dataset into pieces of 3D+time Dataset Before GCA. Please wait...', ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Residual_var = rest_regress(y,X)
         [n,ncolX] = size(X);
         [Q,R,perm] = qr(X,0);
         p = sum(abs(diag(R)) > max(n,ncolX)*eps(R(1)));       
         if p < ncolX,
            R = R(1:p,1:p);
            Q = Q(:,1:p);
            perm = perm(1:p);
         end
         beta = zeros(ncolX,1);
         beta(perm) = R \ (Q'*y);
% compute the var of residual           
         yhat = X*beta;                     
         residual = y-yhat;
         Residual_var = sum(residual.^2)/(length(residual)-1);

%%%% Compute the GCA on residual %%%%%%%
function [ResultMap1,ResultMap2,ResultMap3,ResultMap4,ResultMap5] = restgca_residual(AROITimeCourse, ABrain4D,Order,theCovariables)
         [nDim1, nDim2, nDim3, nDim4]=size(ABrain4D);

         AROITimeCourse = reshape(AROITimeCourse, 1, nDim4)';
         AROITimeCourse_now = AROITimeCourse(Order+1:nDim4);
   
         ABrain4D = reshape(ABrain4D, nDim1*nDim2*nDim3, nDim4)';
   
         theCovariables = [theCovariables(Order+1:end,:),ones(nDim4-Order,1)];
   
         AX = ones(nDim4-Order,Order);
         BY = ones(nDim4-Order,Order);

         AllResult1 = ones(1,nDim1*nDim2*nDim3);
         AllResult2 = ones(1,nDim1*nDim2*nDim3);
   
         for i = 1:nDim1*nDim2*nDim3,
             Y_TimeCourse = ABrain4D(:,i);
             Y_TimeCourse_now = Y_TimeCourse(Order+1:nDim4);
             Judgment = var(Y_TimeCourse_now);
        
             for k = 1:Order,%set order       
                 AX(:,k) = AROITimeCourse(k:nDim4-Order+k-1);
                 BY(:,k) = Y_TimeCourse(k:nDim4-Order+k-1);
             end
        
             Regressors1 = [BY,theCovariables];
             Regressors2 = [AX,theCovariables];
             Regressors3 = [AX,BY,theCovariables];
        
             Residual_Y = rest_regress(Y_TimeCourse_now,Regressors1);
             Residual_X = rest_regress(AROITimeCourse_now,Regressors2);
             Residual_X2Y = rest_regress(Y_TimeCourse_now,Regressors3);
             Residual_Y2X = rest_regress(AROITimeCourse_now,Regressors3);
        
             if Judgment == 0,
                F_X2Y = 0;
                F_Y2X = 0;
             else
                F_X2Y = log(Residual_Y/Residual_X2Y);
                F_Y2X = log(Residual_X/Residual_Y2X);
             end
        
             AllResult1(:,i) = F_X2Y;
             AllResult2(:,i) = F_Y2X;       
         end
    
         ResultMap1 = single(reshape(AllResult1,nDim1,nDim2,nDim3));
         ResultMap2 = single(reshape(AllResult2,nDim1,nDim2,nDim3));
         ResultMap3 = abs((ResultMap1.*(nDim4-Order)-(Order-1)/3)).^0.5;
         ResultMap4 = abs((ResultMap2.*(nDim4-Order)-(Order-1)/3)).^0.5;
         ResultMap5 = ResultMap1-ResultMap2;
%% ROI-wise computation %%%
function [ResultMap1,ResultMap2,ResultMap3,ResultMap4,ResultMap5] = restgca_FROI(theROITimeCourses,Order,theCovariables)
         nDim4 = length(theROITimeCourses);
         AX = ones(nDim4-Order,Order);
         BY = ones(nDim4-Order,Order);
           
         theCovariables = [theCovariables(Order+1:end,:),ones(nDim4-Order,1)];
            
         AROITimeCourse_1 = theROITimeCourses(:,1);
         AROITimeCourse_2 = theROITimeCourses(:,2);
         AROITimeCourse_1now = AROITimeCourse_1(Order+1:nDim4);        
         AROITimeCourse_2now = AROITimeCourse_2(Order+1:nDim4);
            
          for k = 1:Order,
              AX(:,k) = AROITimeCourse_1(k:nDim4-Order+k-1);
              BY(:,k) = AROITimeCourse_2(k:nDim4-Order+k-1);
          end
          
          Regressors1 = [BY,theCovariables];
          Regressors2 = [AX,theCovariables];
          Regressors3 = [AX,BY,theCovariables];
          
          Residual_Y = rest_regress(AROITimeCourse_2now,Regressors1);
          Residual_X = rest_regress(AROITimeCourse_1now,Regressors2);
          Residual_X2Y = rest_regress(AROITimeCourse_2now,Regressors3);  
          Residual_Y2X = rest_regress(AROITimeCourse_1now,Regressors3);
          
          F_X2Y = log(Residual_Y/Residual_X2Y); 
          F_Y2X = log(Residual_X/Residual_Y2X);
          F_TX2Y = abs((F_X2Y*(nDim4-Order)-(Order-1)/3)).^0.5;
          F_TY2X = abs((F_Y2X*(nDim4-Order)-(Order-1)/3)).^0.5;
            
          ResultMap1 = F_X2Y;
          ResultMap2 = F_Y2X;
          ResultMap3 = F_TX2Y;
          ResultMap4 = F_TY2X;
          ResultMap5 = F_X2Y-F_Y2X;

        