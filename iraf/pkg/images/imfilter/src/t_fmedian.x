# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <error.h>
include "fmedian.h"

# T_FMEDIAN -- Median filter a list of images in x and y.

procedure t_fmedian()

bool	verbose
long	xwindow, ywindow
int	boundary
pointer	list1, list2
pointer	sp, imtlist1, imtlist2, image1, image2, imtemp, str, fmd, im1, im2
real	constant
size_t	sz_val
long	c_2

bool	clgetb(), fp_equalr()
int	clgeti(), imtgetim(), imtlen(), clgwrd(), btoi()
long	clgetl()
pointer	imtopen(), immap()
real	clgetr()
long	lmod()
errchk	fmd_medbox
include	<nullptr.inc>

begin
	c_2 = 2
	# Allocate some working space.
	call smark (sp)
	sz_val = SZ_LINE
	call salloc (imtlist1, sz_val, TY_CHAR)
	call salloc (imtlist2, sz_val, TY_CHAR)
	sz_val = SZ_FNAME
	call salloc (image1, sz_val, TY_CHAR)
	call salloc (image2, sz_val, TY_CHAR)
	call salloc (imtemp, sz_val, TY_CHAR)
	sz_val = SZ_LINE
	call salloc (str, sz_val, TY_CHAR)

	# Allcoate space for the fmedian structure.
	sz_val = LEN_FMEDIAN_STRUCT
	call calloc (fmd, sz_val, TY_STRUCT)

	# Get the task parameters.
	call clgstr ("input", Memc[imtlist1], SZ_FNAME)
	call clgstr ("output", Memc[imtlist2], SZ_FNAME)

	# Get the window size.
	xwindow = clgetl ("xwindow")
	ywindow = clgetl ("ywindow")

	# Get the quantization parameters.
	FMED_Z1(fmd) = clgetr ("zmin")
	FMED_Z2(fmd) = clgetr ("zmax")
	FMED_ZLOW(fmd) = clgetr ("zloreject")
	FMED_ZHIGH(fmd) = clgetr ("zhireject")
	FMED_HMIN(fmd) = clgeti ("hmin")
	FMED_HMAX(fmd) = clgeti ("hmax")
	FMED_UNMAP(fmd) = btoi (clgetb ("unmap"))

	# Get the boundary extension parameters.
	boundary = clgwrd ("boundary", Memc[str], SZ_LINE,
	    ",constant,nearest,reflect,wrap,")
	constant = clgetr ("constant")
	verbose = clgetb ("verbose")

	# Open the input and output image lists.
	list1 = imtopen (Memc[imtlist1])
	list2 = imtopen (Memc[imtlist2])
	if (imtlen (list1) != imtlen (list2)) {
	    call imtclose (list1)
	    call imtclose (list2)
	    call error (0, "Number of input and output images not the same.")
	}

	# Median filter each set of input and output images.
	while ((imtgetim (list1, Memc[image1], SZ_FNAME) != EOF) &&
	      (imtgetim (list2, Memc[image2], SZ_FNAME) != EOF)) {
	    
	    call xt_mkimtemp (Memc[image1], Memc[image2], Memc[imtemp],
	        SZ_FNAME)

	    im1 = immap (Memc[image1], READ_ONLY, NULLPTR)
	    im2 = immap (Memc[image2], NEW_COPY, im1)

	    if (lmod (xwindow, c_2) == 0)
	        FMED_XBOX(fmd) = xwindow + 1
	    else
	        FMED_XBOX(fmd) = xwindow
	    if (lmod (ywindow, c_2) == 0)
	        FMED_YBOX(fmd) = ywindow + 1
	    else
	        FMED_YBOX(fmd) = ywindow

	    if (verbose) {
		call printf ("%dx%d Box median filter %s to %s\n")
		    call pargz (FMED_XBOX(fmd))
		    call pargz (FMED_YBOX(fmd))
		    call pargstr (Memc[image1])
		    call pargstr (Memc[imtemp])
		call flush (STDOUT)
	    }

	    # Find input image max and min if necessary.
	    if (IS_INDEFR(FMED_Z1(fmd)) || IS_INDEFR(FMED_Z2(fmd))) 
	        call fmd_maxmin (im1, FMED_XBOX(fmd), FMED_YBOX(fmd),
		    boundary, constant, FMED_ZMIN(fmd), FMED_ZMAX(fmd))

	    if (verbose) {
		if (! fp_equalr (FMED_Z1(fmd), real(FMED_HMIN(fmd))) &&
		    ! fp_equalr (FMED_Z2(fmd), real(FMED_HMAX(fmd)))) {
		    call printf (
		  "    Pixels from %g to %g mapped to integers from %d to %d\n")
		        if (IS_INDEFR(FMED_Z1(fmd))) 
			    call pargr (FMED_ZMIN(fmd))
		        else
			    call pargr (FMED_Z1(fmd))
		        if (IS_INDEFR(FMED_Z2(fmd))) 
			    call pargr (FMED_ZMAX(fmd))
		        else
			    call pargr (FMED_Z2(fmd))
		        call pargi (FMED_HMIN(fmd))
		        call pargi (FMED_HMAX(fmd))
		}
		if (! IS_INDEFR(FMED_ZLOW(fmd)) ||
		    ! IS_INDEFR(FMED_ZHIGH(fmd)))  {
		    call printf (
		    "    Pixels < %g or > %g excluded from the median filter\n")
			call pargr (FMED_ZLOW(fmd))
			call pargr (FMED_ZHIGH(fmd))
		}
		call flush (STDOUT)
	    }

	    # Median filter the image.
	    iferr {
		call fmd_medbox (fmd, im1, im2, boundary, constant)
	    } then {
		call eprintf ("Error median filtering image: %s\n")
		    call pargstr (Memc[image1])
		call erract (EA_WARN)
		call imunmap (im1)
		call imunmap (im2)
		call imdelete (Memc[image2])
	    } else {
	        call imunmap (im1)
	        call imunmap (im2)
	        call xt_delimtemp (Memc[image2], Memc[imtemp])
	    }
	}

	call imtclose (list1)
	call imtclose (list2)

	call mfree (fmd, TY_STRUCT)

	call sfree (sp)
end
