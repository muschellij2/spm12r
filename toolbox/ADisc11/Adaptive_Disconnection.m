function decom_img = Adaptive_Disconnection(tfe,voxel_size)
%-------------------------------------------------------------------------
% input : tfe : a struct array containing tissue fraction estimates 
%              (aka partial volume estimates) as provided by e.g. pvemri.m
%               or pvemrimex.m 
%        voxel_size = 3 component vector of the voxel dimemsions 
%                     (e.g. [1 1 1] for 1 mm cubed voxels) 
% output: decom_img = mask of labeled brain voxels into left CH (label =1), 
%                     right CH (label = 2), left CB (label = 3), 
%                     right CB (label = 4), and brainstem (label = 5)                     
%-------------------------------------------------------------------------
% Copyright (C) 2010 Lu Zhao
% McConnell Brain Imaging Center,
% Montreal Neurological Institute,
% McGill University, Montreal, QC, Canada
% zhao<at>bic.mni.mcgill.ca
% 
% Modified on 8th Oct 2010
% -------------------------------------------------------------------------
% The method is described in
% L. Zhao, U. Ruotsalainen, J. Hirvonen, J. Hietala and J. Tohka.
% Automatic cerebral and cerebellar hemisphere segmentation in 3D MRI:
% adaptive disconnection algorithm. Medical Image Analysis, 14(3):360-372, 
% 2010.
% L. Zhao and J. Tohka. Automatic compartmental decomposition for 3D MR 
% images of human brain. Proc. of 30th Annual International Conference 
% of the IEEE Engineering in Medicine and Biology Society, EMBC08, pages
% 3888-3891, Vancouver, Canada, August 2008.
% -------------------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software
% for any purpose and without fee is hereby granted, provided that 
% the above copyright notice appear in all copies.  The author makes no 
% representations about the suitability of this software for any purpose. 
% It is provided "as is" without express or implied warranty.
% -------------------------------------------------------------------------
[tfe,ed] = expand_tfe(tfe); 
brain = ((tfe.gm + tfe.wm + tfe.csf) > 0.99) & (tfe.csf < 1);
WM = (tfe.wm > 0); 
pureGM = (tfe.gm == 1);
csfgm = (tfe.csf > 0) & (tfe.gm > 0);

%--------------------------------------------------------------------------
% decompose brain volume into CH, CB and BS
%--------------------------------------------------------------------------
disp('Decomposing Brain Volume (into CH, CB and BS)');
tic;
decomposed_brain = compartment_reconstruction(brain,WM,pureGM,csfgm,voxel_size); 
brain = brain & (tfe.csf < 0.3); 
disp('Brain Volume Decomposition Completed');
toc;
%-------------------------------------------------------------------------
% CH hemisphere segmentation
%-------------------------------------------------------------------------
disp('Segmenting Cerebral Hemispheres');
tic;
M = (decomposed_brain == 1).*brain;
% initializing PDE based shape bottlenecks algorithm for hemisphere segmentation
[X,Y,Z] = size(M);
Ref = zeros(X,Y,Z); 
IND = find(M(:));
[X_nz,Y_nz,Z_nz] = ind2sub([X Y Z],IND);
X_nz_min = min(X_nz);
X_nz_max = max(X_nz);
L_X = X_nz_max - X_nz_min;
X_H = X_nz_min + floor(L_X/4);
X_L = X_nz_max - floor(L_X/4);
init = zeros(X,Y,Z);
for x = 1 : X
    for y = 1 : Y
        for z = 1 : Z
            if (M(x,y,z)~=0)&&(M(x-1,y,z)==0)&&(M(x+1,y,z)==0)&&(M(x,y-1,z)==0)&&(M(x,y+1,z)==0)&&(M(x,y,z-1)==0)&&(M(x,y,z+1)==0)
                Ref(x,y,z) = 0; % Remove noises
            elseif (M(x,y,z)~=0)&&(x<=X_H)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))
                Ref(x,y,z) = 4; % Information source
                init(x,y,z) = 5000;
            elseif (M(x,y,z)~=0)&&(x>=X_L)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))
                Ref(x,y,z) = 1; % Information terminal
                init(x,y,z) = 1000;
            elseif (M(x,y,z)~=0)&&(x>X_H)&&(x<X_L)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))   
                Ref(x,y,z) = 2; % Rest of the boundary
                init(x,y,z) = 3000; 
            elseif (M(x,y,z)~=0)
                Ref(x,y,z) = 3; % Interior region
                init(x,y,z) = 3000;
            end
        end
    end
end

