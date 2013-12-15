//
//  easygl.h
//  kinsim
//
//  Created by Rene, ands on 14/11/13.
//  Copyright (c) 2013 Rene, ands. All rights reserved.
//

#ifndef kinsim_easygl_h
#define kinsim_easygl_h

#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#else
#include <GL/gl.h>
#include <GL/glext.h>
#endif

#include <glm/glm.hpp>
#include <glm/gtc/quaternion.hpp>
#include <math.h>
#include "path.h"

class stl;

class easygl
{
public:
	glm::vec3 position;
	glm::vec3 target;
	glm::vec3 up;
	glm::quat orientation;
	
	glm::ivec2 viewportSize;
	double fieldOfView;
	double near, far;
	double aspectRatio;
	
	vec* robotState;
	path* currentPath;
	
	easygl();
	~easygl();
	
	void init();
	void draw();
	
private:
	void drawBox(GLdouble width, GLdouble height, GLdouble depth);
	void drawPath();
	void drawRobot();
	void drawAxis();
	void drawGrid();
	void drawStl(stl* obj);
};

#endif
