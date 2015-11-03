% Partial volume estimation in brain MRI with TMCD method
% Book keeping is done during the ICM to avoid doing any computations
% for voxels which cannot change the label during an ICM sweep.
% (C) 2013 Jussi Tohka 
% Department of Signal Processing,
% Tampere University of Technology, Finland
% jussi.tohka at tut.fi
% -------------------------------------------------------------
% The method is described in 
% J. Tohka, A. Zijdenbos, and A. Evans. 
% Fast and robust parameter estimation for statistical partial volume models in brain MRI. 
% NeuroImage, 23(1):84 - 97, 2004. 
% Please cite this paper if you use the code
% 
% The incremental kmeans algorithm used to initialize the method (if the segmented image is 
% not given) is described in
% J.V. Manjón,  J. Tohka , G. García-Martí, J. Carbonell-Caballero, 
% J.J. Lull, L. Martí-Bonmatí and M. Robles.
% Robust MRI Brain Tissue Parameter Estimation by Multistage Outlier Rejection. 
% Magnetic Resonance in Medicine, 59:866 - 873, 2008. 
% Please cite additionally this paper if you use the incremental k-means 
% 
% Several speed-ups and, in particular, the fast ICM algorithm are detailed in
% J. Tohka. FAST-PVE: Extremely Fast Markov Random Field Based Brain MRI 
% Tissue Classification. SCIA 2013, Scandinavian Conference on Image Analysis, 
% Helsinki, Finland, 2013, Lecture notes in computer science vol 7944 pp. 266 - 276.
% --------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software 
% for any purpose and without fee is hereby
% granted, provided that the above copyright notice appear in all
% copies.  The author and Tampere University of Technology make no representations
% about the suitability of this software for any purpose.  It is
% provided "as is" without express or implied warranty.
% -------------------------------------------------------------
% Input arguments  
%         img        : A 3D MRI image to be segmented. This should be corrected for intensity nonuniformities.
%   brain_mask       : A mask defining brain/non-brain voxels. Voxels outside the brain should have value 0 and voxels inside the brain should have value 1 
%  tissue_class      : A segmentation of the image into csf, gm, and wm. 
%                       csf should have label 1
%                       gm should have label 2 
%                       wm should have label 3
%                      If you don't have this, give an empty matrix (i.e. []). 
%                      This will be then generated based on a modified k-means described in Manjon et al. MRM 2008. 
%                      This is quite robust and very fast. 
%                      IMPORTANT: the implementation assumes T1-weighted data!!!  It is, however, easy to modify the method for other weightings. 
%  class_params      : A cell array of the tissue class parameters (optional)
%                      you can give also an empty matrix and the parameters will 
%                      be estimated for you 
%                      class_params{1}.mu is the mean intensity of CSF
%                      class_params{1}.var is the intensity variance of CSF
%                      class_params{2}.mu is the mean intensity of GM
%                      class_params{2}.var is the intensity variance of GM
%                      class_params{3}.mu is the mean intensity of WM
%                      class_params{3}.var is the intensity variance of WM
%  voxel_size        : Voxel size of the image, a 3 component vector (optional, defaults to [1 1 1])
%        beta        : regularization parameter (optional, defaults to 0.1)
%      Output 
%                    : tfe = tissue fraction estimate images for csf, gm, and wm 
%                    : pve_disc: Crisp segmentation with PVE labels
%                    : In pve_disc label 0 is background
%                                  label 1 is csf   
%                                  label 2 is gm
%                                  label 3 is wm
%                                  label 4 is background/csf
%                                  label 5 is csf/gm
%                                  label 6 is gm/wm 
% Version history
% Version 1.01 Sep 15 2010: A minor bug correction in initialization  
% Version 2.00 May 5  2013: Introduced speed ups from the mex-based code
%                           also to this "pure" Matlab version


