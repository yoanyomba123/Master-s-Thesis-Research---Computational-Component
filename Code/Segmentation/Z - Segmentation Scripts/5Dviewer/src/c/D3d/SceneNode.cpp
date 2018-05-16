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

#include "SceneNode.h"
#include "Global/Globals.h"
#include "Messages/MexErrorMsg.h"

#undef max

// Class method implementations
SceneNode::SceneNode()
{
	localToParentTransform = DirectX::XMMatrixIdentity();
	parentToWorld = DirectX::XMMatrixIdentity();
	parentNode=NULL;
}

SceneNode::~SceneNode()
{
	for (std::vector<SceneNode*>::iterator it=childrenNodes.begin(); it!=childrenNodes.end(); ++it)
	{
		SceneNode* cur = *it;
		cur->parentNode = NULL;
		delete cur;
	}

	childrenNodes.clear();

	parentNode = NULL;
}

void SceneNode::update()
{
	updateTransforms(parentToWorld);
}

void SceneNode::attachToParentNode(SceneNode* parent)
{
	if ( !parent->addChildNode(this) )
		return;

	parentNode = parent;
	updateTransforms(parent->getLocalToWorldTransform());
	requestUpdate();
}

void SceneNode::detatchFromParentNode()
{
	parentNode->detatchChildNode(this);
	parentNode = NULL;
}


void SceneNode::setLocalToParent(DirectX::XMMATRIX transform)
{
	localToParentTransform = transform;
	updateTransforms(parentToWorld);
}

DirectX::XMMATRIX SceneNode::getLocalToWorldTransform()
{
	return localToParentTransform*parentToWorld;
}


int SceneNode::getPolygon(Vec<float> pnt, Vec<float> direction,float& depthOut)
{
	depthOut = std::numeric_limits<float>::max();
	int labelOut = -1;

	for (int i=0; i<childrenNodes.size(); ++i)
	{
		float curDepth;
		int index = childrenNodes[i]->getPolygon(pnt,direction,curDepth);

		if (curDepth < depthOut)
		{
			labelOut = index;
			depthOut = curDepth;
		}
	}

	return labelOut;
}


void SceneNode::setParentNode(SceneNode* parent)
{
	parentNode = parent;
}

const std::vector<SceneNode*>& SceneNode::getChildren()
{
	return childrenNodes;
}

void SceneNode::updateTransforms(DirectX::XMMATRIX parentToWorldIn)
{
	parentToWorld = parentToWorldIn;

	for (std::vector<SceneNode*>::iterator it=childrenNodes.begin(); it!=childrenNodes.end(); ++it)
	{
		(*it)->updateTransforms(localToParentTransform*parentToWorld);
	}
}

bool SceneNode::addChildNode(SceneNode* child)
{
	//TODO check for dups
	childrenNodes.push_back(child);

	return true;
}

void SceneNode::requestUpdate()
{
	if (parentNode!=NULL)
		parentNode->requestUpdate();
}

void SceneNode::detatchChildNode(SceneNode* child)
{
	for (std::vector<SceneNode*>::iterator it=childrenNodes.begin(); it!=childrenNodes.end(); ++it)
	{
		if (*it==child)
		{
			childrenNodes.erase(it,it+1);
			break;
		}
	}
}


GraphicObjectNode::GraphicObjectNode(GraphicObject* graphicObjectIn)
{
	graphicObject = graphicObjectIn;
	renderable = true;
}

void GraphicObjectNode::releaseRenderResources()
{
	if (parentNode!=NULL)
		detatchFromParentNode();

	SAFE_DELETE(graphicObject);
	
	renderable = false;
}

void GraphicObjectNode::setRenderable(bool render)
{
	renderable = render;
	requestUpdate();
}

void GraphicObjectNode::setWireframe(bool wireframe)
{
	graphicObject->setWireframe(wireframe);
}


const RendererPackage* GraphicObjectNode::getRenderPackage()
{
	return graphicObject->getRenderPackage();
}


int GraphicObjectNode::getPolygon(Vec<float> pnt, Vec<float> direction,float& depthOut)
{
	DirectX::XMVECTOR det;
	DirectX::XMMATRIX locl = DirectX::XMMatrixInverse(&det,getLocalToWorldTransform());

	DirectX::XMFLOAT3 viewPntF(pnt.x,pnt.y,pnt.z);
	DirectX::XMVECTOR viewPntV = DirectX::XMLoadFloat3(&viewPntF);
	DirectX::XMFLOAT3 viewDirF(direction.x,direction.y,direction.z);
	DirectX::XMVECTOR viewDirV = DirectX::XMLoadFloat3(&viewDirF);

	DirectX::XMVECTOR lclPnt = DirectX::XMVector3TransformCoord(viewPntV,locl);
	DirectX::XMVECTOR lclDir = DirectX::XMVector3TransformNormal(viewDirV,locl);

	Vec<float> lclPntVec(DirectX::XMVectorGetX(lclPnt),DirectX::XMVectorGetY(lclPnt),DirectX::XMVectorGetZ(lclPnt));
	Vec<float> lclDirVec(DirectX::XMVectorGetX(lclDir),DirectX::XMVectorGetY(lclDir),DirectX::XMVectorGetZ(lclDir));

	return graphicObject->getPolygon(lclPntVec,lclDirVec,depthOut);
}


void GraphicObjectNode::updateTransforms(DirectX::XMMATRIX parentToWorldIn)
{
	parentToWorld = parentToWorldIn;
	graphicObject->makeLocalToWorld(localToParentTransform*parentToWorld);
}

