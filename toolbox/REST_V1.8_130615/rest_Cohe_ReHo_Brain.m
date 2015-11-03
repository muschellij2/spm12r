function [] = rest_Cohe_ReHo_Brain(ADataDir, NVoxel, AMaskFilename, AResultFilename,ASamplePeriod,AHighPass_LowCutoff,ALowPass_HighCutoff,Auto,TimeP,Overlap)
% Calculate Regional Homogeneity based on Coherence from the 3D EPI images.
% FORMAT     function []   = rest_Cohe_ReHo_Brain(ADataDir, NVoxel, AMaskFilename, AResultFilename,ASamplePeriod,AHighPass_LowCutoff,ALowPass_HighCutoff,Auto,TimeP,Overlap)
% Input:
% 	ADataDir			Where the 3d+time dataset stay, and there should be	3d EPI functional image files. It must not contain / or \ at the end.
%   NVoxel              The number of the voxel for a given cluster during calculating the KCC (e.g. 27, 19, or 7); Recommand: NVoxel=27;
% 	AMaskFilename		the mask file name, I only compute the point within the mask
%	AResultFilename		the output filename
% 	ASamplePeriod		TR, or like the variable name
% 	AHighPass_LowCutoff			the low edge of the pass band
% 	ALowPass_HighCutoff			the High edge of the pass band
%   Auto   Define the segment automatically
%   TimeP  Time points in each segment
%   Overlap Overlap for neighboring segments
% Output:
%	AResultFilename	the filename of ReHo result
%   For methodology, please see: 
%   Liu D, Yan C, Ren J, Yao L, Kiviniemi VJ and Zang Y (2010) Using coherence to measure regional homogeneity of resting-state fMRI signal. Front. Syst. Neurosci. 4:24. doi: 10.3389/fnsys.2010.00024 
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="charlesliu116@gmail.com">LIU Dong-Qiang</a>;	<a href="dongzy08@gmail.com">DONG Zhang-Ye</a>; <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>
%	Version=1.0;
%	Release=20101025;

if nargin~=10
    error(' Error using ==> Cohe-ReHo. 10 arguments wanted.');
end
theElapsedTime =cputime;

% Examine the Nvoxel
% --------------------------------------------------------------------------
if NVoxel ~= 27 & NVoxel ~= 19 & NVoxel ~= 7 
    error('The second parameter should be 7, 19 or 27. Please re-exmamin it.');
end

%read the normalized functional images 
% -------------------------------------------------------------------------
fprintf('\n\t Read these 3D EPI functional images.\twait...');
[I,vsize,theImgFileList, Header,nVolumn] =rest_to4d(ADataDir);
[nDim1 nDim2 nDim3 nDim4]=size(I);
isize = [nDim1 nDim2 nDim3]; 
mask=rest_loadmask(nDim1, nDim2, nDim3, AMaskFilename);


