function clinical_mrnormseg (T1,lesion,T2, UseSCTemplates, vox, bb, DeleteIntermediateImages, ssthresh, cleanup);
% This script normalizes MR scans using normalization-segmetnation
%Inputs
% T1 = 					Filename[s] for T1 scans
% lesion =				OPTIONAL Filename[s] for lesion maps [drawn on T2 if is T2 is specified, otherwise drawn on T1]
% T2 =  					OPTIONAL Filename[s] for T2 weighted images  
% UseSCTemplates =  		OPTIONAL 0=normalize to young individuals, else normalize to template based on older adults
% vox =	  				OPTIONAL Voxel size in mm
% bb =	  				OPTIONAL Bounding box
% DeleteIntermediateImages=	OPTIONAL Should files used inbetween stages be saved?
% ssthresh =	  			OPTIONAL Thresold for brain extraction, e.g. 0.1 will have tissue that has combine GM+WM probability >10%
%
% Example: Normalize T1 scan from elderly person
%  clinical_mrnormseg('c:\dir\t1.nii');
% Example: Normalize T1 scan from elderly person to 1mm isotropic
%  clinical_mrnormseg('c:\dir\t1.nii','','',1,[1 1 1]);
% Example: Normalize T1 scan and lesion from person with stroke, with lesion drawn on T1
%  clinical_mrnormseg('c:\dir\t1.nii','c:\dir\t1lesion.nii' );
% Example: Normalize T1 scan and lesion from person with stroke, with lesion drawn on T2
%  clinical_mrnormseg('c:\dir\t1.nii','c:\dir\t2lesion.nii','c:\dir\t2.nii' );
%   Note: could be T2, FLAIR, etc. but second image (lesion) is aligned to third image ("T2")
% clinical_mrnormseg('C:\t1','C:\lesion.nii','C:\flair.nii');
% UseSCTemplates = If 1, uses 'stroke control' template (good for elderly), if 0 then uses SPM's default tissue templates
%			  				Set to 0.0 if you do not want a brain extracted T1


if nargin <1 %no files
 T1 = spm_select(inf,'image','Select T1 images');
end;
if nargin < 1 %no files
 lesion = spm_select(inf,'image','Optional: select lesion maps (same order as T1)');
else 
 if nargin <2 %T1 specified, no lesion map specified
   lesion = '';
 end;
end;
if (nargin < 1 & length(lesion) > 1) %no files passed, but user has specified both T1 and lesion images...
 T2 = spm_select(inf,'image','Select T2 images (only if lesions are not drawn on T1, same order as T1)');
else %T1 specified, no T2 specified
  if nargin <3 %no files
	T2 = '';
  end;
end;
if nargin < 4 %no template specified
  UseSCTemplates= 1; %assume old individual
end;
if nargin < 5 %no voxel size
	vox = [2 2 2];
end;
if nargin < 6 %no bounding box
	bb = [-78 -112 -50; 78 76 85];
end; % std tight (removes some cerebellum) -> [-78 -112 -50; 78 76 85] ch2 -> [  -90 -126  -72;  90   90  108]
if nargin < 7 %delete images
  DeleteIntermediateImages = 1;
end;
if nargin < 8 %brain extraction threshold
  ssthresh  = 0.005; %0.1;
end;
if nargin < 9 %cleanup not specified
	cleanup = 2; %2= thorough cleanup; 1=light cleanup, 0= nocleanup
end;

smoothlesion = true;
tic
if (length(lesion) < 1) && (length(T2) > 0)
 fprintf('You can not process T2 images without T1 scans\n'); 	
 return;
end;

