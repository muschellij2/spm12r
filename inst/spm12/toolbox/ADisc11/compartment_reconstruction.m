function decomposed_brain = compartment_reconstruction(brain,WM,pureGM,csfgm,voxel_size) 
%--------------------------------------------------------------------------
% Decompose brain volume into CH, CB and BS. 
% input: brain = the binary mask of the brain volume consisting of GM, WM, GM/WM and CSF/GM;
%        WM = the mask of WM+GM/WM (binary);
%        pureGM = the mask of pure GM (binary);
%        csfgm = the CSF/GM mask (binary);
%        voxel_size = 3 component vector of the voxel dimemsions 
%                     (e.g. [1 1 1] for 1 mm cubed voxels) 
% output: decomposed_brain = mask of labeled brain voxels into CH (label = 1), CB (label = 3), BS (label =2);
%-------------------------------------------------------------------------
% Copyright (C) 2010 Lu Zhao
% McConnell Brain Imaging Center,
% Montreal Neurological Institute,
% McGill University, Montreal, QC, Canada
% zhao<at>bic.mni.mcgill.ca
% ------------------------------------------------------------------------
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

[X Y Z]=size(brain);
brain1 = reshape(brain,X*Y*Z,1);
IND = find(brain1);
[X_nz,Y_nz,Z_nz] = ind2sub([X Y Z],IND);

% Segment the WM mask into CH, CB and BS as starting voxels for
% reconstruction


% define the High and Low information boundaries and the flow domain 

Ref = zeros(X,Y,Z); % Matrix whose elements determine which area the corresponding voxel in M is 

% define the position of the High and Low boundaries
IND = find(WM(:));
[X_nz,Y_nz,Z_nz] = ind2sub([X Y Z],IND);
Z_nz_min = min(Z_nz);
Z_nz_max = max(Z_nz);
L_Z = Z_nz_max - Z_nz_min;
Z_H = Z_nz_max - floor(L_Z/4);
Z_L = Z_nz_min + floor(L_Z/8);

% region classification
init = zeros(X,Y,Z);
for x = 1 : X
    for y = 1 : Y
        for z = 1 : Z
            if (WM(x,y,z)~=0)&&(WM(x-1,y,z)==0)&&(WM(x+1,y,z)==0)&&(WM(x,y-1,z)==0)&&(WM(x,y+1,z)==0)&&(WM(x,y,z-1)==0)&&(WM(x,y,z+1)==0)
                Ref(x,y,z) = 0;
            elseif (WM(x,y,z)~=0)&&(z>=Z_H)&&((WM(x-1,y,z)==0)||(WM(x+1,y,z)==0)||(WM(x,y-1,z)==0)||(WM(x,y+1,z)==0)||(WM(x,y,z-1)==0)||(WM(x,y,z+1)==0))
                Ref(x,y,z) = 4; % High boundary
                init(x,y,z) = 5000;
            elseif (WM(x,y,z)~=0)&&(z<=Z_L)&&((WM(x-1,y,z)==0)||(WM(x+1,y,z)==0)||(WM(x,y-1,z)==0)||(WM(x,y+1,z)==0)||(WM(x,y,z-1)==0)||(WM(x,y,z+1)==0))
                Ref(x,y,z) = 1; % Low boundary
                init(x,y,z) = 1000;
            elseif (WM(x,y,z)~=0)&&(z<Z_H)&&(z>Z_L)&&((WM(x-1,y,z)==0)||(WM(x+1,y,z)==0)||(WM(x,y-1,z)==0)||(WM(x,y+1,z)==0)||(WM(x,y,z-1)==0)||(WM(x,y,z+1)==0))   
                Ref(x,y,z) = 2; % rest boundary
                init(x,y,z) = 3000;
            elseif (WM(x,y,z)~=0)
                Ref(x,y,z) = 3; % interior region
                init(x,y,z) = 3000;
            end
        end
    end
end

IPM_CH_CBB = Info_Map_Gen(int8(Ref),init,0.001,voxel_size(1),voxel_size(2),voxel_size(3));