IPM_CH = Info_Map_Gen(int8(Ref),init,0.001,voxel_size(1),voxel_size(2),voxel_size(3));
hemi_mask_CH = IPM_seg_kmeans(IPM_CH);
clear IPM_CH;
disp('Cerebral Hemisphere Segmentation Completed');
toc;
%--------------------------------------------------------------------------
% CB hemisphere segmentation
%--------------------------------------------------------------------------
disp('Segmenting Cerebellar Hemispheres');
tic;
M = (decomposed_brain == 3).*brain;
Ref = zeros(X,Y,Z); 
IND = find(M(:));
[X_nz,Y_nz,Z_nz] = ind2sub([X Y Z],IND);
X_nz_min = min(X_nz);
X_nz_max = max(X_nz);
L_X = X_nz_max - X_nz_min;
X_H = X_nz_min + floor(L_X/4);
X_L = X_nz_max - floor(L_X/4);
init = zeros(X,Y,Z);
for x = 1 : X
    for y = 1 : Y
        for z = 1 : Z
            if (M(x,y,z)~=0)&&(M(x-1,y,z)==0)&&(M(x+1,y,z)==0)&&(M(x,y-1,z)==0)&&(M(x,y+1,z)==0)&&(M(x,y,z-1)==0)&&(M(x,y,z+1)==0)
                Ref(x,y,z) = 0; % Remove noises
            elseif (M(x,y,z)~=0)&&(x<=X_H)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))
                Ref(x,y,z) = 4; % Information source
                init(x,y,z) = 5000;
            elseif (M(x,y,z)~=0)&&(x>=X_L)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))
                Ref(x,y,z) = 1; % Information terminal
                init(x,y,z) =  1000;
            elseif (M(x,y,z)~=0)&&(x>X_H)&&(x<X_L)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))   
                Ref(x,y,z) = 2; % Rest of the boundary
                 init(x,y,z) = 3000;
            elseif (M(x,y,z)~=0)
                 init(x,y,z) = 3000;
                Ref(x,y,z) = 3; % Interior region
            end
        end
    end
end

IPM_CB = Info_Map_Gen(int8(Ref),init,0.001,voxel_size(1),voxel_size(2),voxel_size(3));
hemi_mask_CB = IPM_seg_kmeans(IPM_CB);
clear IPM_CB 
disp('Cerebellar Hemisphere Segmentation Completed');
toc;
clearvars -except hemi_mask_CH hemi_mask_CB decomposed_brain ed
%--------------------------------------------------------------------------
% Denoise and integrate the segmented masks for output
%--------------------------------------------------------------------------
disp('Denoising and Intergrating Segmented Masks');
CHL = ismember(hemi_mask_CH,1);
CHR = ismember(hemi_mask_CH,2);
CHL_labeled = bwlabeln(CHL);
CHR_labeled = bwlabeln(CHR);
clear hemi_mask_CH  CH_L  CH_R
areas_S_CHL = regionprops(CHL_labeled, 'Area');
areas_S_CHR = regionprops(CHR_labeled, 'Area');
areas_CHL = [areas_S_CHL.Area];
areas_CHR = [areas_S_CHR.Area];
clear areas_S_CHL areas_S_CHR
CHL_denoised = double(ismember(CHL_labeled,find(areas_CHL==max(areas_CHL))));
CHR_denoised = double(ismember(CHR_labeled,find(areas_CHR==max(areas_CHR))));
hemi_mask_CH = CHL_denoised + CHR_denoised.*2;
clear CHL_labeled CHR_labeled CHL_denoised CHR_denoised

CBL = ismember(hemi_mask_CB,1);
CBR = ismember(hemi_mask_CB,2);
CBL_labeled = bwlabeln(CBL);
CBR_labeled = bwlabeln(CBR);
clear hemi_mask_CB  CB_L  CB_R
areas_S_CBL = regionprops(CBL_labeled, 'Area');
areas_S_CBR = regionprops(CBR_labeled, 'Area');
areas_CBL = [areas_S_CBL.Area];
areas_CBR = [areas_S_CBR.Area];
clear areas_S_CBL areas_S_CBR
CBL_denoised = double(ismember(CBL_labeled,find(areas_CBL==max(areas_CBL))));
CBR_denoised = double(ismember(CBR_labeled,find(areas_CBR==max(areas_CBR))));
hemi_mask_CB = CBL_denoised.*3 + CBR_denoised.*4;
clear CBL_labeled CBR_labeled CBL_denoised CBR_denoised

decom_img = hemi_mask_CH + hemi_mask_CB + 5*(decomposed_brain == 2);
decom_img = shrink_tfe(decom_img,ed);
disp('Adaptive Disconnection Completed');
