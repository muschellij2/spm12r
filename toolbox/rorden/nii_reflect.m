function [hdr, orient] = nii_reflect(hdr, tolerance)

   orient = [1 2 3];
   affine_transform = 1;

      R = [hdr.hist.srow_x(1:3)
           hdr.hist.srow_y(1:3)
           hdr.hist.srow_z(1:3)];

      T = [hdr.hist.srow_x(4)
           hdr.hist.srow_y(4)
           hdr.hist.srow_z(4)];

         
      if det(R) == 0 | ~isequal(R(find(R)), sum(R)')
         
         disp('Fine Change');
          hdr.hist.old_affine = [ [R;[0 0 0]] [T;1] ];
         R_sort = sort(abs(R(:)));
         R_sort
         R( find( abs(R) < tolerance*min(R_sort(end-2:end)) ) ) = 0;
         hdr.hist.new_affine = [ [R;[0 0 0]] [T;1] ];

         if det(R) == 0 | ~isequal(R(find(R)), sum(R)')
            msg = [char(10) char(10) '   Non-orthogonal rotation or shearing '];
            msg = [msg 'found inside the affine matrix' char(10)];
            msg = [msg '   in this NIfTI file. You have 3 options:' char(10) char(10)];
            msg = [msg '   1. Using included ''reslice_nii.m'' program to reslice the NIfTI' char(10)];
            msg = [msg '      file. I strongly recommand this, because it will not cause' char(10)];
            msg = [msg '      negative effect, as long as you remember not to do slice' char(10)];
            msg = [msg '      time correction after using ''reslice_nii.m''.' char(10) char(10)];
            msg = [msg '   2. Using included ''load_untouch_nii.m'' program to load image' char(10)];
            msg = [msg '      without applying any affine geometric transformation or' char(10)];
            msg = [msg '      voxel intensity scaling. This is only for people who want' char(10)];
            msg = [msg '      to do some image processing regardless of image orientation' char(10)];
            msg = [msg '      and to save data back with the same NIfTI header.' char(10) char(10)];
            msg = [msg '   3. Increasing the tolerance to allow more distortion in loaded' char(10)];
            msg = [msg '      image, but I don''t suggest this.' char(10) char(10)];
            msg = [msg '   To get help, please type:' char(10) char(10) '   help reslice_nii.m' char(10)];
            msg = [msg '   help load_untouch_nii.m' char(10) '   help load_nii.m'];
            error(msg);
         end
      end

   if affine_transform == 1
      voxel_size = abs(sum(R,1));
      R
      voxel_size
      inv_R = inv(R);
      originator = inv_R*(-T)+1;
      orient = get_orient(inv_R);

      %  modify pixdim and originator
      %
      hdr.dime.pixdim(2:4) = voxel_size;
      hdr.hist.originator(1:3) = originator;

      %  set sform or qform to non-use, because they have been
      %  applied in xform_nii
      %
      hdr.hist.qform_code = 0;
      hdr.hist.sform_code = 0;
   end

   %  apply space_unit to pixdim if not 1 (mm)
   %
   space_unit = get_units(hdr);

   if space_unit ~= 1
      hdr.dime.pixdim(2:4) = hdr.dime.pixdim(2:4) * space_unit;

      %  set space_unit of xyzt_units to millimeter, because
      %  voxel_size has been re-scaled
      %
      hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,1,0));
      hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,2,1));
      hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,3,0));
   end

   hdr.dime.pixdim = abs(hdr.dime.pixdim);

   return;					% change_hdr


%-----------------------------------------------------------------------
function orient = get_orient(R)

   orient = [];

   for i = 1:3
      switch find(R(i,:)) * sign(sum(R(i,:)))
      case 1
         orient = [orient 1];		% Left to Right
      case 2
         orient = [orient 2];		% Posterior to Anterior
      case 3
         orient = [orient 3];		% Inferior to Superior
      case -1
         orient = [orient 4];		% Right to Left
      case -2
         orient = [orient 5];		% Anterior to Posterior
      case -3
         orient = [orient 6];		% Superior to Inferior
      end
   end

   return;					% get_orient


%-----------------------------------------------------------------------
function [space_unit, time_unit] = get_units(hdr)

   switch bitand(hdr.dime.xyzt_units, 7)	% mask with 0x07
   case 1
      space_unit = 1e+3;		% meter, m
   case 3
      space_unit = 1e-3;		% micrometer, um
   otherwise
      space_unit = 1;			% millimeter, mm
   end

   switch bitand(hdr.dime.xyzt_units, 56)	% mask with 0x38
   case 16
      time_unit = 1e-3;			% millisecond, ms
   case 24
      time_unit = 1e-6;			% microsecond, us
   otherwise
      time_unit = 1;			% second, s
   end

   return;					% get_units

