#///////////////////////////////////////////////////////////////////////////////
#//
#//  Makefile for the Vendor Libraries
#//
#///////////////////////////////////////////////////////////////////////////////

# primary dependencies

NAME       	 = vendor
VERSION    	 = 1.0
PLATFORM  	:= $(shell uname -s)
PLMACH  	:= $(shell uname -m)
HERE      	:= $(shell /bin/pwd)
BINDIR    	:= ../bin/
LIBDIR    	:= ../lib/
INCDIR    	:= ../lib/


# includes, flags and libraries
CINCS  	  	= -I$(INCDIR) -I./
LIBS		= -lm -lc -lpthread


all:
	./mklibs

libs:

install:
	(cd cfitsio   ; make install)
	(cd libvotable  ; make install)

clean:
	(cd cfitsio   ; make clean)
	(cd libvotable  ; make clean)


cfitsio:
	(cd cfitsio   ; ./configure --libdir=../../bin ; make ; make install)

libvotable:
	(cd libvotable  ; make World)


###############################################################################
# Leave this stuff alone.
###############################################################################

$(STATICLIB): $(SRCS:%.c=Static/%.o)
	/usr/bin/ar rv $@ $?
Static/%.o: %.c $(INCS)
	/usr/bin/gcc $(CINCS) $(CFLAGS) -c $< -o $@
Static:
	/bin/mkdir $@
	chmod 777 $@

$(SHAREDLIB): $(SRCS:%.c=Shared/%.o)
	/usr/bin/ld -shared -o $@ $? -lc -ldl
Shared/%.o: %.c $(INCS)
	/usr/bin/gcc $(CINCS) $(CFLAGS) -fpic -shared -c $< -o $@
Shared:
	/bin/mkdir $@
	chmod 777 $@
