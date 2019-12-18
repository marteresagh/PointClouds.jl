# """
# # Input
# # X        Array [x y z] where x = vector of x-coordinates,
# #          y = vector of y-coordinates and z = vector of z-coordinates.
# #          Dimension: m x 3.
# #
# # x0       Estimate of the torus centre.
# #          Dimension: 3 x 1.
# #
# # a0       Estimate of the direction cosines.
# #          The major circle of the torus is estimated to lie in
# #          the plane (x - x0)' * a = 0.
# #          Dimension: 3 x 1.
# #
# # r0       Estimate of the major radius.
# #          Dimension: 1 x 1.
# #
# # s0       Estimate of the minor radius.
# #          Dimension: 1 x 1.
# #
# # tolp     Tolerance for test on step length.
# #          Dimension: 1 x 1.
# #
# # tolg     Tolerance for test on gradient.
# #          Dimension: 1 x 1.
# #
# # <Optional...
# # w        Weights.
# #          Dimension: m x 1.
# # ...>
# #
# # Output
# # x0n      Estimate of the torus centre.
# #          Dimension: 3 x 1.
# #
# # a0       Estimate of the direction cosines.
# #          The major circle of the torus is estimated to lie in
# #          the plane (x - x0)' * a = 0.
# #          Dimension: 3 x 1.
# #
# # r0       Estimate of the major radius.
# #          Dimension: 1 x 1.
# #
# # s0       Estimate of the minor radius.
# #          Dimension: 1 x 1.
# #
# # d        Array of weighted distances:
# #          d(i) = w(i) * d(x_i, T),
# #          where d(x, T) is the orthogonal distance of the point
# #          x from the torus T.
# #          Dimension: mX x 1.
# #
# # sigmah   Estimate of the standard deviation of the weighted
# #          residual errors.
# #          Dimension: 1 x 1.
# #
# # conv     If conv = 1 the algorithm has converged,
# #          if conv = 0 the algorithm has not converged
# #          and x0n, rn, d, and sigmah are current estimates.
# #          Dimension: 1 x 1.
# #
# # Vx0n     Covariance matrix of torus centre.
# #          Dimension: 3 x 3.
# #
# # Van      Covariance matrix of direction cosines.
# #          Dimension: 3 x 3.
# #
# # urn      Uncertainty in major radius.
# #          Dimension: 1 x 1.
# #
# # usn      Uncertainty in minor radius.
# #          Dimension: 1 x 1.
# #
# # GNlog    Log of the Gauss-Newton iterations.
# #          Rows 1 to niter contain
# #          [iter, norm(f_iter), |step_iter|, |gradient_iter|].
# #          Row (niter + 1) contains
# #          [conv, norm(d), 0, 0].
# #          Dimension: (niter + 1) x 4.
# #
# # a        Optimisation parameters at the solution.
# #          Dimension: 7 x 1.
# #
# # R0       Fixed rotation matrix.
# #          Dimension: 3 x 3.
# #
# # R        Upper-triangular factor of the Jacobian matrix
# #          at the solution.
# #          Dimension: 7 x 7.
# #
# # Modular structure: NLSS11.M, GNCC2.M, FGTORUS.M, ROT3Z.M, GR.M,
# #                    FGRROT3.M, FRROT3.M, DRROT3.M, FGBRRT3.M, CSR.M.
# #
# # [x0n, an, rn, sn, d, sigmah, conv, Vxn, Van, urn, usn, GNlog, u, R0, R] = ...
# #            lstorus(X, x0, a0, r0, s0, tolp, tolg <, w >)
# """
# function lstorus(points, x0, a0, r0, s0, tolp, tolg)
#
# # check number of data points
#   m = size(points, 2);
#   if m < 7
#     error('At least 7 data points required: ' )
#   end
# # find the centroid of the data
#   xb = Tesi.centroid(points)
#
# # transform the data to close to standard position via a rotation
# # followed by a translation
#   R0 = rot3z(a0); # R0 * a0 = [0 0 1]'
#   xb1 = R0 * xb;
#   x1 = R0 * x0;
#   X1 = (points' * R0');
# # find xp, the point on axis nearest the centroid of the rotated data
#   xp = x1 + (xb1[3] - x1[3]) * [0 0 1]';
# # translate data, mapping xp to the origin
#   X2 = X1 - ones(m, 1) * xp';
#   x2 = x1 - xp;
# #
#   ai = [x0' 0 0 r0 s0]';
#   tol = [tolp; tolg]';
# #
# # Gauss-Newton algorithm to find estimate of roto-translation
# # parameters that transform the data so that the best-fit circle
# # is one in standard position
#   a, d, R, GNlog = nlss11(ai, tol, 'fgtorus', X2, w);
# #
#   R3, DR1, DR2, DR3 = fgrrot3([a[4] a[5] 0]');
#   x0n = R0' * (xp + [a[1] a[2] a[3]]');
#   an = R0' * (R3' * [0 0 1]');
#   rn = a[6];
#   sn = a[7];
# #
#   nGN = size(GNlog, 1);
#   conv = GNlog(nGN, 1);
#   if conv == 0
#     warning('*** Gauss-Newton algorithm has not converged ***');
#   end # if conv
# #
# # # calculate statistics
# #   dof = m - 7;
# #   sigmah = norm(d)/sqrt(dof);
# #   G = zeros(8, 7);
# # # derivatives of x0n
# #   G(1:3, 1) = R0' * [1 0 0]';
# #   G(1:3, 2) = R0' * [0 1 0]';
# #   G(1:3, 3) = R0' * [0 0 1]';
# # # derivatives of an
# #   G(4:6, 4) = R0' * DR1' * [0 0 1]';
# #   G(4:6, 5) = R0' * DR2' * [0 0 1]';
# # # derivatives of rn
# #   G(7, 6) = 1;
# # # derivatives of sn
# #   G(8, 7) = 1;
# #   Gt = R'\(sigmah * G'); # R' * Gt = sigmah * G'
# #   Va = Gt'*Gt;
# #   Vx0n = Va(1:3, 1:3); # covariance matrix for x0n
# #   Van = Va(4:6, 4:6); # covariance matrix for a0n
# #   urn = sqrt(Va(7, 7)); # uncertainty in rn
# #   usn = sqrt(Va(8, 8)); # uncertainty in sn
#
#   return x0n, an, rn, sn, d, sigmah, conv, Vx0n, Van, urn, usn, GNlog, a, R0, R
# end
#
#
#
# """
# # Input
# # a        Vector.
# #          Dimension: 3 x 1.
# #
# # Output
# # U        Rotation matrix with U * a = [0 0 z]', z > 0.
# #          Dimension: 3 x 3.
# #
# # Modular structure: GR.M.
# #
# # [U] = rot3z(a)
# """
#
# function rot3z(a)
#
# # form first Givens rotation
#   W, c1, s1 = gr(a[2], a[3]);
#   z = c1*a[2] + s1*a[3];
#   V = [1. 0 0; 0 s1 -c1; 0 c1 s1];
#
# # form second Givens rotation
#   W, c2, s2 = gr(a[1], z);
#
# # check positivity
#   if c2 * a[1] + s2 * z < 0
#     c2 = -c2;
#     s2 = -s2;
#   end
#
#   W = [s2 0 -c2; 0 1 0; c2 0 s2];
#   U = W * V;
#   return U
# end
#
# """
# # --------------------------------------------------------------------------
# # GR.M   Form Givens plane rotation.
# #
# # Version 1.0
# # Last amended   I M Smith 27 May 2002.
# # Created        I M Smith 08 Mar 2002
# # --------------------------------------------------------------------------
# # Input
# # x        Scalar.
# #          Dimension: 1 x 1.
# #
# # y        Scalar.
# #          Dimension: 1 x 1.
# #
# # Output
# # U        Rotation matrix [c s; -s c], with U * [x y]' = [z 0]'.
# #          Dimension: 2 x 2.
# #
# # c        Cosine of the rotation angle.
# #          Dimension: 1 x 1.
# #
# # s        Sine of the rotation angle.
# #          Dimension: 1 x 1.
# #
# # [U, c, s] = gr(x, y)
# # --------------------------------------------------------------------------
#
# """
# function  gr(x, y)
# # form sine and cosine: s and c
#   if y == 0
#     c = 1;
#     s = 0;
#   elseif  abs(y) >= abs(x)
#     t = x/y;
#     s = 1/sqrt(1 + t*t);
#     c = t*s;
#   else
#     t = y/x;
#     c = 1/sqrt(1 + t*t);
#     s = t*c;
#   end
#   U = [c  s; -s  c];
#   return U, c, s
# end
#
#
#
# """
# # --------------------------------------------------------------------------
# # FGRROT3.M   Form rotation matrix R = R3*R2*R1*R0 and its derivatives
# #             using right-handed rotation matrices:
# #
# #             R1 = [ 1  0   0 ]  R2 = [ c2 0  s2 ] and R3 = [ c3 -s3 0 ]
# #                  [ 0 c1 -s1 ],      [ 0  1   0 ]          [ s3  c3 0 ].
# #                  [ 0 s1  c2 ]       [-s2 0  c2 ]          [  0   0 1 ]
# #
# # Version 1.0
# # Last amended   I M Smith 27 May 2002.
# # Created        I M Smith 08 Mar 2002
# # --------------------------------------------------------------------------
# # Input
# # theta    Array of plane rotation angles (t1, t2, t3).
# #          Dimension: 3 x 1.
# #
# # <Optional...
# # R0       Rotation matrix, optional, with default R0 = I.
# #          Dimension: 3 x 3.
# # ...>
# #
# # Output
# # R        Rotation matrix.
# #          Dimension: 3 x 3.
# #
# # <Optional...
# # DR1      Derivative of R wrt t1.
# #          Dimension: 3 x 3.
# #
# # DR2      Derivative of R wrt t2.
# #          Dimension: 3 x 3.
# #
# # DR3      Derivative of R wrt t3.
# #          Dimension: 3 x 3.
# # ...>
# #
# # Modular structure: FRROT3.M, DRROT3.M.
# #
# # [R <, DR1, DR2, DR3 >] = fgrrot3(theta <, R0 >)
# # --------------------------------------------------------------------------
#
# """
# function  fgrrot3(theta, R0)
#
#   if isempty(R0)
#     R0 = Matrix(Lar.I,3,3);
#   end
# #
#   R, R1, R2, R3 = frrot3(theta, R0);
# #
# # Evaluate the derivative matrices if required.
#     dR1, dR2, dR3 = drrot3(R1, R2, R3);
#     DR1 = R3*R2*dR1*R0;
#     DR2 = R3*dR2*R1*R0;
#     DR3 = dR3*R2*R1*R0;
#
#   return R, DR1, DR2, DR3
# end
#
#
# """
# # --------------------------------------------------------------------------
# # FRROT3.M   Form rotation matrix R = R3*R2*R1*U0. - use right-handed
# #            rotation matrices.
# #
# # Version 1.0
# # Last amended   I M Smith 27 May 2002.
# # Created        I M Smith 08 Mar 2002
# # --------------------------------------------------------------------------
# # Input
# # theta    Array of plane rotation angles (t1, t2, t3).
# #          Dimension: 3 x 1.
# #
# # <Optional...
# # U0       Rotation matrix, optional, with default R0 = I.
# #          Dimension: 3 x 3.
# # ...>
# #
# # Output
# # R        Rotation matrix.
# #          Dimension: 3 x 3.
# #
# # R1       Plane rotation [1 0 0; 0 c1 -s1; 0 s1 c1].
# #	       Dimension: 3 x 3.
# #
# # <Optional...
# # R2       Plane rotation [c2 0 s2; 0 1 0; -s2 0 c2].
# #          Dimension: 3 x 3.
# #
# # R3       Plane rotation [c3 -s3 0; s3 c3 0; 0 0 1].
# #          Dimension: 3 x 3.
# # ...>
# #
# # [R, R1 <, R2, R3 >] = frrot3(theta <, U0 >)
# # --------------------------------------------------------------------------
# """
# function frrot3(theta, U0)
#
#   ct = cos(theta);
#   st = sin(theta);
# #
#   if length(theta) > 0
#     R1 = [ 1 0 0; 0 ct(1) -st(1); 0 st(1) ct(1)];
#     R = R1;
#   end #if
# #
#   if length(theta) > 1
#     R2 = [ ct(2) 0 st(2); 0 1 0; -st(2) 0 ct(2)];
#     R = R2*R;
#   end # if
# #
#   if length(theta) > 2
#     R3 = [ ct(3) -st(3) 0; st(3) ct(3) 0; 0 0 1];
#     R = R3*R;
#    end # if
# #
#   if !isempty(U0)
#     R = R*U0;
#   end # if
#   return R, R1, R2, R3
# end
#
# """
# # --------------------------------------------------------------------------
# # DRROT3.M   Calculate the derivatives of plane rotations -
# #            use right-handed rotation matrices.
# #
# # Version 1.0
# # Last amended   I M Smith 27 May 2002.
# # Created        I M Smith 08 Mar 2002
# # --------------------------------------------------------------------------
# # Input
# # R1       Plane rotation of the form
# #          [1 0 0; 0 c1 -s1; 0 s1 c1].
# #          Dimension: 3 x 3.
# #
# # <Optional...
# # R2       Plane rotation of the form
# #          [c2 0 s2; 0 1 0; -s2 0 c2].
# #          Dimension: 3 x 3.
# #
# # R3       Plane rotation of the form
# #          [c3 -s3 0; s3 c3 0; 0 0 1].
# #          Dimension: 3 x 3.
# # ...>
# #
# # Output
# # dR1      Derivative of R1 with respect to rotation angle.
# #          [0 0 0; 0 -s1 -c1; 0 c1 -s1].
# #          Dimension: 3 x 3.
# #
# # <Optional...
# # dR2      Derivative of R2 with respect to rotation angle.
# #          [-s2 0 c2; 0 0 0; -c2 0 -s2].
# #          Dimension: 3 x 3.
# #
# # dR3      Derivative of R3 with respect to rotation angle.
# #          [-s3 -c3 0; c3 -s3 0; 0 0 0].
# #          Dimension: 3 x 3.
# # ...>
# #
# # [dR1 <, dR2, dR3 >] = drrot3(R1 <, R2, R3 >)
# # --------------------------------------------------------------------------
#
# """
# function drrot3(R1, R2, R3)
#
#   if isempty(R2) && isempty(R3)
#     dR1 = [0 0 0; 0 -R1[3, 2] -R1[2, 2]; 0 R1[2, 2] -R1[3, 2]];
#
#   elseif isempty(R3)
#     dR2 = [-R2[1, 3] 0 R2[1, 1]; 0 0 0; -R2[1, 1] 0 -R2[1, 3]];
#
#   else
#     dR3 = [-R3[2, 1] -R3[1, 1] 0; R3[1, 1] -R3[2, 1] 0; 0 0 0];
#   end
#
#   return dR1, dR2, dR3
# end
#
#
# """
# # Input
# # a        Parameters [x0 y0 z0 theta1 theta2 rb sb]'.
# #          Dimension: 7 x 1.
# #
# # X        Array [x y z] where x = vector of x-coordinates,
# #          y = vector of x-coordinates and z = vector of y-coordinates.
# #          Dimension: m x 3.
# #
# # <Optional...
# # w        Weights.
# #          Dimension: m x 1.
# # ...>
# #
# # Output
# # f        Distances of points to the torus.
# #          Dimension: m x 1.
# #
# # <Optional...
# # J        Jacobian matrix df(i)/da(j).
# #          Dimension: m x 7.
# # ...>
# #
# # Modular structure: FGBRRT3.M, FGRROT3.M, FRROT3.M, DRROT3.M, CSR.M.
# #
# # [f <, J >] = fgtorus(a, X <, w >)
# # ---------------------------------------------------------------------
# """
# function [f, J] = fgtorus(a, X)
#
# # check number of data points
#   m = size(X, 2);
#   if m < 7
#     return nothing, nothing
#   end
#
#   tt = [a[1:5]; 0];
#   r0 = a[6];
#   s0 = a[7];
# #
#
#   Xb, Jx, Jy, Jz = fgbrrt3(tt, X);
#
# #
#   x = Xb[:,1];
#   y = Xb[:,2];
#   z = Xb[:,3];
# #
#   c, s, r = csr(x, y);
#   e = r - r0;
#   d = z;
#   cg, sg, g = csr(e, d);
# #
#   f = g - s0;
#   f = w.*f; # incorporate weights
# #
#   if nargout > 1 # form the Jacobian matrix
#     N = [c.*cg, s.*cg, sg];
#     for k = 1:5
#       J(:, k) = (w .* Jx(:, k)) .* N(:, 1) + (w .* Jy(:, k)) .* N(:, 2) + (w .* Jz(:, k)) .* N(:, 3);
#     end # for k
#     J(:, 6) = - cg .* w;
#     J(:, 7) = - w;
#  end # if nargout
# # ---------------------------------------------------------------------
# # End of FGTORUS.M.