function [tfe,pve_disc] = pvemri2(img,brain_mask,tissue_class,class_params,voxel_size,beta)
  tic
  if nargin < 3
    disp('Too few input arguments'); 
    return  
  elseif nargin == 3
    class_params = [];	  
    voxel_size = [1 1 1];
    beta = 0.1;
  elseif nargin == 4    
    voxel_size = [1 1 1];
    beta = 0.1;  
  elseif nargin == 5
    voxel_size = abs(voxel_size);	  
    voxel_size = voxel_size/min(voxel_size);
    beta = 0.1;
  else
    voxel_size = abs(voxel_size);	  
    voxel_size = voxel_size/min(voxel_size);
  end  
  
  sz = size(img);
  brain_mask = (brain_mask > 0.5);
  % cutting the size of the image based on the brain mask
  lim(1,1) = 1;
  for i = 1:sz(1)
    if sum(sum(brain_mask(i,:,:))) == 0
      lim(1,1) = i;
    else
      break;
    end
  end  
  lim(1,2) = sz(1);
  for i = sz(1):(-1):1
    if sum(sum(brain_mask(i,:,:))) == 0
      lim(1,2) = i;
    else
      break;
    end
  end
  lim(2,1) = 1;
  for i = 1:sz(2)
    if sum(sum(brain_mask(:,i,:))) == 0
      lim(2,1) = i;
    else
      break;
    end
  end  
  lim(2,2) = sz(2);
  for i = sz(2):(-1):1
    if sum(sum(brain_mask(:,i,:))) == 0
      lim(2,2) = i;
    else
      break;
    end
  end
  lim(3,1) = 1;
  for i = 1:sz(3)
    if sum(sum(brain_mask(:,:,i))) == 0
      lim(3,1) = i;
    else
      break;
    end
  end  
  lim(3,2) = sz(3);
  for i = sz(3):(-1):1
    if sum(sum(brain_mask(:,:,i))) == 0
      lim(3,2) = i;
    else
      break;
    end
  end
  brainind = find(brain_mask(lim(1,1):lim(1,2),lim(2,1):lim(2,2),lim(3,1):lim(3,2)));
  if isempty(class_params)
    if isempty(tissue_class)  
      disp('generating hard segmentation using incremental k-means');
      tissue_class = kmeansinc(img(lim(1,1):lim(1,2),lim(2,1):lim(2,2),lim(3,1):lim(3,2)),brainind);
    end
    tissue_class = round(tissue_class);
    disp('Estimating tissue class parameters');
    class_params = estimate_parameters(img(lim(1,1):lim(1,2),lim(2,1):lim(2,2),lim(3,1):lim(3,2)),brainind,tissue_class);  
  end
  
  % add background class
  class_params{4}.mu = 0;
  class_params{4}.var = 0.1*class_params{1}.var;
  disp('Computing partial volume classification')
  pve_disc = zeros(sz);
  pve_disc(lim(1,1):lim(1,2),lim(2,1):lim(2,2),lim(3,1):lim(3,2)) = icm_trans(img(lim(1,1):lim(1,2),lim(2,1):lim(2,2),lim(3,1):lim(3,2)),brain_mask(lim(1,1):lim(1,2),lim(2,1):lim(2,2),lim(3,1):lim(3,2)),beta,voxel_size,class_params,50);
 % pve_disc = icm_trans(img,brain_mask,lim,beta,voxel_size,class_params);
  % maximum likelihood based tissue fraction estimation
  disp('Estimating tissue fractions');
  tfe.csf = zeros(sz);
  tfe.gm = zeros(sz);
  tfe.wm = zeros(sz);
  ind = find(pve_disc(:) == 1);
  tfe.csf(ind) = 1;
  ind = find(pve_disc(:) == 2);
  tfe.gm(ind) = 1;
  ind = find(pve_disc(:) == 3);
  tfe.wm(ind) = 1;
  t = 0:0.01:1;
  ind = find(pve_disc(:) == 4); % the tissue class is CSF/backrgound
  tmpmu = t*class_params{1}.mu + (1 - t)*class_params{4}.mu;
  tmpvar = t.^2*class_params{1}.var + (1 - t).^2*class_params{4}.var;
  reg_term = log(tmpvar);
  for i = 1:length(ind)
    score = (img(ind(i)) - tmpmu).^2./tmpvar + reg_term;  
    [tmpval,tfe.csf(ind(i))] = min(score); 
    tfe.csf(ind(i)) =  (tfe.csf(ind(i)) - 1)/100;
  end
  
  ind = find(pve_disc(:) == 5); % the tissue class is CSF/GM
  tmpmu = t*class_params{1}.mu + (1 - t)*class_params{2}.mu;
  tmpvar = t.^2*class_params{1}.var + (1 - t).^2*class_params{2}.var;
  reg_term = log(tmpvar);
  for i = 1:length(ind)
    score = (img(ind(i)) - tmpmu).^2./tmpvar + reg_term;  
    [tmpval,tfe.csf(ind(i))] = min(score); 
    tfe.csf(ind(i)) =  (tfe.csf(ind(i)) - 1)/100;
    tfe.gm(ind(i)) = 1 - tfe.csf(ind(i));	    
  end
  
  ind = find(pve_disc(:) == 6); % the tissue class is GM/WM
  tmpmu = t*class_params{2}.mu + (1 - t)*class_params{3}.mu;
  tmpvar = t.^2*class_params{2}.var + (1 - t).^2*class_params{3}.var;
  reg_term = log(tmpvar);
  for i = 1:length(ind)
    score = (img(ind(i)) - tmpmu).^2./tmpvar + reg_term;  
    [tmpval,tfe.gm(ind(i))] = min(score); 
    tfe.gm(ind(i)) =  (tfe.gm(ind(i)) - 1)/100;
    tfe.wm(ind(i)) = 1 - tfe.gm(ind(i));	    
  end
  toc
  
  % SUBFUNCTIONS
  % *******************************************
  % Iterative conditional modes based MRF
  % *******************************************