clear init Ref
Seg_CH_CBB = IPM_seg_kmeans(IPM_CH_CBB);
%--------------------------------------------------------------------------
% denoising
%--------------------------------------------------------------------------
WM_CH = (Seg_CH_CBB == 1);
WM_CBB = (Seg_CH_CBB == 2);
WM_CH_labeled = bwlabeln(WM_CH);
WM_CBB_labeled = bwlabeln(WM_CBB);
clear WM_CH WM_CBB Seg_CH_CBB
areas_S_CH = regionprops(WM_CH_labeled, 'Area');
areas_S_CBB = regionprops(WM_CBB_labeled, 'Area');
areas_CH = [areas_S_CH.Area];
areas_CBB = [areas_S_CBB.Area];
clear areas_S_CH areas_S_CBB 
WM_CH_denoised = ismember(WM_CH_labeled,find(areas_CH==max(areas_CH)));
WM_CBB_denoised = ismember(WM_CBB_labeled,find(areas_CBB==max(areas_CBB)));
clear areas_CH areas_CBB WM_CH_labeled WM_CBB_labeled
%--------------------------------------------------------------------------
% segment brainstem and cerebellum
%--------------------------------------------------------------------------
% define the High and Low information boundaries and the flow domain 
Ref = zeros(X,Y,Z); % Matrix whose elements determine which area the corresponding voxel in M is 
% define the position of the High and Low boundaries
IND = find(WM_CBB_denoised(:));
[X_nz,Y_nz,Z_nz] = ind2sub([X Y Z],IND);
angle = -20/180;
Y_nz_rot = Y_nz*cos(angle*pi) + Z_nz*sin(angle*pi);
% Z_nz_rot = -Y_nz*sin(angle*pi) + Z_nz*cos(angle*pi);
Y_nz_rot_min = min(Y_nz_rot);
Y_nz_rot_max = max(Y_nz_rot);
L_Y_rot = Y_nz_rot_max - Y_nz_rot_min;
Y_H_rot = Y_nz_rot_max - L_Y_rot/8;
Y_L_rot = Y_nz_rot_min + L_Y_rot/4;
% region classification
init = zeros(X,Y,Z);
for x = 1 : X
    for y = 1 : Y
        for z = 1 : Z
            y_rot = y*cos(angle*pi) + z*sin(angle*pi);
            if (WM_CBB_denoised(x,y,z)~=0)&&(WM_CBB_denoised(x-1,y,z)==0)&&(WM_CBB_denoised(x+1,y,z)==0)&&(WM_CBB_denoised(x,y-1,z)==0)&&(WM_CBB_denoised(x,y+1,z)==0)&&(WM_CBB_denoised(x,y,z-1)==0)&&(WM_CBB_denoised(x,y,z+1)==0)
                Ref(x,y,z) = 0;
            elseif (WM_CBB_denoised(x,y,z)~=0)&&(y_rot>=Y_H_rot)&&((WM_CBB_denoised(x-1,y,z)==0)||(WM_CBB_denoised(x+1,y,z)==0)||(WM_CBB_denoised(x,y-1,z)==0)||(WM_CBB_denoised(x,y+1,z)==0)||(WM_CBB_denoised(x,y,z-1)==0)||(WM_CBB_denoised(x,y,z+1)==0))
                Ref(x,y,z) = 4; % High boundary
                init(x,y,z) = 5000;
            elseif (WM_CBB_denoised(x,y,z)~=0)&&(y_rot<=Y_L_rot)&&((WM_CBB_denoised(x-1,y,z)==0)||(WM_CBB_denoised(x+1,y,z)==0)||(WM_CBB_denoised(x,y-1,z)==0)||(WM_CBB_denoised(x,y+1,z)==0)||(WM_CBB_denoised(x,y,z-1)==0)||(WM_CBB_denoised(x,y,z+1)==0))
                Ref(x,y,z) = 1; % Low boundary
                init(x,y,z) = 1000;
            elseif (WM_CBB_denoised(x,y,z)~=0)&&(y_rot<Y_H_rot)&&(y_rot>Y_L_rot)&&((WM_CBB_denoised(x-1,y,z)==0)||(WM_CBB_denoised(x+1,y,z)==0)||(WM_CBB_denoised(x,y-1,z)==0)||(WM_CBB_denoised(x,y+1,z)==0)||(WM_CBB_denoised(x,y,z-1)==0)||(WM_CBB_denoised(x,y,z+1)==0))   
                Ref(x,y,z) = 2; % rest boundary
                init(x,y,z) = 3000;
            elseif (WM_CBB_denoised(x,y,z)~=0)
                Ref(x,y,z) = 3; % interior region
                init(x,y,z) = 3000;
            end
        end
    end
end

IPM_CH_CBB = Info_Map_Gen(int8(Ref),init,0.001,voxel_size(1),voxel_size(2),voxel_size(3));
clear init Ref

Seg_CB_BS= IPM_seg_kmeans(IPM_CH_CBB);
clear IPM_CH_CBB

WM_BS = ismember(Seg_CB_BS,1);
WM_CB = ismember(Seg_CB_BS,2);
WM_BS_labeled = bwlabeln(WM_BS);
WM_CB_labeled = bwlabeln(WM_CB);
clear WM_BS WM_CB Seg_CB_BS
areas_S_BS = regionprops(WM_BS_labeled, 'Area');
areas_S_CB = regionprops(WM_CB_labeled, 'Area');
areas_BS = [areas_S_BS.Area];
areas_CB = [areas_S_CB.Area];
clear areas_S_BS areas_S_CB
WM_BS_denoised = double(ismember(WM_BS_labeled,find(areas_BS==max(areas_BS))));
WM_CB_denoised = double(ismember(WM_CB_labeled,find(areas_CB==max(areas_CB))));
clear WM_BS_labeled WM_CB_labeled areas_BS areas_CB
WM_CB_BS_denoised = WM_BS_denoised*2 + WM_CB_denoised*3;
region = WM_CH_denoised + WM_CB_BS_denoised; % combine the labeled tissue maps.
clear WM_BS_denoised WM_CB_denoised WM_CB_BS_denoised


