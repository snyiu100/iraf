include	<math/nlfit.h>
include	<pkg/inlfit.h>


# IN_REFIT -- Refit a function. This procedure is analogous to in_fit(),
# except that this one does not initialize the weigths and the rejected
# point list, and it does not reject points after the fit, because it is
# intended to be called from the data rejection procedure.

procedure in_refitr (in, nl, x, y, wts, npts, nvars, wtflag)

pointer	in				# INLFIT pointer
pointer	nl				# NLFIT pointer
real	x[ARB]				# Ordinates
real	y[npts]				# Data to be fit
real	wts[npts]			# Weights
int	npts				# Number of points
int	nvars				# Number of variables
int	wtflag				# Type of weighting

int	i, ier
pointer	rejpts
pointer	in_getp()

begin
#	# Debug
#	call eprintf ("in_refit: in=%d, nl=%d, npts=%d, nvars=%d\n")
#	    call pargi (in)
#	    call pargi (nl)
#	    call pargi (npts)
#	    call pargi (nvars)

	# Check number of data points.
	if (npts == 0) {
	    call in_puti (in, INLFITERROR, NO_DEG_FREEDOM)
	    return
	}

	# Assign a zero weight to each rejected point.
	rejpts = in_getp (in, INLREJPTS)
	do i = 1, npts {
	    if (Memi[rejpts+i-1] == YES)
		wts[i] = real (0.0)
	}

	# Reinitialize NLFIT and refit.
	call in_nlinitr (in, nl)
	call nlfitr (nl, x, y, wts, npts, nvars, wtflag, ier)

	# Store fit status in the INLFIT structure.
	call in_puti (in, INLFITERROR, ier)
end