GraphicObjectNode::~GraphicObjectNode()
{
	releaseRenderResources();
}


RootSceneNode::RootSceneNode() : SceneNode()
{
	for (int i=0; i<Renderer::Section::SectionEnd; ++i)
	{
		rootChildrenNodes[i].push_back(new SceneNode);
		rootChildrenNodes[i][0]->setParentNode(this);
	}

	resetWorldTransform();
	makeRenderableList();
}

void RootSceneNode::resetWorldTransform()
{
	origin = Vec<float>(0.0f,0.0f,0.0f);
	curRotationMatrix = DirectX::XMMatrixRotationRollPitchYaw(0.0f,0.0f,DirectX::XM_PI);
	updateTransforms(parentToWorld);
}

RootSceneNode::~RootSceneNode()
{
	for (int i=0; i<Renderer::Section::SectionEnd; ++i)
	{
		for (int j=0; j<rootChildrenNodes[i].size(); ++j)
			delete rootChildrenNodes[i][j];
		rootChildrenNodes[i].clear();
	}
}

SceneNode* RootSceneNode::getRenderSectionNode(Renderer::Section section, int frame)
{
	if (frame>=rootChildrenNodes[section].size())
	{
		int oldSize = int(rootChildrenNodes[section].size());
		rootChildrenNodes[section].resize(frame+1);
		for (int i=oldSize; i<=frame; ++i)
		{
			rootChildrenNodes[section][i] = new SceneNode;
			rootChildrenNodes[section][i]->parentNode = this; //TODO rethink this
		}
	}

	return rootChildrenNodes[section][frame];
}

const std::vector<GraphicObjectNode*>& RootSceneNode::getRenderableList(Renderer::Section section,unsigned int frame)
{
	frame = frame % rootChildrenNodes[section].size();
	if (renderList[section].size()<=frame)
		sendErrMessage("Render list is malformed!");

	return renderList[section][frame];
}

void RootSceneNode::updateTransforms(DirectX::XMMATRIX parentToWorldIn)
{
	parentToWorld = parentToWorldIn;

	DirectX::XMMATRIX transMatrix = DirectX::XMMatrixTranslation(-origin.x,-origin.y,-origin.z);

	for(int i=0; i<rootChildrenNodes[Renderer::Section::Pre].size(); ++i)
	{
		SceneNode* node = rootChildrenNodes[Renderer::Section::Pre][i];
		node->updateTransforms(transMatrix * curRotationMatrix * parentToWorld);
	}

	for(int i=0; i<rootChildrenNodes[Renderer::Section::Main].size(); ++i)
	{
		SceneNode* node = rootChildrenNodes[Renderer::Section::Main][i];
		node->updateTransforms(transMatrix * curRotationMatrix * parentToWorld);
	}

	for(int i=0; i<rootChildrenNodes[Renderer::Section::Post].size(); ++i)
	{
		SceneNode* node = rootChildrenNodes[Renderer::Section::Post][i];
		node->updateTransforms(curRotationMatrix * parentToWorld);
	}
}

int RootSceneNode::getNumFrames()
{
	int maxFrames = 0;

	for (int i=0; i<Renderer::Section::SectionEnd; ++i)
		if (maxFrames < rootChildrenNodes[i].size())
			maxFrames = int(rootChildrenNodes[i].size());

	return maxFrames;
}


int RootSceneNode::getPolygon(Vec<float> pnt, Vec<float> direction, unsigned int currentFrame, float& depthOut)
{
	std::vector<SceneNode*> children = rootChildrenNodes[Renderer::Section::Main][currentFrame]->getChildren();

	depthOut = std::numeric_limits<float>::max();
	int indexOut = -1;

	for (int i=0; i<children.size(); ++i)
	{
		float curDepth;
		int index = children[i]->getPolygon(pnt,direction,curDepth);

		if (curDepth < depthOut)
		{
			indexOut = index;
			depthOut = curDepth;
		}
	}

	return indexOut;
}

DirectX::XMMATRIX RootSceneNode::getWorldRotation()
{
	return curRotationMatrix;
}

bool RootSceneNode::addChildNode(SceneNode* child)
{
	sendErrMessage("You cannot attach to a root node using this method!");
	return false;
}

void RootSceneNode::requestUpdate()
{
	bRenderListDirty = true;
}

void RootSceneNode::updateRenderableList()
{
	if ( !bRenderListDirty )
		return;

	makeRenderableList();
}


void RootSceneNode::updateTranslation(Vec<float> origin)
{
	this->origin = origin;
	updateTransforms(parentToWorld);
}

void RootSceneNode::updateRotation(DirectX::XMMATRIX& rotation)
{
	curRotationMatrix = rotation;
	updateTransforms(parentToWorld);
}

void RootSceneNode::makeRenderableList()
{
	for (int i=0; i<Renderer::Section::SectionEnd; ++i)
	{
		renderList[i].clear();
		renderList[i].resize(rootChildrenNodes[i].size());

		for (int k=0; k<rootChildrenNodes[i].size(); ++k)
		{
			std::vector<SceneNode*> curChildList;
			curChildList.push_back(rootChildrenNodes[i][k]);

			std::vector<SceneNode*>::iterator it = curChildList.begin();
			size_t j = 0;
			while (j<curChildList.size())
			{
				const std::vector<SceneNode*>& children = curChildList[j]->getChildren();
				curChildList.insert(curChildList.end(),children.begin(),children.end());

				if (curChildList[j]->isRenderable())
					renderList[i][k].push_back((GraphicObjectNode*)curChildList[j]);

				++j;
			}

			curChildList.clear();
		}
	}

	bRenderListDirty = false;
}
