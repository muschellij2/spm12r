function clinical_ctnorm(V, lesion, vox, bb, DeleteIntermediateImages, UseTemplateMask);
% This script attempts to normalize a CT scan
% V                        =   filename[s] of CT scan[s] to normalize
% lesion                     =   filename[s] of lesion maps. Optional: binary images drawn in same dimensions as CT. For multiple CTs, order of V and lesion must be the same
% vox                      =   voxel size of normalized image[s]
% bb                       =   bounding box of normalized image[s]
% DeleteIntermediateImages =   if 1, then temporary images used between steps are deleted
%
% Prior to running this script, use SPM's DISPLAY
%   Use this to set "0 0 0"mm to point to the Anterior Commissure
% Example
%   clinical_ctnorm ('C:\dir\img.nii');

fprintf('CT normalization version 2/2/2012\n');

%use custom 'stroke control' CT templates
cttemplate = fullfile(fileparts(which(mfilename)),'scct.nii');
%cttemplate = fullfile(spm('Dir'),'templates','Transm.nii');%SPM8 default template
%report if templates are not found
if (clinical_filedir_exists(cttemplate) == 0) %report if files do not exist 
  disp(sprintf('Please put the CT template in the SPM template folder'));
  return  
end;

if nargin <1 %no files
 V = spm_select(inf,'image','Select CT[s] to normalize');
end;

if nargin < 1 %no files
 lesion = spm_select(inf,'image','Optional: select lesion maps (same order as CTs)');
else 
 if nargin <2 %T1 specified, no lesion map specified
   lesion = '';
 end;
end;

if nargin < 3 %no voxel size
	vox = [2 2 2];
end;

if nargin < 4 %no bounding box
% 	bb = [-78 -112 -50; 78 76 85];
    bb = [  -90 -126  -72;  90   90  108];
end;

if nargin < 5 %delete images
  DeleteIntermediateImages = 1;
end;

if nargin < 6 %delete images
  UseTemplateMask= 0;
end;

if UseTemplateMask== 1
	TemplateMask = fullfile(spm('Dir'),'apriori','brainmask.nii');
	if (clinical_filedir_exists(TemplateMask ) == 0) %report if files do not exist 
  		fprintf('clinical_ctnorm error: Mask not found %s\n',TemplateMask );
  		return  
	end;
end;



if (size(lesion) > 1) 
 if (size(lesion) ~= size(V))
   fprintf('You must specify the same number of lesions as CT scans\n'); 	
   return;
 end;
end;

smoothlesion = true;
%spm_jobman('initcfg'); %<- resets batch editor

