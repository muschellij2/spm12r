function nii_mirror_norm (Images, Lesions, vox, bb);
% This script attempts to align scan along midline
%  Images : Image(s) from neurological patients to normalize (helps if  ORIGIN is near anterior commissure)
%  Lesions : EITHER
%       Lesion(s) to process
%      -OR-
%       strokeSide : Side of injury: -1 for left damage, +1 for right damage
%  vox : Voxel size for normalized image, e.g. [1 1 1] for 1mm isotropic
%  bb : Bounding box for normalized image
%
% Example: right hemisphere patient
%   nii_mirror_norm('right_damage.nii',1);
% Example: left hemisphere patient
%   nii_mirror_norm('LHD.nii',-1);
% Example: patient with a lesion map
%   nii_mirror_norm('LHD.nii','LHDlesion.nii');
%
%This code was adapted for SPM8 by Chris Rorden, inspired by
% Nachev P, Coulthard E, Jäger HR, Kennard C, Husain M. (2008) Enantiomorphic normalization of focally lesioned brains. Neuroimage. 39(3):1215-26. PMID: 18023365

%NEXT LINES: initialization
if nargin <1 %no files specified
 Images = spm_select(inf,'image','Select image(s) to midline align');
end
if nargin <2 %no lesions or lesion hemisphere specified
    [strokeSide , YPos] = spm_input('VOI(0), leftStroke(-1), rightStroke(+1)?', 1, 'i',-1);
    if strokeSide == 0
        Lesions = spm_select(inf,'image','Select lesion(s): same order as image(s)');
    else
       Lesions = {}; 
    end;
else
    if isa(Lesions,'double') 
        strokeSide = (Lesions);
        Lesions = {};
    %else - autodetect stroke side from lesion files
    end;
end
if nargin < 3 %no voxel size specified
	vox = [2 2 2];
end;
if nargin < 4 %no bounding box specified
    bb = [-78 -112 -50; 78 76 85];
end;
if (size(Lesions,1) > 0) && (size(Images,1) ~= size(Lesions,1))
   fprintf('%s Error: number of lesions and images must match %s.\n',mfilename);
end;
cleanup = 2; %Segmentation Cleanup 2= thorough cleanup; 1=light cleanup, 0= nocleanup
useSCTemplates = false; %use default (false) or stroke control template (true)

