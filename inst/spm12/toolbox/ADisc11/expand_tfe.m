function [new_tfe,expand_dim] = expand_tfe(tfe)
%-------------------------------------------------------------------------
% function : expand the images contained in the input struct array when border
%            voxels were misslabeled into the brain region.  
% input : tfe : a struct array containing the tissue fraction estimates 
%              (aka partial volume estimates) as provided by e.g. pvemri.m 
%               or pvemrimex.m 
% output: new_tfe: new tfe file containing expanded tissue fraction images.
%         expand_dim: expansion parameters.
% modified 22nd June by Jussi Tohka (a bug fix)
%-------------------------------------------------------------------------

      

     [X,Y,Z] = size(tfe.wm);
     mask = (tfe.wm + tfe.csf + tfe.gm) > 0;
     expand_dim = zeros(3,2);
     if sum(sum(mask(1,:,:))) >0
       expand_dim(1,1) = 1;
     end
     if sum(sum(mask(X,:,:))) >0
       expand_dim(1,2) = 1;
     end  
     if sum(sum(mask(:,1,:))) >0
       expand_dim(2,1) = 1;
     end
     if sum(sum(mask(:,Y,:))) >0
       expand_dim(2,2) = 1;
     end
     if sum(sum(mask(:,:,1))) >0
       expand_dim(3,1) = 1;
     end

     if sum(sum(mask(:,:,Z))) >0
       expand_dim(3,2) = 1;
     end
     expand_dim(:,2) = expand_dim(:,1) + expand_dim(:,2);
     if sum(expand_dim(:)) == 0
       new_tfe = tfe;
     else
       new_tfe.csf = zeros(X + expand_dim(1,2),Y + expand_dim(2,2),Z + expand_dim(3,2));
       new_tfe.csf((1 + expand_dim(1,1)):(X + expand_dim(1,1)), (1 + expand_dim(2,1)):(Y + expand_dim(2,1)),(1 + expand_dim(3,1)):(Z + expand_dim(3,1))) = tfe.csf; 
       new_tfe.gm = zeros(X + expand_dim(1,2),Y + expand_dim(2,2),Z + expand_dim(3,2));
       new_tfe.gm((1 + expand_dim(1,1)):(X + expand_dim(1,1)), (1 + expand_dim(2,1)):(Y + expand_dim(2,1)),(1 + expand_dim(3,1)):(Z + expand_dim(3,1))) = tfe.gm; 
       new_tfe.wm = zeros(X + expand_dim(1,2),Y + expand_dim(2,2),Z + expand_dim(3,2));
       new_tfe.wm((1 +expand_dim(1,1)):(X + expand_dim(1,1)),(1 + expand_dim(2,1)):(Y + expand_dim(2,1)),(1 + expand_dim(3,1)):(Z + expand_dim(3,1))) = tfe.wm; 
     end

     

       