for i=1:size(V,1)
 r = deblank(V(i,:));
 [pth,nam,ext, vol] = spm_fileparts(r);
 ref = fullfile(pth,[nam ext]); 
 if (exist(ref ) ~= 2) 
 	fprintf('Error: unable to find source image %s.\n',ref);
	return;  
 end;
 Vi  = spm_vol(strvcat(V(i,:)));
 % determine range...
 mx = -Inf;
 mn =  Inf;
 for p=1:Vi.dim(3),
	img = spm_slice_vol(Vi,spm_matrix([0 0 p]),Vi.dim(1:2),1);
	msk = find(isfinite(img));
	mx  = max([max(img(msk)) mx]);
	mn  = min([min(img(msk)) mn]);
 end;
 range = mx-mn;
 %Hounsfield units, in theory 
 %  min = air = ~-1000
 %  max = bone = ~1000
 %  in practice, teeth fillings are often >3000
 %  Therefore, raise warning if range < 2000
 %   or Range > 6000 then generate warning: does not appear to be in Hounsfield units
 if (range < 1999) | (range > 8000) 
	fprintf('Error: image intensity range (%f) does not appear to be in Hounsfield units.\n',range);
	return
 end;
 fprintf('%s intensity range: %d\n',ref,round(range));
 fprintf(' Ignore QFORM0 warning if reported next\n');
 % next scale from Hounsfield to Cormack
  VO       = Vi;
  [pth,nam,ext] = spm_fileparts(ref);
  VO.fname = fullfile(pth, ['c' nam '.nii']);
  VO.private.dat.scl_slope = 1;
  VO.private.dat.scl_inter = 0;
    VO       = spm_create_vol(VO);
  clipped = 0;
  for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);
    for px=1:length(img(:)),
        img(px) = h2csub(img(px),mn);
      end; %for each pixel
  	VO       = spm_write_plane(VO,img,i);
   end; %for each slice
   %next - prepare lesion mask
   if length(lesion) > 0 
	  [pthL,namL,extL] = spm_fileparts(deblank(lesion(1,:)));
       lesionname = fullfile(pthL,[namL extL]); 
       if (clinical_filedir_exists(lesionname ) == 0)  %report if files do not exist 
        disp(sprintf(' No lesion image found named:  %s', lesionname ))
        return  
       end;
       clinical_smoothmask(lesionname);
       maskname = fullfile(pthL,['x' namL extL]); 
       if smoothlesion == true
       	slesionname = clinical_smooth(lesionname, 3); %lesions often drawn in plane, with edges between planes - apply 3mm smoothing 
       else
       	slesionname = lesionname;
       end; %if smooth lesion
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = {maskname ,',1'};
       %to turn off lesion masking replacing previous line with next line:
       %matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[slesionname ,',1'];[ref,',1']};
       fprintf('masking %s with %s using template %s.\n',ref, slesionname, cttemplate);
   else % if no lesion
   	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
   	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[ref,',1']};
    fprintf('normalizing %s without a mask using template %s.\n',ref, cttemplate);
   end; 
   %next normalize
   matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {[VO.fname,',1']};
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {[cttemplate ,',1']};
   %matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = ''; 
   if UseTemplateMask == 1 
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = {[TemplateMask ,',1']};   
   else
   	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
   end;   
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = bb;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = vox; %2x2x2mm isotropic
   %matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [  -90 -126  -72;  90   90  108];
   %matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2]; %2x2x2mm isotropic
   %matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [1 1 1];
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';
   [npth,nnam,next] = spm_fileparts(ref);
   out_mat = fullfile(npth, [nnam, '.mat']);
    save(out_mat, 'matlabbatch');
    fprintf('Matfile made %s\n',out_mat);
  
   spm_jobman('run',matlabbatch);
   if (DeleteIntermediateImages == 1) 
     clinical_delete(fullfile(pth,['c' nam '.nii'])); %delete cormack image
     if length(lesion) > 0 
     	clinical_delete(maskname);
     	if smoothlesion == true
       		clinical_delete(slesionname); 
       	end; %if smoothed lesions
     end; %if lesions
   end;% if delete
   %make lesion binary, create voi
   if length(lesion) > 0 %we have a lesion
	clinical_binarize(fullfile(pthL,['ws' namL extL])); %lesion maps are considered binary (a voxel is either injured or not)
	if (DeleteIntermediateImages == 1) clinical_delete(fullfile(pthL,['ws' namL extL])); end; %we can delete the continuous lesion map
	clinical_nii2voi(fullfile(pthL,['bws' namL extL]));
   end;
   
end; %for each volume

function out = h2csub(in,min);
%======================
%Convert Hounsfiled to Cormack
 kUninterestingDarkUnits = 900; % e.g. -1000..-100
 kInterestingMidUnits = 200; %e.g. -100..+300
 kScaleRatio = 10;% increase dynamic range of interesting voxels by 3

 v16 = in-min;
 lExtra = v16-kUninterestingDarkUnits;
 if lExtra > kInterestingMidUnits
   lExtra = kInterestingMidUnits;
 end;
 if lExtra > 0 
   lExtra = lExtra*kScaleRatio;
  else
   lExtra = 0;
 end;
  out = v16+lExtra;