function seg = icm_trans(img,brain_mask,beta,voxel_size,class_params,max_iterations)

 
  inter = [2   (-1) (-1) (-1)  1  (-1) (-1) 
          (-1)   2  (-1) (-1)  1    1  (-1)
          (-1) (-1)   2  (-1) (-1)  1    1
          (-1) (-1) (-1)   2  (-1) (-1)  1
           1    1   (-1) (-1) 2   (-1) (-1)
	  (-1)  1     1  (-1) (-1)  2  (-1)
	  (-1) (-1)   1    1  (-1) (-1)  2];
	
  d(:,:,2) = [ sqrt(voxel_size(1)^2 + voxel_size(2)^2)  voxel_size(2)   sqrt(voxel_size(1)^2 + voxel_size(2)^2)
               voxel_size(1)                               0             voxel_size(1) 
	       sqrt(voxel_size(1)^2 + voxel_size(2)^2)  voxel_size(2)   sqrt(voxel_size(1)^2 + voxel_size(2)^2)]; 
  d(:,:,1) = sqrt(d(:,:,2).*d(:,:,2) + voxel_size(3)^2);
  d(:,:,3) = d(:,:,1);
  d(2,2,2) = 0.1;
  d = 1./d;
  d(2,2,2) = 0;
  
  pve(4,1) = 4;   % remember that we need to have BG label, BG label is numbered 4 in class_params (but 1 in inter!)
  pve(4,2) = 1;  
  pve(5,1) = 1;
  pve(5,2) = 2;
  pve(6,1) = 2;
  pve(6,2) = 3;
  
  sz = size(img);
  % check the limits 
  seg = zeros(sz + 2); % this to simplify the icm if/when there are non-background voxels in the image boundaries 
  for i = 1:6  
    cvalpdf(:,:,:,i) = zeros(sz); 
  end
  for i = 1:3  
    cvalpdf(:,:,:,i) = (1/(sqrt(2*pi*class_params{i}.var)))*...
                       exp(-(img - class_params{i}.mu).^2/(2*class_params{i}.var));
  end
  for i = 1:3 
    mutmp(1) = class_params{pve(3 + i,1)}.mu;
    mutmp(2) = class_params{pve(3 + i,2)}.mu;
    vartmp(1) = class_params{pve(3 + i,1)}.var;
    vartmp(2) = class_params{pve(3 + i,2)}.var; 
    % According to a composite Simpson's rule with 10 equally spaced 
    % intervals
    % t = 0
    cvalpdf(:,:,:,3 + i) =  cvalpdf(:,:,:,3 + i) + ...
	 (1/30)*(1/sqrt(2*pi*(vartmp(2))))* ...
	 exp(-(img - ...
	 mutmp(2)).^2/(2*(vartmp(2))));
    % t = 1
    cvalpdf(:,:,:,3 + i) =  cvalpdf(:,:,:,3 + i) + ...
	 (1/30)*(1/sqrt(2*pi*(vartmp(1))))* ...
	 exp(-(img - mutmp(1)).^2/(2*(vartmp(1))));
    % j is odd	 
    for t = 0.1:0.2:0.9
      cvalpdf(:,:,:,3 + i) =  cvalpdf(:,:,:,3 + i) + ...
	 (4/30)*(1/sqrt(2*pi*(t^2*vartmp(1) + (1 - t^2)*vartmp(2))))* ...
	 exp(-(img - t*mutmp(1) - (1 - ...
	 t)*mutmp(2)).^2/(2*(t^2*vartmp(1) + (1 - t^2)*vartmp(2))));
    end
    % j is even
    for t = 0.2:0.2:0.8
      cvalpdf(:,:,:,3 + i) =  cvalpdf(:,:,:,3 + i) + ...
	 (2/30)*(1/sqrt(2*pi*(t^2*vartmp(1) + (1 - t^2)*vartmp(2))))* ...
	 exp(-(img - t*mutmp(1) - (1 - ...
	 t)*mutmp(2)).^2/(2*(t^2*vartmp(1) + (1 - t^2)*vartmp(2))));
    end
  end 
  cvalpdf = log(cvalpdf); 
  
  [~,seg(2:(sz(1) + 1),2:(sz(2) + 1),2:(sz(3) + 1))] = max(cvalpdf,[],4);
  seg(2:(sz(1) + 1),2:(sz(2) + 1),2:(sz(3) + 1)) = seg(2:(sz(1) + 1),2:(sz(2) + 1),2:(sz(3) + 1)).*brain_mask;

  % seg_init = seg;
  cval = zeros(6,1);
  d2 = [d(:) d(:) d(:) d(:) d(:) d(:)]; 
  changed = 0;
  changelog = ones(size(seg));
  changelog(2:(sz(1) + 1),2:(sz(2) + 1),2:(sz(3) + 1)) = changelog(2:(sz(1) + 1),2:(sz(2) + 1),2:(sz(3) + 1)).*brain_mask;

 
  
  for t = 1:max_iterations   
    disp(['ICM iteration ' num2str(t) ' Changes ' num2str(changed)]);  
    changed = 0;
    for x = 2:(sz(1) + 1)
      for y = 2:(sz(2) + 1)
	for z = 2:(sz(3) + 1)
	  if changelog(x,y,z) 
	    if brain_mask(x - 1,y - 1,z - 1) > 0
	      seg_tmp = seg((x - 1):(x + 1),(y - 1):(y + 1),(z - 1):(z + ...
		 1)) + 1; 
              cval = squeeze(cvalpdf(x - 1,y - 1,z - 1,:))' + beta*(sum(d2.*inter(seg_tmp(:),2:7)));
              [tmp,maxc] = max(cval);
              voxel_change = (maxc ~= seg(x,y,z));
              if voxel_change
                changelog((x - 1):(x + 1),(y - 1):(y + 1),(z - 1):(z + 1)) = 1;  
                changed = changed + 1;
                seg(x,y,z) = maxc;
              end
              changelog(x,y,z) = 0;
            end  
	  end
        end	
      end  
    end
    if changed < 1
      break;
    end  
   
  end
  clear cvalpdf
  seg = seg(2:(sz(1) + 1), 2:(sz(2) + 1),2:(sz(3) + 1));
 
  % SUBFUNCTIONS
 
 % ******************************************************************** 
 % PARAMETER ESTIMATION
 % step 1: outlier detection 
 % step 2: parameter estimation using least trimmed squares 
 %         see P.J. Rousseeuw and A.M. Leroy: Robust Regression and Outlier Detection
 %             John Wiley & Sons 1987 for the O(Nlog(N)) algorithm
 % ********************************************************************
