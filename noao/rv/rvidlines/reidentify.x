include	<error.h>
include	<imhdr.h>
include	<gset.h>
include	"identify.h"

define	HELP		"noao$onedspec/identify/identify.key"
define	RVHELP		"noao$rv/rvidlines/rvidlines.key"
define	ICFITHELP	"noao$lib/scr/idicgfit.key"
define	PROMPT		"identify options"

define	PAN		1	# Pan graph
define	ZOOM		2	# Zoom graph

# REIDENTIFY -- Reidentify features in an image.

procedure reidentify (id)

pointer	id			# ID pointer

real	wx, wy, wx2, wy2
int	wcs, key
char	cmd[SZ_LINE]

char	newimage[SZ_FNAME]
int	i, j, last, all, prfeature, nfeatures1, npeaks, ftype
double	pix, fit, user, shift, pix_shift, z_shift, xg[10]
pointer	peaks, label

int	clgcur(), scan(), nscan(), find_peaks(), errcode()
double	id_center(), fit_to_pix(), id_fitpt()
double	id_shift(), id_rms()
errchk	id_graph()

define	newim_		10
define	newkey_		20
define	beep_		99

begin
	# Initialize.
	ID_GTYPE(id) = PAN
	all = 0
	last = ID_CURRENT(id)
	newimage[1] = EOS
	ID_REFIT(id) = NO
	ID_NEWFEATURES(id) = NO
	ID_NEWCV(id) = NO
	wy = INDEF
	key = 'r'

	repeat {
	    prfeature = YES
	    if (all != 0)
		all = mod (all + 1, 3)

	    switch (key) {
	    case '?':	# Print help
		if (ID_TASK(id) == IDENTIFY)
		    call gpagefile (ID_GP(id), HELP, PROMPT)
		else
		    call gpagefile (ID_GP(id), RVHELP, PROMPT)
	    case ':':	# Process colon commands
		if (cmd[1] == '/')
		    call gt_colon (cmd, ID_GP(id), ID_GT(id), ID_NEWGRAPH(id))
		else
		    call id_colon (id, cmd, newimage, prfeature)
	    case ' ':	# Go to current feature
	    case '.':	# Go to nearest feature
		if (ID_NFEATURES(id) == 0)
		    goto beep_
		call id_nearest (id, double (wx))
	    case '-':	# Go to previous feature
		if (ID_CURRENT(id) == 1)
		    goto beep_
		ID_CURRENT(id) = ID_CURRENT(id) - 1
	    case '+', 'n':	# Go to next feature
		if (ID_CURRENT(id) == ID_NFEATURES(id))
		    goto beep_
		ID_CURRENT(id) = ID_CURRENT(id) + 1
	    case 'a':	# Set all flag for next key
		all = 1
	    case 'b':	# Mark blended features
		i = 1
		fit = wx
		xg[i] = fit_to_pix (id, fit)
		call printf ("mark other components (exit with 'q'):")
		while (clgcur ("cursor", wx, wy, wcs, key, cmd, SZ_LINE)!=EOF) {
		    if (key == 'q')
			break
		    i = i + 1
		    fit = wx
		    xg[i] = fit_to_pix (id, fit)
		    if (i == 10)
			break
		}

		call printf ("mark two background points: ")
		j = clgcur ("cursor", wx, wy, wcs, key, cmd, SZ_LINE)
		j = clgcur ("cursor", wx2, wy2, wcs, key, cmd, SZ_LINE)
		wx = fit_to_pix (id, double (wx))
		wx2 = fit_to_pix (id, double (wx2))

		switch (ID_FTYPE(id)) {
		case EMISSION:
		    ftype = GEMISSION
		case ABSORPTION:
		    ftype = GABSORPTION
		default:
		    ftype = ID_FTYPE(id)
		}
		iferr (call id_gcenter (id, xg, i, wx, wy, wx2, wy2,
		    ID_FWIDTH(id), ftype, YES)) {
		    call erract (EA_WARN)
		    prfeature = NO
		    goto newkey_
		}
		
		do j = 1, i {
		    pix = xg[j]
		    fit = id_fitpt (id, pix)
		    user = fit
		    call id_newfeature (id, pix, fit, user, 1.0D0,
			ID_FWIDTH(id), ftype, NULL)
		    USER(id,ID_CURRENT(id)) = INDEFD
		    call id_match (id, FIT(id,ID_CURRENT(id)),
			USER(id,ID_CURRENT(id)),
			Memi[ID_LABEL(id)+ID_CURRENT(id)-1],
			ID_MATCH(id), ID_REDSHIFT(id))
		    call id_mark (id, ID_CURRENT(id))
		    call printf ("%10.2f %10.8g ")
			call pargd (PIX(id,ID_CURRENT(id)))
			call pargd (FIT(id,ID_CURRENT(id)))
		    if (ID_REDSHIFT(id) != 0.) {
			call printf ("%10.8g ")
			    call pargd (FIT(id,ID_CURRENT(id)) /
				(1 + ID_REDSHIFT(id)))
		    }
		    call printf ("(%10.8g %s): ")
			call pargd (USER(id,ID_CURRENT(id)))
			label = Memi[ID_LABEL(id)+ID_CURRENT(id)-1]
			if (label != NULL)
			    call pargstr (Memc[label])
			else
			    call pargstr ("")
		    call flush (STDOUT)
		    if (scan() != EOF) {
			call gargd (user)
			call gargwrd (cmd, SZ_LINE)
			i = nscan()
			if (i > 0) {
			    USER(id,ID_CURRENT(id)) = user
			    fit = user * (1 + ID_REDSHIFT(id))
			    call id_match (id, fit, USER(id,ID_CURRENT(id)),
				Memi[ID_LABEL(id)+ID_CURRENT(id)-1],
				ID_MATCH(id), ID_REDSHIFT(id))
			}
			if (i > 1) {
			    call reset_scan ()
			    call gargd (user)
			    call gargstr (cmd, SZ_LINE)
			    call id_label (cmd,
				Memi[ID_LABEL(id)+ID_CURRENT(id)-1])
			}
		    }
		}
	    case 'c':	# Recenter features
		if (all != 0) {
		    for (i = 1; i <= ID_NFEATURES(id); i = i + 1) {
		        call gseti (ID_GP(id), G_PLTYPE, 0)
		        call id_mark (id, i)
		        call gseti (ID_GP(id), G_PLTYPE, 1)
			FWIDTH(id,i) = ID_FWIDTH(id)
		        PIX(id,i) = id_center (id, PIX(id,i), 1, FWIDTH(id,i),
			    FTYPE(id,i), NO)
		        if (!IS_INDEFD (PIX(id,i))) {
			    FIT(id,i) = id_fitpt (id, PIX(id,i))
		            call id_mark (id, i)
			} else {
			    call id_delete (id, i)
			    i = i - 1
		        }
		    }
		    ID_NEWFEATURES(id) = YES
		} else {
		    if (ID_NFEATURES(id) < 1)
			goto beep_
		    call id_nearest (id, double (wx))
		    pix = PIX(id,ID_CURRENT(id))
		    pix = id_center (id, pix, 1, ID_FWIDTH(id),
			FTYPE(id,ID_CURRENT(id)), NO)
		    if (!IS_INDEFD (pix)) {
		        call gseti (ID_GP(id), G_PLTYPE, 0)
		        call id_mark (id, ID_CURRENT(id))
			PIX(id,ID_CURRENT(id)) = pix
		        FWIDTH(id,ID_CURRENT(id)) = ID_FWIDTH(id)
			FIT(id,ID_CURRENT(id)) = id_fitpt (id, pix)
		        call gseti (ID_GP(id), G_PLTYPE, 1)
			call id_mark (id, ID_CURRENT(id))
		        ID_NEWFEATURES(id) = YES
		    } else {
			call printf ("Centering failed\n")
			prfeature = NO
		    }
		}
	    case 'd':	# Delete features
		if (all != 0) {
		    ID_NFEATURES(id) = 0
		    ID_CURRENT(id) = 0
		    ID_NEWFEATURES(id) = YES
		    ID_NEWGRAPH(id) = YES
		} else {
		    if (ID_NFEATURES(id) < 1)
			goto beep_
		    call id_nearest (id, double (wx))
		    call gseti (ID_GP(id), G_PLTYPE, 0)
		    call id_mark (id, ID_CURRENT(id))
		    call gseti (ID_GP(id), G_PLTYPE, 1)
		    call id_delete (id, ID_CURRENT(id))
		    ID_CURRENT(id) = min (ID_NFEATURES(id), ID_CURRENT(id))
		    last = 0
		}
	    case 'f':	# Fit dispersion function
		if (ID_TASK(id) == IDENTIFY) {
		    call id_dofit (id, YES)
		} else {
		    call id_velocity (id, YES)
		    prfeature = NO
		}
	    case 'g':	# Fit shift
		if (ID_TASK(id) == RVIDLINES)
		    goto beep_

		call id_doshift (id, YES)
		prfeature = NO
	    case 'i':	# Initialize
	        call dcvfree (ID_CV(id))
		ID_SHIFT(id) = 0.
		ID_REDSHIFT(id) = 0.
	        ID_NEWCV(id) = YES
		ID_NFEATURES(id) = 0
		ID_CURRENT(id) = 0
		ID_NEWFEATURES(id) = YES
		ID_NEWGRAPH(id) = YES
	    case 'j', 'k', 'o':
		call printf ("Command not available in REIDENTIFY")
		prfeature = NO
	    case 'l':	# Find features from line list
		if (ID_TASK(id) == IDENTIFY) {
		    if (ID_NFEATURES(id) >= 2)
			call id_dofit (id, NO)
		    if (ID_NEWCV(id) == YES) {
			iferr (call id_fitdata(id))
			    ;
			call id_fitfeatures(id)
			ID_NEWCV(id) = NO
		    }
		    call id_linelist (id)
		    if (ID_NEWFEATURES(id) == YES)
			ID_REFIT(id) = YES
		} else {
		    call id_velocity (id, NO)
		    call id_linelist(id)
		    if (ID_NEWFEATURES(id) == YES) {
			call id_velocity (id, NO)
			ID_NEWGRAPH(id) = YES
		    }
		}
	    case 'm':	# Mark new feature
		fit = wx
		pix = fit_to_pix (id, fit)
		pix = id_center (id, pix, 1, ID_FWIDTH(id), ID_FTYPE(id), YES)
		if (IS_INDEFD (pix))
		    goto beep_
		fit = id_fitpt (id, pix)
		user = fit
		call id_newfeature (id, pix, fit, user, 1.0D0, ID_FWIDTH(id),
		    ID_FTYPE(id), NULL)
		USER(id,ID_CURRENT(id)) = INDEFD
		call id_match (id, FIT(id,ID_CURRENT(id)),
		    USER(id,ID_CURRENT(id)),
		    Memi[ID_LABEL(id)+ID_CURRENT(id)-1],
		    ID_MATCH(id), ID_REDSHIFT(id))
		call id_mark (id, ID_CURRENT(id))
		call printf ("%10.2f %10.8g ")
		    call pargd (PIX(id,ID_CURRENT(id)))
		    call pargd (FIT(id,ID_CURRENT(id)))
		if (ID_REDSHIFT(id) != 0.) {
		    call printf ("[%10.8g] ")
			call pargd (FIT(id,ID_CURRENT(id)) /
			    (1 + ID_REDSHIFT(id)))
		}
		call printf ("(%10.8g %s): ")
		    call pargd (USER(id,ID_CURRENT(id)))
		    label = Memi[ID_LABEL(id)+ID_CURRENT(id)-1]
		    if (label != NULL)
			call pargstr (Memc[label])
		    else
			call pargstr ("")
		call flush (STDOUT)
		if (scan() != EOF) {
		    call gargd (user)
		    call gargwrd (cmd, SZ_LINE)
		    i = nscan()
		    if (i > 0) {
			USER(id,ID_CURRENT(id)) = user
			call id_match (id, user, USER(id,ID_CURRENT(id)),
			    Memi[ID_LABEL(id)+ID_CURRENT(id)-1],
			    ID_MATCH(id), ID_REDSHIFT(id))
		    }
		    if (i > 1) {
			call reset_scan ()
			call gargd (user)
			call gargstr (cmd, SZ_LINE)
			call id_label (cmd, Memi[ID_LABEL(id)+ID_CURRENT(id)-1])
		    }
		}
	    case 'p':	# Switch to pan mode
		if (ID_GTYPE(id) != PAN) {
		    ID_GTYPE(id) = PAN
		    ID_NEWGRAPH(id) = YES
		}
	    case 'q':	# Exit loop
		break
	    case 'r':	# Redraw the graph
		ID_NEWGRAPH(id) = YES
	    case 's', 'x':	# Shift or correlate features
		if (ID_TASK(id) == RVIDLINES)
		    goto beep_

		# Get coordinate shift.
		switch (key) {
		case 's':
		    call printf ("User coordinate (%10.8g): ")
		        call pargr (wx)
		        call flush (STDOUT)
		    if (scan() != EOF) {
		        call gargd (user)
		        if (nscan() == 1)
			    shift = wx - user
		    } else
		        shift = 0.
		case 'x':
		    if (ID_NFEATURES(id) > 5)
			shift = id_shift (id)
		    else
			goto beep_
		}

		ID_NEWFEATURES(id) = YES
		ID_NEWCV(id) = YES
		ID_NEWGRAPH(id) = YES
		prfeature = NO

		if (ID_NFEATURES(id) < 1) {
		    call printf ("User coordinate shift=%5f\n")
			call pargd (shift)
		    ID_SHIFT(id) = ID_SHIFT(id) + shift
		    goto newkey_
		}

		# Recenter features.
		pix_shift = 0.
		z_shift = 0.
		nfeatures1 = ID_NFEATURES(id)

		j = 0.
		do i = 1, ID_NFEATURES(id) {
		    pix = fit_to_pix (id, FIT(id,i) + shift)
		    pix = id_center (id, pix, 1, FWIDTH(id,i), FTYPE(id,i), NO)
		    if (IS_INDEFD (pix)) {
			if (ID_CURRENT(id) == i)
			    ID_CURRENT(id) = i + 1
			next
		    }
		    fit = id_fitpt (id, pix)

		    pix_shift = pix_shift + pix - PIX(id,i)
		    if (FIT(id,i) != 0.)
		        z_shift = z_shift + (fit - FIT(id,i)) / FIT(id,i)

		    j = j + 1
		    PIX(id,j) = pix
		    FIT(id,j) = FIT(id,i)
		    USER(id,j) = USER(id,i)
		    WTS(id,j) = WTS(id,i)
		    FWIDTH(id,j) = FWIDTH(id,i)
		    FTYPE(id,j) = FTYPE(id,i)
		    if (ID_CURRENT(id) == i)
			ID_CURRENT(id) = j
		}
		if (j != ID_NFEATURES(id)) {
		    ID_NFEATURES(id) = j
		    ID_CURRENT(id) = min (ID_CURRENT(id), ID_NFEATURES(id))
		}

		if (ID_NFEATURES(id) < 1) {
		    call printf ("User coordinate shift=%5f")
			call pargd (shift)
		    call printf (", No features found during recentering\n")
		    ID_SHIFT(id) = ID_SHIFT(id) + shift
		    goto newkey_
		}

		# Adjust shift.
		pix = ID_SHIFT(id)
		call id_doshift (id, NO)
		call id_fitfeatures (id)

		# Print results.
		call printf ("Recentered=%d/%d")
		    call pargi (ID_NFEATURES(id))
		    call pargi (nfeatures1)
		call printf (
		    ", pixel shift=%.2f, user shift=%5f, z=%7.3g, rms=%5g\n")
		    call pargd (pix_shift / ID_NFEATURES(id))
		    call pargd (pix - ID_SHIFT(id))
		    call pargd (z_shift / ID_NFEATURES(id))
		    call pargd (id_rms(id))
	    case 't':	# Move the current feature
		if (ID_CURRENT(id) < 1)
		    goto beep_
		pix = fit_to_pix (id, double (wx))
		call gseti (ID_GP(id), G_PLTYPE, 0)
		call id_mark (id, ID_CURRENT(id))
		PIX(id,ID_CURRENT(id)) = pix
		FIT(id,ID_CURRENT(id)) = id_fitpt (id, pix)
		call gseti (ID_GP(id), G_PLTYPE, 1)
		call id_mark (id, ID_CURRENT(id))
		ID_NEWFEATURES(id) = YES
	    case 'u':	# Set user coordinate
		if (ID_NFEATURES(id) < 1)
		    goto beep_
		call printf ("%10.2f %10.8g ")
		    call pargd (PIX(id,ID_CURRENT(id)))
		    call pargd (FIT(id,ID_CURRENT(id)))
		if (ID_REDSHIFT(id) != 0.) {
		    call printf ("[%10.8g] ")
			call pargd (FIT(id,ID_CURRENT(id)) /
			    (1 + ID_REDSHIFT(id)))
		}
		call printf ("(%10.8g %s): ")
		    call pargd (USER(id,ID_CURRENT(id)))
		    label = Memi[ID_LABEL(id)+ID_CURRENT(id)-1]
		    if (label != NULL)
			call pargstr (Memc[label])
		    else
			call pargstr ("")
		call flush (STDOUT)
		if (scan() != EOF) {
		    call gargd (user)
		    call gargwrd (cmd, SZ_LINE)
		    i = nscan()
		    if (i > 0) {
			USER(id,ID_CURRENT(id)) = user
			ID_NEWFEATURES(id) = YES
		    }
		    if (i > 1) {
			call reset_scan ()
			call gargd (user)
			call gargstr (cmd, SZ_LINE)
			call id_label (cmd, Memi[ID_LABEL(id)+ID_CURRENT(id)-1])
		    }
		}
		call printf ("Weight (%g): ")
		    call pargd (WTS(id,ID_CURRENT(id)))
		call flush (STDOUT)
		if (scan() != EOF) {
		    call gargd (user)
		    if (nscan() > 0)
			WTS(id,ID_CURRENT(id)) = user
		}
	    case 'w':	# Window graph
		call gt_window (ID_GT(id), ID_GP(id), "cursor", ID_NEWGRAPH(id))
	    case 'y':	# Find peaks
		call malloc (peaks, ID_NPTS(id), TY_REAL)
		npeaks = find_peaks (IMDATA(id,1), Memr[peaks], ID_NPTS(id), 0.,
		    int (ID_MINSEP(id)), 0, ID_MAXFEATURES(id), 0., false)
		for (j = 1; j <= ID_NFEATURES(id); j = j + 1) {
		    for (i = 1; i <= npeaks; i = i + 1) {
			if (!IS_INDEF (Memr[peaks+i-1])) {
			    pix = Memr[peaks+i-1]
			    if (abs (pix - PIX(id,j)) < ID_MINSEP(id))
			        Memr[peaks+i-1] = INDEF
			}
		    }
		}
		for (i = 1; i <= npeaks; i = i + 1) {
		    if (IS_INDEF(Memr[peaks+i-1]))
			next
		    pix = Memr[peaks+i-1]
		    pix = id_center(id, pix, 1, ID_FWIDTH(id), ID_FTYPE(id), NO)
		    if (IS_INDEFD (pix))
			next
		    fit = id_fitpt (id, pix)
		    user = INDEFD
		    call id_match (id, fit, user, label, ID_MATCH(id),
			ID_REDSHIFT(id))
		    call id_newfeature (id, pix, fit, user, 1.0D0,
			ID_FWIDTH(id), ID_FTYPE(id), label)
		    call id_mark (id, ID_CURRENT(id))
		}
		call mfree (peaks, TY_REAL)
	    case 'z':	# Go to zoom mode
		if (ID_NFEATURES(id) < 1)
		    goto beep_
		if (ID_GTYPE(id) == PAN)
		    ID_NEWGRAPH(id) = YES
		ID_GTYPE(id) = ZOOM
		call id_nearest (id, double (wx))
	    case 'I':
		call fatal (0, "Interrupt")
	    default:
beep_		call printf ("\007")
	    }

newkey_
	    # Set update flag if anything has changed.
	    if ((ID_NEWFEATURES(id) == YES) || (ID_NEWCV(id) == YES))
		ID_NEWDBENTRY(id) = YES

	    # If a new image exit loop, update database, and start over.
	    if (newimage[1] != EOS) {
		call printf ("Can't change image in REIDENTIFY")
		newimage[1] = EOS
		prfeature = NO
	    }

	    # Refit dispersion function
	    if (ID_REFIT(id) == YES) {
		call id_dofit (id, NO)
		ID_REFIT(id) = NO
	    }

	    # If there is a new dispersion solution evaluate the coordinates
	    if (ID_NEWCV(id) == YES) {
		iferr (call id_fitdata (id))
		    ;
		call id_fitfeatures (id)
		ID_NEWCV(id) = NO
	    }

	    # Draw new graph in zoom mode if current feature has changed.
	    if ((ID_GTYPE(id) == ZOOM) && (last != ID_CURRENT(id)))
		ID_NEWGRAPH(id) = YES

	    # Draw new graph.
	    if (ID_NEWGRAPH(id) == YES) {
		call id_graph (id, ID_GTYPE(id))
	        ID_NEWGRAPH(id) = NO
	    }

	    # Set cursor and print status of current feature (unless canceled).
	    if (ID_CURRENT(id) > 0) {
		if (IS_INDEF (wy)) {
		    i = max (1, min (ID_NPTS(id), int (PIX(id,ID_CURRENT(id)))))
		    wy = IMDATA(id,i)
		}
		    
		call gscur (ID_GP(id), real (FIT(id,ID_CURRENT(id))), wy)
		if (errcode() == OK && prfeature == YES) {
		    i = ID_CURRENT(id)
		    pix = PIX(id,i)
		    fit = FIT(id,i)
		    user = USER(id,i)
		    if (ID_TASK(id) == IDENTIFY) {
			if (IS_INDEFD(user))
			    shift = INDEF
			else
			    shift = fit - user
			call printf ("%10.2f %10.8g %10.8g %10.3g %s")
			    call pargd (pix)
			    call pargd (fit)
			    call pargd (user)
			    call pargd (shift)
			    label = Memi[ID_LABEL(id)+i-1]
			    if (label != NULL)
				call pargstr (Memc[label])
			    else
				call pargstr ("")
		    } else {
			if (IS_INDEFD(user))
			    shift = INDEF
			else {
			    shift = (fit - user) / user - ID_REDSHIFT(id)
			    if (abs (shift) < 0.01)
				shift = shift * VLIGHT
			}
			call printf ("%10.2f %10.8g %10.8g %10.8g %10.4g %s")
			    call pargd (pix)
			    call pargd (fit)
			    call pargd (fit / (1 + ID_REDSHIFT(id)))
			    call pargd (user)
			    if (IS_INDEFD(user))
				call pargd (INDEFD)
			    else
				call pargd (shift)
			    label = Memi[ID_LABEL(id)+i-1]
			    if (label != NULL)
				call pargstr (Memc[label])
			    else
				call pargstr ("")
		    }
		}
	    }

	    # Print delayed error message
	    if (errcode() != OK)
		call erract (EA_WARN)

	    last = ID_CURRENT(id)
	} until (clgcur ("cursor", wx, wy, wcs, key, cmd, SZ_LINE) == EOF)
end