% Compute the boundary closing indicators for each brain voxel
D_toback = bwdist(abs(brain - 1));
D_tocsfgm = bwdist(csfgm).*brain;
dist_max = max(max(max(D_tocsfgm)));
dtoback_max = max(max(max(D_toback)));
Pdist = (dist_max-D_tocsfgm)/dist_max.*brain;
Pdtoback = (dtoback_max-D_toback)/dtoback_max.*brain;
Ptotal = Pdist + Pdtoback;
clear D_toback D_tocsfgm Pdist Pdtoback
% Compartment reconstruction from starting voxels

%-----------------------------------------------------------------
% Grow region to pure GM domain
%-----------------------------------------------------------------
region_GM = RegionGrow(region, (brain - csfgm), Ptotal);
%-----------------------------------------------------------------
% segment CBB in GM into BS and CB
%-----------------------------------------------------------------
CBB_pureGM = int8(pureGM).*int8(ismember(region_GM,[2 3]));
BS_seed_WM = int8(region==2);
CB_seed_WM = int8(region==3);
M = CBB_pureGM + BS_seed_WM + CB_seed_WM;
init = zeros(X,Y,Z);
Ref = zeros(X,Y,Z); 
for x = 1 : X
    for y = 1 : Y
        for z = 1 : Z
            if (M(x,y,z)~=0)&&(M(x-1,y,z)==0)&&(M(x+1,y,z)==0)&&(M(x,y-1,z)==0)&&(M(x,y+1,z)==0)&&(M(x,y,z-1)==0)&&(M(x,y,z+1)==0)
                Ref(x,y,z) = 0;
            elseif (M(x,y,z)~=0)&&((M(x-1,y,z)==0)||(M(x+1,y,z)==0)||(M(x,y-1,z)==0)||(M(x,y+1,z)==0)||(M(x,y,z-1)==0)||(M(x,y,z+1)==0))
                Ref(x,y,z) = 2; 
                init(x,y,z) = 3000;
            elseif (CBB_pureGM(x,y,z)~=0)&&(M(x-1,y,z)*M(x+1,y,z)*M(x,y-1,z)*M(x,y+1,z)*M(x,y,z-1)*M(x,y,z+1)~=0)
                Ref(x,y,z) = 3; 
                init(x,y,z) = 3000;
            elseif BS_seed_WM(x,y,z)~=0
                Ref(x,y,z) = 4;
                init(x,y,z) = 5000;
            elseif CB_seed_WM(x,y,z)~=0
                Ref(x,y,z) = 1;
                init(x,y,z) = 1000;
            end
        end
    end
end
clear CBB_pureGM BS_seed_WM CB_seed_WM M 
IPM_CB_BS_GM = Info_Map_Gen(int8(Ref),init,0.001,voxel_size(1),voxel_size(2),voxel_size(3));
clear init Ref
region_CB_BS_GM = IPM_seg_kmeans(IPM_CB_BS_GM);
clear IPM_CB_BS_GM

GM_BS = ismember(region_CB_BS_GM,1);
GM_CB = ismember(region_CB_BS_GM,2);
GM_BS_labeled = bwlabeln(GM_BS);
GM_CB_labeled = bwlabeln(GM_CB);
clear region_CB_BS_GM  GM_BS  GM_CB
areas_S_BS = regionprops(GM_BS_labeled, 'Area');
areas_S_CB = regionprops(GM_CB_labeled, 'Area');
areas_BS = [areas_S_BS.Area];
areas_CB = [areas_S_CB.Area];
clear areas_S_BS areas_S_CB
GM_BS_denoised = double(ismember(GM_BS_labeled,find(areas_BS==max(areas_BS))));
GM_CB_denoised = double(ismember(GM_CB_labeled,find(areas_CB==max(areas_CB))));
region_CB_BS_GM = GM_BS_denoised.*2 + GM_CB_denoised.*3;
clear GM_BS_labeled GM_CB_labeled GM_BS_denoised GM_BS_denoised
region_new = double(region==1) + region_CB_BS_GM; % new seeds
clear pureGM region_GM region_CB_BS_GM region
%------------------------------------------------------------------
% grow new seeds to whole brain domain
%------------------------------------------------------------------
decomposed_brain = RegionGrow(region_new, brain, Ptotal);


                


