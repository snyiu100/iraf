# Structure definition for the FMODE task

define	LEN_FMODE_STRUCT	22

define	FMOD_XBOX	Memz[P2Z($1)]    # x median filtering window
define	FMOD_YBOX	Memz[P2Z($1+1)]  # y median filtering window
define	FMOD_MAP	Memi[P2I($1+2)]  # map image to histogram
define	FMOD_HMIN	Memi[P2I($1+3)]  # histogram minimum
define	FMOD_HMAX	Memi[P2I($1+4)]  # histogram maximum
define	FMOD_HLOW	Memi[P2I($1+5)]  # histogram low side rejection parameter
define	FMOD_HHIGH	Memi[P2I($1+6)]  # histogram high side rejection parameter
define	FMOD_NHLOW	Memi[P2I($1+7)]  # number of low rejected pixels
define	FMOD_NHHIGH	Memi[P2I($1+8)]  # number of high rejected pixels
define	FMOD_MEDIAN	Memi[P2I($1+9)]  # the current median
define	FMOD_NMEDIAN	Meml[P2L($1+10)] # number less than the median
define	FMOD_NLTMEDIAN	Meml[P2L($1+11)] # number less than the current median
define	FMOD_UNMAP	Memi[P2I($1+12)] # rescale the quantizied values
define	FMOD_ZMIN	Memr[P2R($1+13)] # the data minimum
define	FMOD_ZMAX	Memr[P2R($1+14)] # the data maximum
define	FMOD_Z1		Memr[P2R($1+15)] # the requested data minimum
define	FMOD_Z2		Memr[P2R($1+16)] # the requested data maximum
define	FMOD_ZLOW	Memr[P2R($1+17)] # data low side rejection parameter
define	FMOD_ZHIGH	Memr[P2R($1+18)] # data high side rejection parameter
define	FMOD_SUM	Memr[P2R($1+19)] # running sum for mean calculation
