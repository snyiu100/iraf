/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define import_spp
#define import_knames
#include <iraf.h>

/* ACHTU_ -- Unpack an unsigned short integer array into an SPP datatype.
 * [MACHDEP]: The underscore appended to the procedure name is OS dependent.
 */
int ACHTUP ( XUSHORT *a, XPOINTER *b, XSIZE_T *npix )
{
	XUSHORT *ip;
	XPOINTER *op;

	if ( sizeof(*ip) < sizeof(*op) ) {
	    for ( ip = a + *npix, op = b + *npix ; b < op ; ) {
		--op; --ip;
		*op = *ip;
	    }
	} else {
	    XPOINTER *maxop = b + *npix -1;
	    for ( ip=a, op=b ; op <= maxop ; op++, ip++ ) {
		*op = *ip;
	    }
	}

	return 0;
}