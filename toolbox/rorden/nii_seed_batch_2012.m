function nii_seed_batch_2012;
%Find peak in fMRI data, reslice to resting state data.

tic %start timer

%We can select multiple regions of interest (roi)
%  The ROI images are mapped onto a brain extracted image (roispace) 
roi = strvcat('frontal_left.nii.gz', 'frontal_right.nii.gz', 'post_left.nii.gz', 'post_right.nii.gz' );
rdir = '/Volumes/mac_data/renew/regions/';
roispace = 'MNI152_T1_2mm_brain.nii.gz';
%for each 'subj'ect there is 
% stat: a statistical map in native fMRI space 
% fmri: mean motion corrected fMRI image 
% restreg: resting state image normalized to MNI and resliced to 3x3x3mm 
%          (created during resting state pre-processing
 subj = strvcat('P001/','P002/','P003/','P004/','P005/','P006/','P007/','P008/');
sdir = '/Volumes/mac_data/renew/mcbi/';
stat = 'zstat2.nii.gz'; %NOT .GZ!!! SPM likes plain .nii files
fmri = 'bg_image.nii.gz';
restreg = '/reg/example_func2standard.nii.gz';
restregt1 = '/reg/standard.nii.gz';
%This code will
% 1: [once per roi] warp roi to restreg by coregistering roispace to restregt1 
% 2: [once per subj] warp stat to restreg by coregistering fmri to restreg
% 3: [for each subj*roi] find coordinate peak of stat within each roi
% 4: Mask with restreg



 n = size(subj,1);


 Ref = fullfile(sdir, deblank(subj(1,:)), restregt1 );
 RefRoi = fullfile(rdir , roispace);
 for j=1:size(roi,1)
     %step 1: ONCE PER ROI reslice regions of interest to normalized resting state space     
     Shadow =  fullfile(rdir, deblank(roi(j,:)));
     %fprintf('WARP ROI TO NORMALIZED RESTING: warping %s to match %s, and reslicing %s\n',RefRoi, Ref, Shadow); 
     %nii_fslflirt(RefRoi, Ref, Shadow, rdir);
 end;


 for i=1:n %size(subj,1) 
    %step 2: ONCE PER SUBJ warp fMRI to normalized resting state space
    subjdir = [sdir, deblank(subj(i,:))];
    Ref = fullfile(subjdir, restreg );
    RefStat = fullfile(subjdir, fmri );
	Shadow = fullfile(subjdir, stat );
    fprintf('WARP FMRI TO NORMALIZED RESTING:  warping %s to match %s, and reslicing %s\n',RefStat, Ref, Shadow); 
    %nii_fslflirt(RefStat, Ref, Shadow, subjdir);
    wstat = fullfile(subjdir,['w' stat] );    
    %wstat = nii_ungz(wstat);
    for j=1:size(roi,1)
        %step 3: [for each subj*roi] find coordinate peak of stat within each roi  
        wroi =  fullfile(rdir, ['w' deblank(roi(j,:))] );
        %wroi = nii_ungz(wroi);
        fprintf('SEED finding: peak activity of %s in mask %s\n',wstat, wroi); 
        nii_makeseed(wstat,3, wroi);
    end;

end;
 
 
 %step 1: regions of interest to fmri space
%      Ref = fullfile(sdir, deblank(subj(i,:)), fmri );
%      dir = fullfile(sdir, deblank(subj(i,:)) );
%      for j=1:size(roi,1)
%          Shadow =  fullfile(rdir, deblank(roi(j,:)));
%          nii_fslflirt(fullfile(rdir , roispace), Ref, Shadow, dir);
%      end;
%  end;
%  
 
% %step 1: regions of interest to fmri space
%  for i=1:n %size(subj,1) 
%      Ref = fullfile(sdir, deblank(subj(i,:)), fmri );
%      dir = fullfile(sdir, deblank(subj(i,:)) );
%      for j=1:size(roi,1)
%          Shadow =  fullfile(rdir, deblank(roi(j,:)));
%          nii_fslflirt(fullfile(rdir , roispace), Ref, Shadow, dir);
%      end;
%  end;
% 
% 
% %step 2: find peak in each region
%  for i=1:n%size(subj,1) 
%      for j=1:size(roi,1)
%          func = fullfile(sdir, deblank(subj(i,:)), stat );%
%         mask = fullfile(sdir, deblank(subj(i,:)), ['w' deblank(roi(j,:))] );
%          nii_makeseed(func,3, mask);
%      end;
%  
% end; 
% 
% %step 3: reslice to 3mm MNI
%  outspace = '/Volumes/mac_data/renew/regions/MNI152_T1_3mm_brain.nii.gz';
%  for i=1:n
%      %Ref = fullfile(sdir, deblank(subj(i,:)), fmri );
%      dir = fullfile(sdir, deblank(subj(i,:)) );
%      Ref = fullfile(dir, ['w', roispace]);
%      dir = '/Volumes/mac_data/renew/regions/';
%      for j=1:size(roi,1)
%          func = fullfile(sdir, deblank(subj(i,:)), stat );
%          [pth,nam,ext] = spm_fileparts(deblank(roi(j,:)));
%          Shadow = fullfile(sdir, deblank(subj(i,:)), ['aw' nam] );
%          nii_fslflirt(Ref, outspace, Shadow, dir, [num2str(i), 's']);
%      end;
%  end;
% 
% 
% %step 4: reslice to resting data
% 
% for i=1:n %size(subj,1)
%     outspace = fullfile(sdir, deblank(subj(i,:)),'func/rest_filt_mean.nii.gz');
%     Ref = fullfile(sdir, deblank(subj(i,:)), fmri );
%     dir = fullfile(sdir, deblank(subj(i,:)) );
%     %Ref = fullfile(dir, ['w', roispace]);
%     dir = fullfile(dir, 'func/');
%     for j=1:size(roi,1)
%         func = fullfile(sdir, deblank(subj(i,:)), stat );
%         [pth,nam,ext] = spm_fileparts(deblank(roi(j,:)));
%         Shadow = fullfile(sdir, deblank(subj(i,:)), ['aw' nam] );
%         nii_fslflirt(Ref, outspace, Shadow, dir);
%     end;
% end;

%step 5: reslice to resting data - session 2
 
subj2 = strvcat('P201/','P202/','P203/','P204/','P205/','P206/','P207/','P208/');
%  for i=1:n %size(subj,1)
%     outspace = fullfile(sdir, deblank(subj2(i,:)),'func/rest_filt_mean.nii.gz');
%     Ref = fullfile(sdir, deblank(subj(i,:)), fmri );
%     dir = fullfile(sdir, deblank(subj2(i,:)) );
%     %Ref = fullfile(dir, ['w', roispace]);
%     dir = fullfile(dir, 'func/');
%     for j=1:size(roi,1)
%         func = fullfile(sdir, deblank(subj(i,:)), stat );
%         [pth,nam,ext] = spm_fileparts(deblank(roi(j,:)));
%         Shadow = fullfile(sdir, deblank(subj(i,:)), ['aw' nam] );
%         nii_fslflirt(Ref, outspace, Shadow, dir);
%     end;
% end;

%medians
% 
% corr = strvcat('sawfrontal_left_corr.nii.gz','sawfrontal_right_corr.nii.gz','sawpost_left_corr.nii.gz','sawpost_right_corr.nii.gz');
% out= 'results.txt';
% dlmwrite(out,'median','-append', 'delimiter', '');
% 
% b = zeros(n*2,size(corr,1)* size(roi,1)  );
% 
% Label = {};
% for j=1:size(corr,1);
%     for k=1:size(roi,1)
%             Label = [Label, [deblank(corr(j,:)), 'x', deblank(roi(k,:)), '*']  ];
%     end;
% end;
% dlmwrite(out,Label,'-append', 'delimiter', '');
% 
% for i=1:n
%      fdir = fullfile(sdir, deblank(subj(i,:)),'func/');  
%      dir = fullfile(sdir, deblank(subj(i,:)),'func/RSFC/');
%      x = 0;
%      for j=1:size(corr,1);
%          map = fullfile(dir, [num2str(i) deblank(corr(j,:))] );
%          for k=1:size(roi,1)
%              [pth,nam,ext] = spm_fileparts(deblank(roi(k,:)));        
%              mask = fullfile(fdir,  ['waw' nam ext] );
%              x = x + 1;
%              b(i,x) =   nii_median (map, mask);
%          end;
%       end;
% end;
% 
% for i=1:size(subj2,1)
%      fdir = fullfile(sdir, deblank(subj2(i,:)),'func/');  
%      dir = fullfile(sdir, deblank(subj2(i,:)),'func/RSFC/');
%      x = 0;
%      for j=1:size(corr,1);
%          map = fullfile(dir, [num2str(i) deblank(corr(j,:))] );
%          for k=1:size(roi,1)
%              [pth,nam,ext] = spm_fileparts(deblank(roi(k,:)));        
%              mask = fullfile(fdir,  ['waw' nam ext] );
%              x = x + 1;
%              b(i+n,x) =   nii_median (map, mask);
%          end;
%       end;
% end;
% 
% 
% %   b(1,i) =  nii_median(deblank(subj(i,:)),'mask.voi');
% 
% dlmwrite(out,'median','-append', 'delimiter', '');
% dlmwrite(out, b, '-append', 'delimiter', '\t');


toc