function [class_params] = estimate_parameters(img,brainind,tissue_class); 
 
 % B = zeros(3,3,3);
 % B(:,2,2) = 1;
 % B(2,:,2) = 1;
 % B(2,2,:) = 1;
 % Belements = 7;
  B = ones(3,3,3);
  Belements = 27;
  imgmax = max(img(:));
  imgmin = min(img(:));
  range = (imgmax - imgmin)/(2^16);
  
  for i = 1:3
    % step 1
    XeB = convn(tissue_class == i,B,'same');
    ind = find((XeB(brainind) == Belements)); 
   % len = length(ind2);
   % ind = ind2([1:2:len]);
    % step 2 
    data = sort(img(brainind(ind)) + 2*range*rand(length(ind),1) - range); % adding minute amount of noise
    n = length(data);
    h = n - floor(n/2);
    h2 = floor(n/2);
    old_sum = sum(data(1:h));
    old_power_sum = sum(data(1:h).*data(1:h));
    loc = old_sum/h;
    score = old_power_sum - old_sum*loc;
    best_score = score;
    best_loc = loc;
   
    for j = 1:h2
      old_sum = old_sum - data(j) + data(h + j);
      loc = old_sum/h;
      old_power_sum = old_power_sum - data(j)*data(j) + data(h + j)*data(h + j);
      score = old_power_sum - old_sum*loc;
      if score < best_score
        best_score = score;
        best_loc = loc;
      end
    end  
    class_params{i}.mu = best_loc;
    scaled_data = (data - best_loc).*((h - 1)/best_score).*(data - best_loc);  
    medd = median(scaled_data);
    class_params{i}.var = (best_score/(h - 1))*(medd/0.45493642311957);
  end
   
   % *************************************************
   % Incremental k-means algorithm
   % ************************************************'
 
