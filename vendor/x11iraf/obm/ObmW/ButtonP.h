/* Generated by wbuild from "Button.w"
** (generator version $Revision: 2.0 $ of $Date: 93/07/06 16:08:04 $)
*/
#ifndef _XfwfButtonP_H_
#define _XfwfButtonP_H_
#include "LabelP.h"
#include "Button.h"
typedef struct {
/* methods */
/* class variables */
int dummy;
} XfwfButtonClassPart;
typedef struct _XfwfButtonClassRec {
CoreClassPart core_class;
CompositeClassPart composite_class;
XfwfCommonClassPart xfwfCommon_class;
XfwfFrameClassPart xfwfFrame_class;
XfwfBoardClassPart xfwfBoard_class;
XfwfLabelClassPart xfwfLabel_class;
XfwfButtonClassPart xfwfButton_class;
} XfwfButtonClassRec;

typedef struct {
/* resources */
XtCallbackList  activate;
/* private state */
} XfwfButtonPart;

typedef struct _XfwfButtonRec {
CorePart core;
CompositePart composite;
XfwfCommonPart xfwfCommon;
XfwfFramePart xfwfFrame;
XfwfBoardPart xfwfBoard;
XfwfLabelPart xfwfLabel;
XfwfButtonPart xfwfButton;
} XfwfButtonRec;

externalref XfwfButtonClassRec xfwfButtonClassRec;

#endif /* _XfwfButtonP_H_ */