for i=1:size(T1,1), %repeat for each image the user selected
     [pth,nam,ext] = spm_fileparts(deblank(T1(i,:)));
      T1name = fullfile(pth,[ nam ext]); %the T1 image has no prefix
      if (clinical_filedir_exists(T1name ) == 0)  %report if files do not exist 
         disp(sprintf(' No T1 image found named:  %s', T1name ))
         return  
      end;
	if length(lesion) > 0 
	  [pthL,namL,extL] = spm_fileparts(deblank(lesion(i,:)));
       lesionname = fullfile(pthL,[namL extL]); 
       if (clinical_filedir_exists(lesionname ) == 0)  %report if files do not exist 
        disp(sprintf(' No lesion image found named:  %s', lesionname ))
        return  
       end;
     end;
	if length(T2) > 0 %if 3rd image (T2) exists - use it to coreg 2nd (lesion) to 1st (T1)
	  [pth2,nam2,ext2] = spm_fileparts(deblank(T2(i,:)));
       T2name = fullfile(pth2,[nam2 ext2]); %the T2 pathological image has the prefix 'p'
       if (clinical_filedir_exists(T2name ) == 0)  %report if files do not exist 
         disp(sprintf(' No T2/FLAIR/DWI image found named:  %s', T2name ))
         return  
       end;
       %next coreg
       coregbatch{1}.spm.spatial.coreg.estwrite.ref = {[T1name ,',1']};
       coregbatch{1}.spm.spatial.coreg.estwrite.source = {[T2name ,',1']};
       coregbatch{1}.spm.spatial.coreg.estwrite.other = {[lesionname ,',1']};
       coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
       coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
       coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
       coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
       coregbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
       coregbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
       coregbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
       coregbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
   	  spm_jobman('run',coregbatch);
       namL = ['r' namL]; %resliced data now has prefix 'r'
       lesionname = fullfile(pthL,[namL extL]); %the lesion image has the prefix 'l'
       if (DeleteIntermediateImages == 1) clinical_delete(fullfile(pth2,['r' nam2 ext2])); end;
     end;%nargin > 2 = T2 present
     %next - generate mask
     if length(lesion) > 0 
       clinical_smoothmask(lesionname);
       maskname = fullfile(pthL,['x' namL extL]); 
       if smoothlesion == true
       	slesionname = clinical_smooth(lesionname, 3); %lesions often drawn in plane, with edges between planes - apply 3mm smoothing 
       else
       	slesionname = lesionname;
       end; %if smooth lesion
     end; %if lesion available
     %next normalize...
	if UseSCTemplates == 1 % 
		disp(sprintf('Using stroke control tissue probability maps'));
		gtemplate  = fullfile(fileparts(which(mfilename)),'scgrey.nii');
		wtemplate= fullfile(fileparts(which(mfilename)),'scwhite.nii');
		ctemplate = fullfile(fileparts(which(mfilename)),'sccsf.nii');
     else
		disp(sprintf('Using default SPM tissue probability maps'));
		gtemplate = fullfile(spm('Dir'),'tpm','grey.nii');
		wtemplate = fullfile(spm('Dir'),'tpm','white.nii');
 		ctemplate = fullfile(spm('Dir'),'tpm','csf.nii');
     end;
     %report if templates are not found
     if (clinical_filedir_exists(gtemplate) == 0) || (clinical_filedir_exists(wtemplate) == 0) || (clinical_filedir_exists(ctemplate) == 0)  %report if files do not exist 
         disp(sprintf('Unable to find templates'));
         return  
     end;
     normbatch{1}.spm.spatial.preproc.data = {T1name ,',1'};
     if ssthresh  > 0
     	normbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
     	normbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
     else
     	normbatch{1}.spm.spatial.preproc.output.GM = [0 0 0];
     	normbatch{1}.spm.spatial.preproc.output.WM = [0 0 0];
     end;
     normbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
     normbatch{1}.spm.spatial.preproc.output.biascor = 1;
     normbatch{1}.spm.spatial.preproc.output.cleanup = cleanup;
     normbatch{1}.spm.spatial.preproc.opts.tpm = {
                                               gtemplate 
                                               wtemplate 
                                               ctemplate 
                                               };
     normbatch{1}.spm.spatial.preproc.opts.ngaus = [2; 2; 2; 4];
     normbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
     normbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
     normbatch{1}.spm.spatial.preproc.opts.warpco = 25;
     normbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
     normbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
     normbatch{1}.spm.spatial.preproc.opts.samp = 3;
	if length(lesion) > 0 
	     normbatch{1}.spm.spatial.preproc.opts.msk = {maskname ,',1'};
     else
	     normbatch{1}.spm.spatial.preproc.opts.msk = {''};
     end;
    fprintf('Unified segmentation of %s with cleanup level %d threshold %f, job %d/%d\n', T1name, cleanup, ssthresh, i, size(T1,1));
    fprintf('  If segmentation fails: use SPM''s DISPLAY tool to set the origin as the anterior commissure');
	spm_jobman('run',normbatch);
	%next reslice...
	reslicebatch{1}.spm.spatial.normalise.write.subj.matname = {fullfile(pth,[ nam '_seg_sn.mat'])};	
	
	if length(lesion) > 0 
	     reslicebatch{1}.spm.spatial.normalise.write.subj.resample =  {fullfile(pth,['m' nam ext]) ,',1; ',slesionname ,',1'};
     else
	     reslicebatch{1}.spm.spatial.normalise.write.subj.resample = {fullfile(pth,['m' nam ext]) ,',1'}; %m is bias corrected
     end;
	reslicebatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
	reslicebatch{1}.spm.spatial.normalise.write.roptions.bb = bb;
	reslicebatch{1}.spm.spatial.normalise.write.roptions.vox = vox; 
	reslicebatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
	reslicebatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
	reslicebatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
	spm_jobman('run',reslicebatch);
     %next: reslice tissue maps 
     if ssthresh  > 0
     	c1 = fullfile(pth,['c1' nam ext]);
		c2 = fullfile(pth,['c2' nam ext]);
     	reslicebatch{1}.spm.spatial.normalise.write.subj.resample =  {c1 ,',1; ',c2,',1'};
     	spm_jobman('run',reslicebatch);
     	if (DeleteIntermediateImages == 1) clinical_delete(c1); clinical_delete(c2); end;
     end; 
     
     %we now have our normalized images with the 'w' prefix.
 
     %The optional next lines delete the intermediate images
     if (DeleteIntermediateImages == 1)  clinical_delete(fullfile(pth,['m' nam ext])); end; %mT1 is the bias corrected T1
     if length(lesion) > 0 %we have a lesion
     	if (DeleteIntermediateImages == 1) clinical_delete(maskname ); end; %lesion mask
	     [pthLs,namLs,extLs] = spm_fileparts(slesionname); 
		clinical_binarize(fullfile(pthLs,['w' namLs extLs])); %lesion maps are considered binary (a voxel is either injured or not)
		if (DeleteIntermediateImages == 1) clinical_delete(fullfile(pthLs,['w' namLs extLs])); end; %we can delete the continuous lesion map
	     clinical_nii2voi(fullfile(pthLs,['bw' namLs extLs]));
     end;
     %next: create brain extracted image
     if ssthresh  > 0
     	if length(lesion) > 0 %we have a lesion
     		les = fullfile(pthLs,['bw' namLs extLs]);
		else
			les = '';
		end;
		c1 = fullfile(pth,['wc1' nam ext]);
		c2 = fullfile(pth,['wc2' nam ext]);
        	extractsub(ssthresh, fullfile(pth,['wm' nam ext]), c1, c2, '', les)  
        	if (DeleteIntermediateImages == 1) 
			clinical_delete(c1);
			clinical_delete(c2);
		end;
     end; 
     if length(T2) > 0 %We have a T2, and resliced T2->T1->MNI, delete intermediate image in T1 space
     	if (DeleteIntermediateImages == 1) clinical_delete(lesionname ); end; %intermediate lesion in T1 space   
     	if smoothlesion 
       		if (DeleteIntermediateImages == 1) clinical_delete(slesionname); end;
       	end;     
	end;

