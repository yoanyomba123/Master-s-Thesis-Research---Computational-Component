#include "MexCommand.h"
#include "MexFunctions.h"
#include "Global/Globals.h"

void MexSetBackgroundColor::execute(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
	double* bc = (double*)mxGetData(prhs[0]);
	Vec<float>* background = new Vec<float>;
	background->x = (float)(bc[0]);
	background->y = (float)(bc[1]);
	background->z = (float)(bc[2]);

	gMsgQueueToDirectX.writeMessage("setBackgroundColor", (void*)background);
}

std::string MexSetBackgroundColor::check(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
	if (nrhs != 1)
		return "There must be one input consisting of three doubles between [0,1]!";

	return "";
}

void MexSetBackgroundColor::usage(std::vector<std::string>& outArgs, std::vector<std::string>& inArgs) const
{
	inArgs.push_back("color");
}

void MexSetBackgroundColor::help(std::vector<std::string>& helpLines) const
{
	helpLines.push_back("This will set the color of the background.");

	helpLines.push_back("\tColor - This should be three doubles between [0,1] that represent (r,g,b) of the desired background color.");
}