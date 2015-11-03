function nii_fslflirt (P, Ref, Shadow,  OutDir, Prefix);
%Normalize P->Ref using FLIRT
% P: image[s] to normalize
% Ref: [optional] target of normalization
% Shadow: image[s] to be resliced using P->Ref transform
% OutDir: if provided, output folder
%
%Linear transform, mutual information cost function
%
%Note: requires FSL. One could use SPM's coregister function instead
%      I wrote this for data pre-processed with FSL
%
%Example: compute MNI->fMRI, then transform ROI from MNI to native space
%  nii_fslflirt('MNI152_T1_2mm_brain.nii.gz','funct_to_rest.nii.gz', 'right_posterior.nii.gz');
fsldir= '/usr/local/fsl/';
if ~exist(fsldir,'dir')
	error('nii_fslflirt: fsldir (%s) not found',fsldir);
end
setenv('FSLDIR', fsldir);
flirt = [fsldir 'bin/flirt'];
if ~exist(flirt)
	error('nii_fslflirt: flirt (%s) not found',flirt);
end
 
if nargin <1 %no files
 %P = spm_select(inf,'image','Select image[s] to normalize');
 P = spm_select(inf,'^.*\.gz$','Select image[s] to normalize');
end;
if nargin <2 %no Ref
    Ref = [fsldir '/data/standard/MNI152_T1_2mm_brain.nii.gz'] ;
    if ~exist(Ref)
        error('nii_fslflirt: reference image (%s) not found',Ref);
    end
end;
if nargin < 5, Prefix = 'w'; end;

[rpth,rnam,rext] = spm_fileparts(Ref);
for i=1:size(P,1)
  src = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(src);
  src = fullfile(pth,[ nam ext]);
  mat = fullfile(pth,[ nam '.mat']);
  %if RefIsOutDir
  %  dest = fullfile(rpth,['w' nam ext]);  
  %else
  %  dest = fullfile(pth,['w' nam ext]);
  %end;
  if nargin < 4,
    dest = fullfile(pth,[Prefix nam ext]);
  else
    dest = fullfile(OutDir,[Prefix nam ext]);  
  end;
  command=sprintf('sh -c ". ${FSLDIR}/etc/fslconf/fsl.sh; ${FSLDIR}/bin/flirt -in %s -ref %s -out %s -omat %s -bins 256 -cost corratio -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 12  -interp trilinear"\n',src,Ref,dest,mat);
  %command=sprintf('sh -c ". %setc/fslconf/fsl.sh; %sbin/flirt -in %s -ref %s -out %s -omat %s -bins 256 -cost corratio -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 12  -interp trilinear"\n',fsldir,fsldir,src,Ref,dest,mat);  
  system(command);
  if nargin >2 %Shadow Reg
    for i=1:size(Shadow,1)
        ssrc = deblank(Shadow(i,:));
        [spth,snam,sext] = spm_fileparts(ssrc);
        ssrc = fullfile(spth,[ snam sext]);
        %         if RefIsOutDir
        %             dest = fullfile(rpth,['v' snam  ]);
        %         else
        %             dest = fullfile(pth,['v' snam  ]);
        %         end;
        
        if nargin < 4,
            dest = fullfile(pth,[Prefix snam ]);
        else
                dest = fullfile(OutDir,[Prefix snam ]);  
        end;
  
        command=sprintf('sh -c ". ${FSLDIR}/etc/fslconf/fsl.sh; ${FSLDIR}/bin/flirt -in %s -ref %s -out %s -applyxfm -init  %s   -interp trilinear"\n',ssrc,Ref,dest,mat);
        
        %command=sprintf('sh -c ". %setc/fslconf/fsl.sh; %sbin/flirt -in %s -ref %s -out %s -applyxfm -init  %s   -interp trilinear"\n',fsldir,fsldir,ssrc,Ref,dest,mat);
        system(command);
    end;%for each shadow
  end;%if shadows specified
  
end; %for each P