%NEXT LINES: MAIN LOOP - once per image
for j=1:size(Images,1),
    %NEXT: extract filename 
    [pth,nam,ext] = spm_fileparts(deblank(Images(1,:)));
    fname = fullfile(pth,[nam ext]);
    if (exist(fname) ~= 2) 
        fprintf('%s Error: unable to find image %s.\n',mfilename,fname);
        return;  
    end;
    %NEXT: check lesion map if provided
    if (size(Lesions,1) > 0) 
        [lpth,lnam,lext] = spm_fileparts(deblank(Lesions(1,:)));
        lesname = fullfile(lpth,[lnam lext]);
        strokeSide = findLesionSideSub(lesname);
        if strokeSide == 0 %problem detecting lesion
            return;
        end;
        if ~sameDimSub (fname, lesname)
            return;
        end;
    end;
    %NEXT: create mirror image file
    fname_flip = fullfile(pth,['flip' nam ext]);
    fhead = spm_vol([fname,',1']); 
    fdata = spm_read_vols(fhead); 
    fhead.fname = fname_flip;
    fhead.mat = [-1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] * fhead.mat;
    spm_write_vol(fhead,fdata); 
        %An alternative method to flipping:
        %M = [-1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
        %MM(:,:,j) = spm_get_space(fname_flip);
        %spm_get_space(fname_flip, M*MM(:,:,j)); 
    %NEXT: coregister data to estimate transform from image to its mirror
    fhead = spm_vol([fname,',1']); 
    fhead_flip = spm_vol([fname_flip,',1']); 
    x  = spm_coreg(fhead_flip,fhead); 
    %NEXT: apply transform, so both image and flipped meet half way
    x  = (x/2); 
    M = spm_matrix(x);
    MM = spm_get_space(fname_flip);
    spm_get_space(fname_flip, M*MM); %reorient flip
    M  = inv(spm_matrix(x)); 
    MM = spm_get_space(fname);
    spm_get_space(fname, M*MM); %reorient original so midline is X=0
    if (size(Lesions,1) > 0)
        MM = spm_get_space(lesname);
        spm_get_space(lesname, M*MM); %reorient lesion so midline is X=0        
    end;
    %NEXT: reslice flipped to space of unflipped
    P            = char([fname,',1'],[fname_flip,',1']);
    flags.mask   = 0;
    flags.mean   = 0;
    flags.interp = 1;
    flags.which  = 1;
    flags.wrap   = [0 0 0];
    flags.prefix = 'r';
    spm_reslice(P,flags); 
    delete(fname_flip); %remove un-resliced flipped file
    fname_flip = fullfile(pth,['rflip' nam ext]);%resliced flip file
    %NEXT: create image with two intact hemispheres
    fhead = spm_vol([fname,',1']); 
	fdata = spm_read_vols(fhead);
    xdata = fdata;
    fheadflip = spm_vol([fname_flip,',1']); 
	fdataflip = spm_read_vols(fheadflip);
    for z=1:fhead.dim(3)
        for y=1:fhead.dim(2)
            for x=1:fhead.dim(1)
                XYZ_vx = [x; y; z; 1];
                XYZ_mm = fhead.mat * XYZ_vx;
                switch strokeSide
                    case -1
                        if (XYZ_mm(1) < 0) %two right hemispheres
                            xdata(x,y,z) = fdataflip(x,y,z);
                        end
                    case 0
                        xdata(x,y,z) = XYZ_mm(1); %create a map of X coordinate
                    otherwise
                        
                        if (XYZ_mm(1) > 0) %two left hemispheres
                            xdata(x,y,z) = fdataflip(x,y,z);
                        end
                end
            end;%x
        end;%y
    end;%z
    fname_x = fullfile(pth,['x' nam ext]);%resliced flip file
    fhead.fname = fname_x; %save morphed image
    spm_write_vol(fhead,xdata);
    if strokeSide == 0 
        fprintf('%s created an image showing x-dimension',mfilename);
        return;
    end;
    delete(fname_flip);
    %NEXT: if lesion is provided: create 'repaired' image where lesion is filled inwith values from intact hemisphere
    if (size(Lesions,1) > 0)
        fname_repaired = fillLesionSub(fname, lesname, fname_x);
        fname_warp = fname_repaired;
    else
        fname_warp = fname_x;
    end;   
    [wpth,wnam,wext] = spm_fileparts(fname_warp);
    %NEXT: normalize to standard space:
    %  If lesion is provided, normalize repaired image
    %  If lesion is not provided, normalize image with two intact hemispheres
    if useSCTemplates  % 
		disp(sprintf('Using stroke control tissue probability maps - please make sure Clinical Toolbox is installed'));
		gtemplate  = fullfile(spm('Dir'),'toolbox','Clinical','scgrey.nii');
		wtemplate= fullfile(spm('Dir'),'toolbox','Clinical','scwhite.nii');
		ctemplate = fullfile(spm('Dir'),'toolbox','Clinical','sccsf.nii');
    else         
        gtemplate = fullfile(spm('Dir'),'tpm','grey.nii');
        wtemplate = fullfile(spm('Dir'),'tpm','white.nii');
        ctemplate = fullfile(spm('Dir'),'tpm','csf.nii');
    end;
    if ~exist(gtemplate, 'file')
        fprintf('%s error: unable to find template image named %s\n', mfilename,gtemplate);
        return;
    end
    normbatch{1}.spm.spatial.preproc.data = {fname_warp ,',1'};
    normbatch{1}.spm.spatial.preproc.output.GM = [0 0 0];
    normbatch{1}.spm.spatial.preproc.output.WM = [0 0 0];
    normbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
    normbatch{1}.spm.spatial.preproc.output.biascor = 0;
    normbatch{1}.spm.spatial.preproc.output.cleanup = cleanup;
    normbatch{1}.spm.spatial.preproc.opts.tpm = {gtemplate; wtemplate; ctemplate };
    normbatch{1}.spm.spatial.preproc.opts.ngaus = [2; 2; 2; 4];
    normbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
    normbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
    normbatch{1}.spm.spatial.preproc.opts.warpco = 25;
    normbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
    normbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
    normbatch{1}.spm.spatial.preproc.opts.samp = 3;
    normbatch{1}.spm.spatial.preproc.opts.msk = {''};
    fprintf('Unified segmentation of %s with cleanup level %d\n', fname_x, cleanup);
    fprintf('  If segmentation fails: use SPM''s DISPLAY tool to set the origin as the anterior commissure');
    spm_jobman('initcfg');
    spm_jobman('run',normbatch);
    %NEXT: reslice original image to standard space
    reslicebatch{1}.spm.spatial.normalise.write.subj.matname = {fullfile(wpth,[  wnam '_seg_sn.mat'])};
    if (size(Lesions,1) > 0)
        reslicebatch{1}.spm.spatial.normalise.write.subj.resample = {fname ,',1',';', fname_x ,',1',';', lesname ,',1' };
    else
        reslicebatch{1}.spm.spatial.normalise.write.subj.resample = {fname ,',1',';', fname_x ,',1' };
    end;
    reslicebatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
    reslicebatch{1}.spm.spatial.normalise.write.roptions.bb = bb;
    reslicebatch{1}.spm.spatial.normalise.write.roptions.vox = vox; 
    reslicebatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
    reslicebatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    reslicebatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
    spm_jobman('run',reslicebatch);
    %NEXT: compute Z-scores for a rough estimate of lesion location
    fname_xwarped = fullfile(pth,['wx' nam ext]);
    fname_warped = fullfile(pth,['w' nam ext]);
    if strokeSide < 0
		damagedHemi = fullfile(spm('Dir'),'toolbox','Clinical','scx50L.nii');
        intactHemi = fullfile(spm('Dir'),'toolbox','Clinical','scx50R.nii');
    else         
		damagedHemi = fullfile(spm('Dir'),'toolbox','Clinical','scx50R.nii');
        intactHemi = fullfile(spm('Dir'),'toolbox','Clinical','scx50L.nii');
    end;
    if ~exist(damagedHemi, 'file')
        fprintf('%s skipping Z-transforms: unable to find template image named %s: make sure the clinical toolbox is installed\n', mfilename,damagedHemi );
    else
        if ~sameDimSub (fname_warped, damagedHemi)
            fprintf('Unable to compute Z-scores, make sure bounding box (bb) and voxel size (vox) match');
        else
            warpz = clinical_zintensitySub(fname_warped,intactHemi,damagedHemi,fname_xwarped);
            unwarpz = warp2nativeSub(fname_warp,warpz); %deform z-map back to native space
            threshScaleSub(unwarpz); %weight z-map for suspected lesion size
        end;
    end;
end;
fprintf('%s completed\n', mfilename);
%end main function

function [side] = findLesionSideSub (lesname);
%determine if lesion is on left or right hemisphere
%THIS FUNCTION IS NOT CURRENTLY REQUIRED 
% mathod: compute center of mass
side = 0;
lhead = spm_vol([lesname,',1']); 
ldata = spm_read_vols(lhead);
volume = 0;
XYZ_vx = [0; 0; 0; 1];
for z=1:lhead.dim(3)
    for y=1:lhead.dim(2)
        for x=1:lhead.dim(1)
            if (ldata(x,y,z) > 0) %lesion
                XYZ_vx(1) = XYZ_vx(1)+x;
                XYZ_vx(2) = XYZ_vx(2)+y;
                XYZ_vx(3) = XYZ_vx(3)+z;
                volume = volume+1;
            end
        end;%x
    end;%y
end;%z
if (volume == 0) 
    fprintf('%s error - no lesion found in %s\n',mfilename,lesname);
    return;
end;
if (volume *2) > (lhead.dim(1)*lhead.dim(2)*lhead.dim(3))
    fprintf('%s error lesion %s too large to be plausible: is the lesion inverted?\n',mfilename,lesname);
    return;    
end;
XYZ_vx(1) = XYZ_vx(1)/volume;
XYZ_vx(2) = XYZ_vx(2)/volume;
XYZ_vx(3) = XYZ_vx(3)/volume;
XYZ_mm = lhead.mat * XYZ_vx;
fprintf('%s lesion volume is %d voxels, with a center of mass at %f,%f,%f\n',lesname,volume, XYZ_mm(1) ,XYZ_mm(2) ,XYZ_mm(3) );
if (XYZ_mm(1) < 0) 
    side = -1;
else
    side = 1;
end;
%end findLesionSideSub


function [iT1] = fillLesionSub (T1, lesion, flipT1 );
%inserts intact tissue from flipT1 into T1
%returns name of new 'inserted' image
dilateFeather = true; %set to true to dilate the edges of the lesion and feather (blend) edges
head = spm_vol([T1,',1']); 
data = spm_read_vols(head);
fhead = spm_vol([flipT1,',1']); 
fdata = spm_read_vols(fhead);
lhead = spm_vol([lesion,',1']); 
ldata = spm_read_vols(lhead);
if dilateFeather
    rdata = +(ldata > 0); %binarize raw lesion data, + converts logical to double
    spm_smooth(rdata,ldata,4); %blur data
    rdata = +(ldata > 0.1); %dilate: more than 20%
    spm_smooth(rdata,ldata,8); %blur data
else
   ldata = +(ldata > 0); %binarize raw lesion data (0 or 1) regardless of input range 
end
for z=1:fhead.dim(3)
    for y=1:fhead.dim(2)
        for x=1:fhead.dim(1)
            if ldata(x,y,z) > 0
                frac = ldata(x,y,z);
                data(x,y,z) = (frac*fdata(x,y,z))+ ((1-frac)*data(x,y,z));
            end
        end;%x
    end;%y
end;%z
[pth,nam,ext] = spm_fileparts(T1);
iT1 = fullfile(pth,['i' nam ext]);%resliced flip file
head.fname = iT1; %save morphed image
spm_write_vol(head,data); 
%end fillLesionSideSub

function [zName] = clinical_zintensitySub (Filename, Maskname, PreserveName, FlipName);
% Creates version of image where intensity is z-score of brightness in mask
%  Filename: Continuous image[s] used for median calculation
%  Mask: (optional). list of mask image[s] - region used for peak
%  PreserveName : Regions outside this mask are set to zero
%Example
%  mdn = clinical_zintensity('brain.nii','mask.nii','');
%  mdn = clinical_zintensity('MNI152_T1_2mm_brain.nii.gz','mask.voi');
    %Nextload image
    %Filename = nii_ungz(Filename); %optional: convert .nii.gz to .nii
    vi = spm_vol(Filename);
    img = spm_read_vols(vi);
    %load mask
    %Maskname = clinical_ungz(Maskname);
    vm = spm_vol(Maskname);
    mask = spm_read_vols(vm);
    % make mask binary...
    mn = min(mask(:));
    mask = (mask ~= mn);
    imgmasked = img(mask);
    %return result
    format long;
    mn=mean(imgmasked);
    st= std(imgmasked);
    fprintf('%s has %d voxels, the %d defined by the mask %s have a mean intensity of %f and stdev of %f\n',Filename,length(img(:)), length(imgmasked(:)), Maskname,mn, st); 
    if (st == 0) 
        fprintf('clinical_zintensity error: can not compute Z-scores when standard error is zero!');
        return;
    end;
    %use flipped brain
    
    if length(FlipName) > 0 
        fprintf('Normalizing for mirrored image %s.\n',FlipName); 
        vm = spm_vol(FlipName);
        mask = spm_read_vols(vm);
        % make mask binary...
        img = img - mask; %<- difference between standard hemisphere and its mirror
        z=img./ st;
    
    else
        z=(img-mn)./ st;
    end;    
    %%z((img==0)) = 0; %<- use this to retain zeros....
    if length(PreserveName) > 0 
        fprintf('Only retaining voxels in %s.\n',PreserveName); 
        vm = spm_vol(PreserveName);
        mask = spm_read_vols(vm);
        % make mask binary...
        mn = min(mask(:));
        mask = (mask ~= mn);
        z((mask==0)) = 0; %<- only masked regions....
    end;
    % next part saves transformed data
    [pth,nam,ext]=fileparts(vi.fname);
    vi.dt(1)=16; %save as 32-bit float uint8=2; int16=4; int32=8; float32=16; float64=64
    vi.fname = fullfile(pth,['z',  nam, ext]);
    zName = vi.fname;
    spm_write_vol(vi,z);
%end clinical_zintensitySub

function [same] = sameDimSub (imageA, imageB);
%returns whether images have same dimensions and spatial transforms
same = false;
headA = spm_vol([imageA,',1']);
headB = spm_vol([imageB,',1']);
if (headA.dim ~= headB.dim)
    fprintf('Image dimensions differ %s (%dx%d%d) ~= %s (%dx%d%d)\n',imageA,headA(1),headA(2),headA(3), imageB,headB(1),headB(2),headB(3));
    return;
end;
if (headA.mat ~= headB.mat)
    fprintf('Image transformation matrices differ %s  ~= %s (%dx%d%d)\n',imageA, imageB);
    fprintf('%f %f\n',headA.mat,headB.mat);
    return;
end;
same = true;
%end sameDimSub

function [unwarp] = warp2nativeSub (native, warp);
%native is the image used for normalization where a _inv_mat was generated
% warp is an image in normalized space to be deformed back to native
% returns name of un-warped image
[pth,nam,ext] = spm_fileparts(native);
norm2native{1}.spm.util.defs.comp{1}.sn2def.matname = {fullfile(pth,[  nam '_seg_inv_sn.mat'])};
norm2native{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
norm2native{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN; NaN NaN NaN];
norm2native{1}.spm.util.defs.ofname = '';
norm2native{1}.spm.util.defs.fnames = {warp};
norm2native{1}.spm.util.defs.savedir.savepwd = 1;
norm2native{1}.spm.util.defs.interp = 1;
spm_jobman('run',norm2native);
[pth,nam,ext] = spm_fileparts(warp);
unwarp = fullfile(pth,['w'  nam ext]); %warped image
%end warp2nativeSub

function threshScaleSub (zMap);
%Given Z-image, shows only positive values, rescales intensity
head = spm_vol([zMap,',1']); 
data = spm_read_vols(head);
data(isnan(data)) = 0; % use ~isfinite instead of isnan to replace +/-inf with zero
numdark = sum (data(:) < 0);
numbright = sum(data(:) > 0);
moredark = numdark-numbright;
if (moredark < 1) 
    fprintf('%s error: injured hemisphere Z-map has more bright voxels than dark: was this a T2 scan or is hemisphere reversed?');
    return;
end;
dark = (data < 0); %negative values = 1, else = 0
nobright = (dark .* data); %all positive values set to zero
rev = -nobright; %reverse polarity, so only positive
theSum = sum(rev(:));
scale = moredark/theSum;
rev = rev .*scale;
srev = rev;
spm_smooth(rev,srev,2); %blur data 2 voxels - should consider mm
fprintf('suspected lesion size is %d, sum %d\n', moredark,round(sum(rev(:))) );
[pth,nam,ext] = spm_fileparts(zMap);
head.fname = fullfile(pth,['e' nam ext]);%resliced flip file
spm_write_vol(head,srev); 
%end threshScaleSub
