//
//  KinOpenGLView.m
//  kinsim
//
//  Created by Rene on 11/11/13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "KinOpenGLView.h"

@implementation KinOpenGLView

// sets the camera data to initial conditions
- (void) resetCamera
{
    camera.aperture = 40;
    //camera.rotPoint = gOrigin;
    
    camera.viewPos.x = 0.0;
    camera.viewPos.y = 0.0;
    camera.viewPos.z = 0.0;
    camera.viewDir.x = -camera.viewPos.x;
    camera.viewDir.y = -camera.viewPos.y;
    camera.viewDir.z = -camera.viewPos.z;
    
    camera.viewUp.x = 0;
    camera.viewUp.y = 0;
    camera.viewUp.z = 1;
    
    cam.x = 0;
    cam.y = 0;
    
    shapeSize = 40.0f; // max radius of of objects
    
    [self updateCamera];
}

- (void) updateCamera
{
    NSRect rectView = [self bounds];
	
	// ensure camera knows size changed
	if ((camera.viewHeight != rectView.size.height) ||
	    (camera.viewWidth != rectView.size.width)) {
		camera.viewHeight = rectView.size.height;
		camera.viewWidth = rectView.size.width;
		
		glViewport (0, 0, camera.viewWidth, camera.viewHeight);
		[self updateProjection];  // update projection matrix
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:self];
    drag.x = location.x;
    drag.y = location.y;
    startcam.x = cam.x;
    startcam.y = cam.y;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:self];
    cam.x = location.x-drag.x+startcam.x;
    cam.y = drag.y-location.y+startcam.y;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	float wheelDelta = [theEvent deltaX] +[theEvent deltaY] + [theEvent deltaZ];
	if (wheelDelta)
	{
		GLfloat deltaAperture = wheelDelta * -camera.aperture / 200.0f;
		camera.aperture += deltaAperture;
		if (camera.aperture < 0.1) // do not let aperture <= 0.1
			camera.aperture = 0.1;
		if (camera.aperture > 179.9) // do not let aperture >= 180
			camera.aperture = 179.9;
		[self updateProjection]; // update projection matrix
		//[self setNeedsDisplay: YES];
	}
}

// update the projection matrix based on camera and view info
- (void) updateProjection
{
	GLdouble ratio, radians, wd2;
	GLdouble left, right, top, bottom, near, far;
    
    //[[self openGLContext] makeCurrentContext];
    
	// set projection
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity ();
	near = -camera.viewPos.z - shapeSize * 0.5;
	if (near < 0.00001)
		near = 0.00001;
	far = -camera.viewPos.z + shapeSize * 0.5;
	if (far < 1.0)
		far = 1.0;
	radians = 0.0174532925 * camera.aperture / 2; // half aperture degrees to radians
	wd2 = near * tan(radians);
	ratio = camera.viewWidth / (float) camera.viewHeight;
	if (ratio >= 1.0) {
		left  = -ratio * wd2;
		right = ratio * wd2;
		top = wd2;
		bottom = -wd2;
	} else {
		left  = -wd2;
		right = wd2;
		top = wd2 / ratio;
		bottom = -wd2 / ratio;
	}
	glFrustum (left, right, bottom, top, near, far);
}

- (void)animationTimer:(NSTimer *)timer
{
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0, -1, -5);
    glRotatef(cam.y, 1, 0, 0);
    glRotatef(cam.x, 0, 1, 0);
    glRotatef(0, 0, 0, 1);
    
    // Set every pixel in the frame buffer to the current clear color.
    glClear(GL_COLOR_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    
    if(display){
        j1 = [joint1 floatValue];//+p.jointpos1[curr_pos];
        j2 = [joint2 floatValue];//+p.jointpos2[curr_pos];
        j3 = [joint3 floatValue];//+p.jointpos3[curr_pos];
        
        drawgrid();
        drawrobot(j1, j2, j3, [joint4 floatValue], [joint5 floatValue], 0);
        drawaxis();
        drawpath(currentPath);
        draw(obj);
        
        // Flush drawing command buffer to make drawing happen as soon as possible.
        glFlush();
    
        curr_pos += (int)[speed floatValue];
        if(curr_pos < 0){
            curr_pos = p.length - 1;
        }
        if(curr_pos >= p.length){
            curr_pos = 0;
        }
        if([speed floatValue] != 0){
            [pos setFloatValue:curr_pos * 100 / p.length];
        }else{
            curr_pos = [pos floatValue]/100*(p.length-1);
        }
    }
}

-(IBAction)stop:(id)sender{
    [speed  setFloatValue:0];
    [joint1 setFloatValue:0];
    [joint2 setFloatValue:0];
    [joint3 setFloatValue:0];
    [joint4 setFloatValue:0];
    [joint5 setFloatValue:0];
    [joint6 setFloatValue:0];
}

-(IBAction)send:(id)sender{
    int i1 = -j1 / 0.055;
    int i2 = j2 / 0.038;
    int i3 = j3-j2 / 0.038;
    //int i4 = j4 / 0.055;
    //int i5 = j5 / 0.055;
    //int i6 = j6 / 0.026;
    
    char buffer[1024];
    snprintf(buffer, sizeof(buffer), "D %i %i %i %i %i %i\n", i1, i2, i3, 0, 0, 0);
    NSLog(@"%@",[NSString stringWithCString:buffer encoding:NSASCIIStringEncoding]);
    
    //swrite(buffer);
}


- (void) prepareOpenGL
{
    [self resetCamera];
    frame = 0;
    curr_pos = 0;
    display = NO;
    
    glEnable(GL_LINE_SMOOTH);

    //obj = stl("/Users/crinq/Dropbox/maschinen/knuth/pumpe.stl");
    
    timer = [NSTimer
             timerWithTimeInterval:(1.0f/60.0f)
             target:self
             selector:@selector(animationTimer:)
             userInfo:nil
             repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    // ensure timer fires during resize
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}

- (void) newPath:(struct path*)newpath
{
    display = NO;
    free(p.jointpos1);
    free(p.jointpos2);
    free(p.jointpos3);
    freepath(currentPath);
    
    currentPath = newpath;
    p = interpol(currentPath);
    display = YES;
}

- (void)windowDidResize:(NSNotification *)notification{
    [self updateCamera];
}

@end
