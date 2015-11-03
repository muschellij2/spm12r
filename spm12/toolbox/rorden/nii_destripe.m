function nii_destripe (P);
%Remove banding between odd and even slices seen due to slice interference
%  P: Image[s] to remove striping artifacts
% Example
%   nii_destrip ('C:\dir\img.nii');

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to translate');
end;

fprintf('%s: please make sure all air voxels are set to zero (use BET)',mfilename);

for i=1:size(P,1)
  ref = deblank(P(i,:));
  Vi  = spm_vol(strvcat(P(i,:)));
  [pth,nam,ext] = spm_fileparts(ref);
  nVol = length(Vi);
  nSlices = round (Vi(1).dim(3));
  if (nSlices < 2) 
    fprintf('%s can not de-stripe %s: at least 2 slices are required \n',mfilename, ref); 
  else
      %create output file
      VO       = Vi; %output image
      for v=1:nVol
        VO(v).fname = fullfile(pth,['d' nam '.nii']); 
      end;
      VO       = spm_create_vol(VO);
      
      for v=1:nVol
          %first pass, for each slice, find number of non-zero voxels and their mean
          mnVals = NaN(nSlices+1,1); %create empty array to record mean values
          stdVals = NaN(nSlices+1,1); %create empty array to record standard deviation values
          nVals = zeros(nSlices,1); %create empty array to number of non-zero voxels
          for i=1:Vi(v).dim(3), 
            img      = spm_slice_vol(Vi(v),spm_matrix([0 0 i]),Vi(v).dim(1:2),0);
            tmp      = find(isnan(img));     %make NaNs into zeros
            img(tmp) = 0;
            imgVals = nonzeros(img); %only examine non-zero voxels
            nVals(i) = length(imgVals); %number of non-zero voxels
            if nVals(i) > 0 
                mnVals(i) = mean(imgVals(:)); %average  of non-zero voxels
                stdVals(i) = std(imgVals(:)); 
                if (v==1)
                    fprintf(' slice: %d voxels: %d mean: %f stdev: %f\n', i, nVals(i), mnVals(i),  stdVals(i));
                end;
            end
          end; %for each slice
          mnVals(nSlices+1) = mnVals(nSlices-1); %if 12 slices create 13th slice with value of 11th
          %second pass, rescale even slices
          for i=1:Vi(v).dim(3),
            img      = spm_slice_vol(Vi(v),spm_matrix([0 0 i]),Vi(v).dim(1:2),0);
            if (mod(i,2) == 1)  %odd slice
                %odd slice, do nothing
            elseif (isnan(mnVals(i-1)) && isnan(mnVals(i+1)) )
                % no valid voxels above or below: do nothing
            else
                if isnan(mnVals(i-1))
                    %no valid voxels in previous slice: use next slice for estimates
                    mnVal = mnVals(i+1);
                    slope = stdVals(i+1) / stdVals(i);
                elseif isnan(mnVals(i+1))
                    %no valid voxels in next slice: use previous slice for estimates
                    mnVal = mnVals(i-1);
                    slope = stdVals(i-1) / stdVals(i);
                else
                    %use both previous and next slice for estimates
                    mnVal = 0.5*( mnVals(i-1)+mnVals(i+1) );
                    slope = (0.5*(stdVals(i-1)+stdVals(i+1))) / stdVals(i);
                end;
                for px=1:length(img(:)),
                  if ((~isnan(img(px))) && (img(px) ~= 0) )
                      img(px) = ((img(px)-mnVals(i))*slope)+mnVal;
                  end;
                end;
            end; %if slice requires adjustment
            VO(v)       = spm_write_plane(VO(v),img,i);
         end; %for each slice 
     
      end;% for each volume
      fprintf('de-striped %s with %d slices and %d volumes\n',VO(1).fname, nSlices, nVol); 	
  end; %if multiple slices
end %for each image