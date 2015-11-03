function region_growed = RegionGrow(region, Target, Ptotal)

%--------------------------------------------------------------------------
% Grow the region towards to Target volume using boundary-closing indicator 
% based region growing algorithm.
%%%%%%
% Input:  region: seeds for region growing
%         Target: target volume 
%         Ptotal: matrix containing the boundary-closing indicator values 
% Output: region_growed: reconstructed volume from the seeds
%--------------------------------------------------------------------------
% Copyright (C) 2010 Lu Zhao
% McConnell Brain Imaging Center,
% Montreal Neurological Institute,
% McGill University, Montreal, QC, Canada
% zhao<at>bic.mni.mcgill.ca
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
% Permission to use, copy, modify, and distribute this software for any 
% purpose and without fee is hereby granted, provided that the above 
% copyright notice appear in all copies.  The author makes no representations 
% about the suitability of this software for any purpose. It is provided 
% "as is" without express or implied warranty.
% -------------------------------------------------------------------------

[X Y Z]=size(Target);
Target1 = reshape(Target,X*Y*Z,1);
IND = find(Target1);
[X_nz,Y_nz,Z_nz] = ind2sub([X Y Z],IND);


%-----------------------------------------------------------------
% Region growing
%-----------------------------------------------------------------
lx = ((max(X_nz)-min(X_nz)) - mod((max(X_nz)-min(X_nz)),2))/2;
xc_ne = min(X_nz); 
xc_po = max(X_nz) + mod((max(X_nz)-min(X_nz)+1),2); 


dif1 = nnz(region)-nnz(Target);
iteration = 0;
x = zeros(1,2);

while dif1~=0;
      dif2 = dif1;
      for p = 0 : lx
          x(1,1) = xc_ne + p;
          x(1,2) = xc_po - p;
          for y = 1 : Y
              for z = 1 : Z
                  for tx = 1 : 2
                       if (region(x(tx),y,z)~=0)
                           for a = -1 : 1
                               for b = -1 : 1
                                   for c = -1 : 1
                                       if (region(x(tx)+a,y+b,z+c)==0)&&(Target(x(tx)+a,y+b,z+c)~=0)
                                           region(x(tx)+a,y+b,z+c)=(Ptotal(x(tx)+a,y+b,z+c)>Ptotal(x(tx),y,z))*region(x(tx),y,z);
                                       end
                                    end
                                end
                            end
                       end
                  end
              end
          end
      end
      dif1 = nnz(region)-nnz(Target);
      if dif2 - dif1 == 0
          break;
      end
      iteration = iteration + 1;
end

% Hole filling
dif3 = nnz(region)-nnz(Target);
iteration = 0;
while dif3 ~= 0
    dif4 = dif3;
      for x = 1 : X
          for y = 1 : Y
              for z = 1 : Z
                  if (region(x,y,z)==0)&&(Target(x,y,z)~=0)
                      Nb = zeros(1,3);
                      for a = -1 : 1
                          for b = -1 : 1
                              for c = -1 : 1
                                  if region(x+a,y+b,z+c)~=0
                                     Nb(region(x+a,y+b,z+c))=Nb(Target(x+a,y+b,z+c))+1;
                                  end
                               end
                           end
                      end
                      if max(Nb) > 0
                         region(x,y,z)=find(Nb==max(Nb),1,'first');
                      end
                  end
              end
          end
      end
      dif3 = nnz(region)-nnz(Target);
      if dif4 - dif3 == 0
          break;
      end
      iteration = iteration + 1;
end

% Smoothing
for x = 1 : X
    for y = 1 : Y
        for z = 1 : Z
            if (region(x,y,z)~=0)
                Nb = zeros(1,3);
                for a = -1 : 1
                    for b = -1 : 1
                        for c = -1 : 1
                            if region(x+a,y+b,z+c)~=0
                               Nb(region(x+a,y+b,z+c))=Nb(region(x+a,y+b,z+c))+1;
                            end
                        end
                     end
                 end
                 if max(Nb) > 0
                    region(x,y,z)=find(Nb==max(Nb),1,'first');
                 end
            end
        end
    end
end

region_growed = region;