end; %for each image in T1name

toc

function extractsub(thresh, t1, c1, c2, c3, PreserveMask)   
%subroutine to extract brain from surrounding scalp
% t1: anatomical scan to be extracted
% c1: gray matter map
% c2: white matter map
% c3: [optional] spinal fluid map
% PreserveMask: [optional] any voxels with values >0 in this image will be spared
[pth,nam,ext] = spm_fileparts(t1);
%load headers
mi = spm_vol(t1);%bias corrected T1
gi = spm_vol(c1);%Gray Matter map
wi = spm_vol(c2);%White Matter map
%load images
m = spm_read_vols(mi);
g = spm_read_vols(gi);
w = spm_read_vols(wi);
if length(c3) > 0
   ci = spm_vol(c3);%CSF map
   c = spm_read_vols(ci);
   w = c+w; 
end;
w = g+w;
if  (length(PreserveMask) >0)
    mski = spm_vol(PreserveMask);%bias corrected T1
    msk = spm_read_vols(mski);
    w(msk > 0) = 1;
end;
if thresh <= 0
    m=m.*w;
else
    mask= zeros(size(m));
    for px=1:length(w(:)),
      if w(px) >= thresh
        mask(px) = 255;
      end;
    end;
    spm_smooth(mask,mask,1); %feather the edges
    mask = mask / 255;
    m=m.*mask;
end;
mi.fname = fullfile(pth,['render',  nam, ext]);
mi.dt(1) = 4; %16-bit precision more than sufficient uint8=2; int16=4; int32=8; float32=16; float64=64
spm_write_vol(mi,m);
%end for extractsub