M=nDim1;
N=nDim2;
O=nDim3;
% calulate the kcc for the data set
% ------------------------------------------------------------------------
fprintf('\t Calculate the Cohe-ReHo on voxel by voxel for the data set.\n');
K = zeros(M,N,O); 
switch NVoxel
    case 27  
        for i = 2:M-1
            for j = 2:N-1
                for k = 2:O-1                            
                    block = I(i-1:i+1,j-1:j+1,k-1:k+1,:);
                    mask_block = mask(i-1:i+1,j-1:j+1,k-1:k+1);
                    if mask_block(2,2,2)~=0
                        %YAN Chao-Gan 090717, We also calculate the cohe value of the voxels near the border of the brain mask, users should be cautious when dicussing the results near the border. %if all(mask_block(:))
                        R_block=reshape(block,27,[]);%Revised by YAN Chao-Gan, 090420. Speed up the calculation.
                        mask_R_block = R_block(reshape(mask_block,27,1) > 0,:);
                        K(i,j,k) =  rest_Cohe_ReHo(mask_R_block,ASamplePeriod,ALowPass_HighCutoff,AHighPass_LowCutoff,Auto,TimeP,Overlap);  
                    end %end if	
                end%end k 
            end% end j			
			%rest_waitbar(i/M, ...
			%		sprintf('Calculate the Cohe-ReHo\nwait...'), ...
			%		'Cohe-ReHo Computing','Child','NeedCancelBtn');
        end%end i
        fprintf('\t The Cohe-ReHo of the data set was finished.\n');
        rest_writefile(single(K),AResultFilename,isize,vsize,Header, 'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');
    case 19  
        mask_cluster_19=ones(3,3,3);
        mask_cluster_19(1,1,1) = 0;    mask_cluster_19(1,3,1) = 0;    mask_cluster_19(3,1,1) = 0;    mask_cluster_19(3,3,1) = 0;
        mask_cluster_19(1,1,3) = 0;    mask_cluster_19(1,3,3) = 0;    mask_cluster_19(3,1,3) = 0;    mask_cluster_19(3,3,3) = 0;
        %Revised by YAN Chao-Gan, 090420. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
        for i = 2:M-1
            for j = 2:N-1
                for k = 2:O-1                            
                    block = I(i-1:i+1,j-1:j+1,k-1:k+1,:);
                    mask_block = mask(i-1:i+1,j-1:j+1,k-1:k+1);
                    if mask_block(2,2,2)~=0
                        %YAN Chao-Gan 090717, We also calculate the ReHo value of the voxels near the border of the brain mask, users should be cautious when dicussing the results near the border. %if all(mask_block(:))
                        mask_block=mask_block.*mask_cluster_19;
                        %Revised by YAN Chao-Gan, 090419. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
                        R_block=reshape(block,27,[]);%Revised by YAN Chao-Gan, 090420. Speed up the calculation.
                        mask_R_block = R_block(reshape(mask_block,27,1) > 0,:);
                        K(i,j,k) =  rest_Cohe_ReHo(mask_R_block,ASamplePeriod,ALowPass_HighCutoff,AHighPass_LowCutoff,Auto,TimeP,Overlap); 
                    end%end if
                end%end k
            end%end j	
			%rest_waitbar(i/M, ...
			%		sprintf('Calculate the Cohe-ReHo\nwait...'), ...
			%		'Cohe-ReHo Computing','Child','NeedCancelBtn');
        end%end i
        fprintf('\t The Cohe-ReHo of the data set was finished.\n');
        rest_writefile(single(K),AResultFilename,isize,vsize,Header, 'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');
    case 7   
        mask_cluster_7=ones(3,3,3);
        mask_cluster_7(1,1,1) = 0;    mask_cluster_7(1,2,1) = 0;     mask_cluster_7(1,3,1) = 0;      mask_cluster_7(1,1,2) = 0;
        mask_cluster_7(1,3,2) = 0;    mask_cluster_7(1,1,3) = 0;     mask_cluster_7(1,2,3) = 0;      mask_cluster_7(1,3,3) = 0;
        mask_cluster_7(2,1,1) = 0;    mask_cluster_7(2,3,1) = 0;     mask_cluster_7(2,1,3) = 0;      mask_cluster_7(2,3,3) = 0;
        mask_cluster_7(3,1,1) = 0;    mask_cluster_7(3,2,1) = 0;     mask_cluster_7(3,3,1) = 0;      mask_cluster_7(3,1,2) = 0;
        mask_cluster_7(3,3,2) = 0;    mask_cluster_7(3,1,3) = 0;     mask_cluster_7(3,2,3) = 0;      mask_cluster_7(3,3,3) = 0;
        %Revised by YAN Chao-Gan, 090420. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
        for i = 2:M-1
            for j = 2:N-1
                for k = 2:O-1
                    block = I(i-1:i+1,j-1:j+1,k-1:k+1,:);
                    mask_block = mask(i-1:i+1,j-1:j+1,k-1:k+1);
                    if mask_block(2,2,2)~=0
                        %YAN Chao-Gan 090717, We also calculate the ReHo value of the voxels near the border of the brain mask, users should be cautious when dicussing the results near the border. %if all(mask_block(:))
                        mask_block=mask_block.*mask_cluster_7;
                        %Revised by YAN Chao-Gan, 090419. The element in the mask could be 1 other than 127. Fixed the bug of computing ReHo with 7 voxels or 19 voxels.
                        R_block=reshape(block,27,[]);%Revised by YAN Chao-Gan, 090420. Speed up the calculation.
                        mask_R_block = R_block(reshape(mask_block,27,1) > 0,:);
                        K(i,j,k) =  rest_Cohe_ReHo(mask_R_block,ASamplePeriod,ALowPass_HighCutoff,AHighPass_LowCutoff,Auto,TimeP,Overlap);
                    end%end if
                end%end k
            end%end j		
			%rest_waitbar(i/M, ...
			%		sprintf('Calculate the Cohe-ReHo\nwait...'), ...
			%		'Cohe-ReHo Computing','Child','NeedCancelBtn');
        end%end i
        fprintf('\t The Cohe-ReHo of the data set was finished.\n');
        rest_writefile(single(K),AResultFilename,isize,vsize,Header,'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');
    otherwise
        error('The second parameter should be 7, 19 or 27. Please re-exmamin it.');
end %end switch
Ken = K;
theElapsedTime =cputime - theElapsedTime;
fprintf('\n\tCohe-ReHo computation over, elapsed time: %g seconds\n', theElapsedTime);

% calculate kcc for a time series
%---------------------------------------------------------------------------
% function B = f_kendall(A)
% nk = size(A); n = nk(1); k = nk(2);
% SR = sum(A,2); SRBAR = mean(SR);
% S = sum(SR.^2) - n*SRBAR^2;
% B = 12*S/k^2/(n^3-n);
    
    
%function Save1stDimPieces(ATempDir, A4DVolume, AFilenamePrefix)
%Save the 1st dimension of the 4D dataset to files
%NumPieces_Dim1=10;	%Constant number to divide the first dimension to "NumPieces_Dim1" pieces 
%NumComputingCount =ceil(size(A4DVolume,1)/NumPieces_Dim1);
%for x = 1:(NumComputingCount),
%    %for x = 1:(floor(size(A4DVolume,1)/NumPieces_Dim1)+1)
%    rest_waitbar((x/NumComputingCount), ...
%        'Cut one Big 3D+time Dataset into pieces of 3D+time Dataset Before Cohe-ReHo. Please wait...', ...
%        'REST working','Child','NeedCancelBtn');
%
%    theFilename =fullfile(ATempDir, sprintf('%s%.8d',AFilenamePrefix, x));
%    if x~=NumComputingCount
%        the1stDim = A4DVolume(((x-1)*NumPieces_Dim1+1):(x*NumPieces_Dim1), :,:,:);
%    else
%        the1stDim = A4DVolume(((x-1)*NumPieces_Dim1+1):end, :,:,:);
%    end
%    save(theFilename, 'the1stDim');
%end

%function Result=Load1stDimVolume(AFilename)
%Load the 1st dimension of the 4D dataset from files, return a Matrix not a struct
%Result =load(AFilename);
%theFieldnames=fieldnames(Result);
% Result =eval(sprintf('Result.%s',the1stField));%remove the struct variable to any named variable with a matrix
%Result = Result.(theFieldnames{1});
