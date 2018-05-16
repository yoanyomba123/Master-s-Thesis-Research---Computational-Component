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

#ifdef EXTERN_TYPE

DEVICE_PREFIX VEC_THIS_CLASS(const EXTERN_TYPE<T>& other)
{
	this->x = other.x;
	this->y = other.y;
	this->z = other.z;
}

DEVICE_PREFIX VEC_THIS_CLASS& operator= (const EXTERN_TYPE<T>& other)
{
	this->x = other.x;
	this->y = other.y;
	this->z = other.z;

	return *this;
}

DEVICE_PREFIX VEC_THIS_CLASS<T> operator+ (const EXTERN_TYPE<T>& other) const
{
	VEC_THIS_CLASS<T> outVec;
	outVec.x = x + other.x;
	outVec.y = y + other.y;
	outVec.z = z + other.z;

	return outVec;
}

DEVICE_PREFIX VEC_THIS_CLASS<T> operator- (const EXTERN_TYPE<T>& other) const
{
	VEC_THIS_CLASS<T> outVec;
	outVec.x = x - other.x;
	outVec.y = y - other.y;
	outVec.z = z - other.z;

	return outVec;
}

DEVICE_PREFIX VEC_THIS_CLASS<T> operator/ (const EXTERN_TYPE<T>& other) const
{
	VEC_THIS_CLASS<T> outVec;
	outVec.x = x / other.x;
	outVec.y = y / other.y;
	outVec.z = z / other.z;

	return outVec;
}

DEVICE_PREFIX VEC_THIS_CLASS<T> operator* (const EXTERN_TYPE<T>& other) const
{
	VEC_THIS_CLASS<T> outVec;
	outVec.x = x * other.x;
	outVec.y = y * other.y;
	outVec.z = z * other.z;

	return outVec;
}

// Adds each element by other
DEVICE_PREFIX VEC_THIS_CLASS<T>& operator+= (const EXTERN_TYPE<T>& other)
{
	x += other.x;
	y += other.y;
	z += other.z;

	return *this;
}

// Subtracts each element by other
DEVICE_PREFIX VEC_THIS_CLASS<T>& operator-= (const EXTERN_TYPE<T>& other)
{
	x -= other.x;
	y -= other.y;
	z -= other.z;

	return *this;
}

// Are all the values less then the passed in values
DEVICE_PREFIX bool operator< (const EXTERN_TYPE<T>& inVec)
{
	return x<inVec.x && y<inVec.y && z<inVec.z;
}

DEVICE_PREFIX bool operator<= (const EXTERN_TYPE<T>& inVec)
{
	return x<=inVec.x && y<=inVec.y && z<=inVec.z;
}

// Are all the values greater then the passed in values
DEVICE_PREFIX bool operator> (const EXTERN_TYPE<T>& inVec)
{
	return x>inVec.x && y>inVec.y && z>inVec.z;
}

DEVICE_PREFIX bool operator>= (const EXTERN_TYPE<T>& inVec)
{
	return x>=inVec.x && y>=inVec.y && z>=inVec.z;
}

DEVICE_PREFIX bool operator== (const EXTERN_TYPE<T>& inVec)
{
	return x==inVec.x && y==inVec.y && z==inVec.z;
}

DEVICE_PREFIX bool operator!= (const EXTERN_TYPE<T>& inVec)
{
	return x!=inVec.x || y!=inVec.y || z!=inVec.z;
}

// Returns the linear memory map if this is the dimensions and the passed in Vec is the coordinate
DEVICE_PREFIX size_t linearAddressAt(const EXTERN_TYPE<T>& coordinate, bool columnMajor=false) const
{
	if (columnMajor)
		return coordinate.y + coordinate.x*y + coordinate.z*x*y;

	return coordinate.x + coordinate.y*x + coordinate.z*y*x;
}

DEVICE_PREFIX double EuclideanDistanceTo(const EXTERN_TYPE<T>& other)
{
	return sqrt((double)(SQR(x-other.x) + SQR(y-other.y) + SQR(z-other.z)));
}

DEVICE_PREFIX VEC_THIS_CLASS<T> cross(const EXTERN_TYPE<T>& other)
{
	VEC_THIS_CLASS<T> outVec;
	outVec.x = this->y*other.z - this->z*other.y;
	outVec.y = -(this->x*other.z - this->z*other.x);
	outVec.z = this->x*other.y - this->y*other.x;

	return outVec;
}

DEVICE_PREFIX T dot(const EXTERN_TYPE<T>& other)
{
	return x*other.x + y*other.y + z*other.z;
}

#endif