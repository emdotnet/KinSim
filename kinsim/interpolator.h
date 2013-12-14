//
//  interpolator.h
//  kinsim
//
//  Created by Rene on 12/11/13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#include "path.h"

#ifndef kinsim_interpolator_h
#define kinsim_interpolator_h

#ifdef __cplusplus
extern "C" {
#endif

struct outpath{
    double* jointpos1;
    double* jointpos2;
    double* jointpos3;
    int length;
};

struct outpath interpol(struct path* AB);
    
#ifdef __cplusplus
}
#endif


#endif
