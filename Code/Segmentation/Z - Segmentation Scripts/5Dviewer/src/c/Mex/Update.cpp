#include "Global/Vec.h"
#include "mex.h"
#include "Messages/MessageQueue.h"
#include "windows.h"
#include "Global/Globals.h"
#include "MexFunctions.h"
#include "Messages/QueuePolygon.h"
#include <set>
#include <vector>

using std::vector;

std::vector<VolumeTextureObject*> firstVolumeTextures;
std::vector<SceneNode*> hullRootNodes;

void setCurrentTexture(GraphicObjectTypes textureType)
{
	if (gRenderer == NULL) return;

	int fvtIdx = textureType - GraphicObjectTypes::OriginalVolume;

	for (int i = 0; i < firstVolumeTextures.size(); ++i)
	{
		int idx = GraphicObjectTypes::OriginalVolume + i;
		if (idx == GraphicObjectTypes::VTend)
			break;

		bool render = (i == fvtIdx);
		for (auto itr :gGraphicObjectNodes[idx])
			itr.second->setRenderable(render);
	}
}

void togglePolygons(bool on)
{
	if (gRenderer == NULL) return;

	const GraphicObjectTypes cellType = GraphicObjectTypes::Polygons;
	for (auto itr : gGraphicObjectNodes[cellType])
		itr.second->setRenderable(on);
}

void toggleWidget(bool on)
{
	if(gRenderer==NULL) return;

	const GraphicObjectTypes widgetType = GraphicObjectTypes::Widget;
	for(auto itr:gGraphicObjectNodes[widgetType])
		itr.second->setRenderable(on);
}

void togglePolygonWireframe(bool wireframe)
{
	if (gRenderer == NULL) return;

	const GraphicObjectTypes cellType = GraphicObjectTypes::Polygons;
	std::map<int, GraphicObjectNode*>::iterator objectIter = gGraphicObjectNodes[cellType].begin();
	for ( ; objectIter != gGraphicObjectNodes[cellType].end(); ++objectIter )
		objectIter->second->setWireframe(wireframe);
}

void togglePolygonLighting(bool lighting)
{
	if (gRenderer == NULL) return;

	const GraphicObjectTypes cellType = GraphicObjectTypes::Polygons;
	for(auto itr:gGraphicObjectNodes[cellType])
		itr.second->setLightOn(lighting);
}

void toggleSelectedPolygon(std::set<int> labels)
{
	if (gRenderer == NULL) return;

	const GraphicObjectTypes cellType = GraphicObjectTypes::Polygons;
	for(auto itr:gGraphicObjectNodes[cellType])
	{
		GraphicObjectNode* node = itr.second;
		if ( labels.count(node->getPolygonLabel()) > 0 )
			node->setRenderable(true);
		else
			node->setRenderable(false);
	}
}

HRESULT updatePolygons(const mxArray* hulls)
{
	if (gRenderer == NULL) return E_FAIL;

	size_t numPolygons = mxGetNumberOfElements(hulls);
	for (size_t i = 0; i < numPolygons; ++i)
	{
		mxArray* mxFaces = mxGetField(hulls, i, "faces");
		mxArray* mxVerts = mxGetField(hulls, i, "verts");
		mxArray* mxNorms = mxGetField(hulls, i, "norms");
		mxArray* mxColor = mxGetField(hulls, i, "color");
		mxArray* mxFrame = mxGetField(hulls, i, "frame");
		mxArray* mxIndex = mxGetField(hulls, i, "index");
		mxArray* mxlabel = mxGetField(hulls, i, "label");

		size_t numFaces = mxGetM(mxFaces);
		size_t numVerts = mxGetM(mxVerts);
		size_t numNormals = mxGetM(mxNorms);

		if (numVerts < 1)
			mexErrMsgTxt("No Verts!");

		if (numFaces < 1)
			mexErrMsgTxt("No faces!");

		if (numNormals < 1)
			mexErrMsgTxt("No norms!");

		if (numNormals != numVerts)
			mexErrMsgTxt("Number of verts does not match the number of normals!");

		double* faceData = (double*)mxGetData(mxFaces);
		double* vertData = (double*)mxGetData(mxVerts);
		double* normData = (double*)mxGetData(mxNorms);
		double* colorData = (double*)mxGetData(mxColor);
		int frame = int(mxGetScalar(mxFrame)) - 1;

		char buff[255];
		mxGetString(mxlabel, buff, 255);

		QueuePolygon* polygon = new QueuePolygon(numFaces, numVerts, numNormals, frame, (int)mxGetScalar(mxIndex), buff);
		//memcpy(this->pixels, pixels, dimensions.product()* numChannels * numFrames * sizeof(unsigned char));
		polygon->setfaceData(faceData);
		polygon->setvertData(vertData);
		polygon->setnormData(normData);
		polygon->setcolorData(colorData);
		int* intptr = new int;
		*intptr = polygon->getIndex();
		gMsgQueueToDirectX.writeMessage("removePolygon", (void*)intptr);
		gMsgQueueToDirectX.writeMessage("loadPolygon", (void*)polygon);
	}

	return S_OK;
}

