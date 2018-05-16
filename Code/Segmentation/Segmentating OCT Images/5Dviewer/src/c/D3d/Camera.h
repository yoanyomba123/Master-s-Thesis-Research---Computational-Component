////////////////////////////////////////////////////////////////////////////////
//Copyright 2014 Andrew Cohen, Eric Wait, and Mark Winter
//This file is part of LEVER 3-D - the tool for 5-D stem cell segmentation,
//tracking, and lineaging. See http://bioimage.coe.drexel.edu 'software' section
//for details. LEVER 3-D is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by the Free
//Software Foundation, either version 3 of the License, or (at your option) any
//later version.
//LEVER 3-D is distributed in the hope that it will be useful, but WITHOUT ANY
//WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
//A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with
//LEVer in file "gnu gpl v3.txt".  If not, see  <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////

#pragma once
#include "Global\Vec.h"
#include <DirectXMath.h>
#include "Renderer.h"

class Camera
{
public:
	Camera(Vec<float> cameraPositionIn, Vec<float> lookPositionIn, Vec<float> upDirectionIn);
    virtual ~Camera() {}

	void moveLeft(double speedFactor=1.0);
	void moveRight(double speedFactor=1.0);
	void moveUp(double speedFactor=1.0);
	void moveDown(double speedFactor=1.0);
	virtual void zoomIncrement(double speedFactor=1.0);
	virtual void zoomDecrement(double speedFactor=1.0);
    float getNearZ() const { return nearZ; }
    void setNearZ(float val);
	void resetCamera();
	void setCameraPosition(Vec<float> cameraPositionIn);
	void setLookPosition(Vec<float> lookPositionIn);
	void setUpDirection(Vec<float> upDirectionIn);
	void setCamera(Vec<float> cameraPositionIn, Vec<float> lookPositionIn, Vec<float> upDirectionIn);
	virtual void updateProjectionTransform();

	DirectX::XMMATRIX getProjectionTransform() const {return projectionTransform;}
	DirectX::XMMATRIX getViewTransform() const {return viewTransform;}
	void getRay(int iMouseX, int iMouseY, Vec<float>& pointOut, Vec<float>& directionOut);
	float Camera::getVolUnitsPerPix() const;

protected:
	Camera(){}

	virtual void updateViewTransform();
	Vec<float> cameraPosition;
	Vec<float> lookPosition;
	Vec<float> upDirection;
	Vec<float> defaultCameraPosition;
	Vec<float> defaultLookPosition;
	Vec<float> defaultUpDirection;
    float nearZ;
	DirectX::XMMATRIX viewTransform;
	DirectX::XMMATRIX projectionTransform;
	float zoomFactor;
};


class OrthoCamera : public Camera
{
public:
	OrthoCamera(Vec<float> cameraPostionIn, Vec<float> lookPostionIn, Vec<float> upDirectionIn);

	void updateProjectionTransform();
    virtual void zoomIncrement() {}
    virtual void zoomDecrement() {}

private:
	OrthoCamera();
};
