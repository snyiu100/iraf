# Global (possibly system dependent) definitions for MKPKG.

$verbose

$set	MACH		= $(IRAFARCH)	# machine/fpu type
$set	HOSTID		= $(IRAFHOSTID)	# host system name
$set	SITEID		= $(IRAFSITEID)	# site name

$set	XFLAGS		= "-c"		# default XC compile flags
$set	XVFLAGS		= "-c"		# VOPS XC compile flags
$set	LFLAGS		= $(XC_XLFLAGS)	# default XC link flags

$set	USE_LIBMAIN	= yes		# update lib$libmain.o (root object)
$set	USE_KNET	= yes		# use the KI (network interface)
$set	USE_SHLIB	= no		# use (update) the shared library
$set	USE_CCOMPILER	= yes		# use the C compiler
$set	USE_GENERIC	= yes		# use the generic preprocessor
$set	USE_NSPP	= no		# make the NCAR/NSPP graphics kernel
$set	USE_IIS         = no		# make the IIS display control package
$set	USE_CALCOMP	= no		# make the Calcomp graphics kernel
$set	LIB_CALCOMP	= "-lcalcomp"	# name of host system calcomp library

$special "sys$osb/":		aclrb.c		host$sys/aclrb.c
				bytmov.c	host$sys/bytmov.c
				ieeer.x		host$sys/ieeer.c
				ieeed.x		host$sys/ieeed.c
				;

$special "sys$vops/ak/":	aclrc.x		host$sys/aclrc.c
				aclrs.x		host$sys/aclrs.c
				aclri.x		host$sys/aclri.c
				aclrl.x		host$sys/aclrl.c
				aclrp.x		host$sys/aclrp.c
				aclrr.x		host$sys/aclrr.c
				aclrd.x		host$sys/aclrd.c
				;

$special "sys$vops/lz/":	amovc.x		host$sys/amovc.c
				amovs.x		host$sys/amovs.c
				amovi.x		host$sys/amovi.c
				amovl.x		host$sys/amovl.c
				amovp.x		host$sys/amovp.c
				amovr.x		host$sys/amovr.c
				amovd.x		host$sys/amovd.c
				;

$set	XBIG	= '& "$xc -c -/Nx512 -/Ns3072 &"'
$special "sys$fmtio/":		evvexpr.x	$(XBIG)	;

$set    XNL     = '& "$xc -c -/NL400 &"'
$special "math$slalib/":        obs.f           $(XNL)  ;