function [tissue_class] = kmeansinc(img,ind);
    % compute gradient
    
     cimg = convn(img,ones(3,3,3)/27,'same');
     sz = size(img);
     gr_img = zeros(sz);
     gr_img(2:(sz(1) - 1),2:(sz(2) - 1),2:(sz(3) - 1)) = ...
       (cimg(3:sz(1),2:(sz(2) - 1),2:(sz(3) - 1)) - cimg(1:(sz(1) - 2),2:(sz(2) - 1),2:(sz(3) - 1))).^2 + ...  
       (cimg(2:(sz(1) - 1),3:(sz(2)),2:(sz(3) - 1)) - cimg(2:(sz(1) - 1),1:(sz(2) - 2),2:(sz(3) - 1))).^2 + ...
       (cimg(2:(sz(1) - 1),2:(sz(2) - 1),3:(sz(3))) - cimg(2:(sz(1) - 1),2:(sz(2) - 1),1:(sz(3) - 2))).^2;
         
     % ind = find(brain_mask(:) > 0);
     gr_img = sqrt(gr_img(ind)); 
     
     mgr = sum(gr_img(:))/length(ind);
     sgr = sqrt(sum((gr_img(:) -mgr).^2)/(length(ind) - 1));  
     ind2 = find((gr_img(:) < 2*sgr));
     data = img(ind(ind2));
     imgmax = max(data);
     imgmin = min(data);
     delta = (imgmax - imgmin)/255;
     cdata = imgmin + delta*(0:255);
     edges = cdata - delta/2;
     ndata = histc(data,edges);  
     % kmeans1d consumes very little time
     init = [(mean(data) - delta) (mean(data) + delta)];
     [c1,costfunctionvalue1] = kmeans1d(cdata',ndata,2,init,50);
     init = [(c1(1) - delta) (c1(1) + delta) c1(2)];
     [c2,costfunctionvalue2] = kmeans1d(cdata',ndata,3,init,50);
     init = [c1(1) (c1(2) - delta) (c1(2) + delta)];
     [c3,costfunctionvalue3] = kmeans1d(cdata',ndata,3,init,50);  
     
    % disp(t2)
     if costfunctionvalue2 < costfunctionvalue3 
       c = c2;
     else
       c = c3;	       
     end
     % check the consistency of the means   
     c = sort(c);  
     % classify voxels
     dist = zeros(length(ind),3);
     for i = 1:3
       dist(:,i) = (img(ind) - c(i)).^2;
     end
     [tmp,tissue_class_tmp] = min(dist,[],2);
     tissue_class = zeros(sz);
     tissue_class(ind) = tissue_class_tmp;
    %  tissue_class = reshape(tissue_class,sz).*brain_mask; 
     
     
     
 function [cen,costfunctionvalue] = kmeans1d(cdata,ndata,k,init,max_iter); 
  % t = cputime; 
    % Start the algorithm
   iter = 0;
   changes = 1;
   n = length(cdata);
   cen = init;
   datalabels = zeros(n,1);
   while (iter < max_iter) & changes
     iter = iter + 1;
     old_datalabels = datalabels;
     % Compute the distances between cluster centres and datapoints
     for i = 1:k
       dist(:,i) = (cdata - cen(i)).^2;
     end
     % Label data points based on the nearest cluster centre
     [tmp,datalabels] = min(dist,[],2);
     % compute the cost function value
     % costfunctionvalue = sum(tmp);
     % calculate the new cluster centres 
     for i = 1:k
       ind = find(datalabels == i);
       cen(i) = sum(ndata(ind).*cdata(ind))/sum(ndata(ind));
     end
     % study whether the labels have changed
     changes = sum(old_datalabels ~= datalabels);
   end
   for i = 1:k
     dist(:,i) = (cdata - cen(i)).^2;
   end
   [tmp,datalabels] = min(dist,[],2);
   % compute the cost function value
   costfunctionvalue = sum(ndata.*tmp);
 %  t2 = cputime;
 % disp(t2 - t)
  
  
