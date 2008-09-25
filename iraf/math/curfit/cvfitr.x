# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <math/curfit.h>

include "curfitdef.h"

# CVFIT -- Procedure to add a set of points to the normal equations.
# The inner products of the basis functions are calculated and
# accumulated into the CV_ORDER(cv) by CV_NCOEFF(cv) matrix MATRIX.
# The main diagonal of the matrix is stored in the first row of
# MATRIX followed by the remaining non-zero diagonals. This method
# of storage is particularly efficient for the large symmetric
# banded matrices produced during spline fits. The inner product
# of the basis functions and the data ordinates are stored in the
# CV_NCOEFF(cv)-vector VECTOR. The array LEFT is
# used for the indices describing which elements of MATRIX and VECTOR are
# to receive the inner products. After accumulation is complete
# the Cholesky factorization of MATRIX is calculated and stored
# in the CV_ORDER(cv) by CV_NCOEFF(cv) matrix CHOFAC. Finally
# the coefficients are calculated by forward and back substitution
# and placed in COEFF.

procedure cvfit (cv, x, y, w, npts, wtflag, ier)

pointer	cv		# curve descriptor
real	x[npts]		# array of abcissa
real	y[npts]		# array of ordinates
real	w[npts]		# array of weights
size_t	npts		# number of data points
int	wtflag		# type of weighting
int	ier		# error code


begin

	# zero the appropriate arrays
	call cvzero (cv)

	# enter data points
	call cvacpts (cv, x, y, w, npts, wtflag)

	# solve the system
	call cvsolve (cv, ier)

end
