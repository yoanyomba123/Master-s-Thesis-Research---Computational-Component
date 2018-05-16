#include "MexCommand.h"
#include "MexFunctions.h"
#include "Global/Globals.h"

void MexMoveRight::execute(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
    double speedFactorM = mxGetScalar(prhs[0]);
    double* speed = new double;
    *speed = speedFactorM;

    gMsgQueueToDirectX.writeMessage("moveRight", NULL);
}

std::string MexMoveRight::check(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
    if(nrhs!=1)
        return "Not the right arguments for MoveRight!";

    return "";
}

void MexMoveRight::usage(std::vector<std::string>& outArgs, std::vector<std::string>& inArgs) const
{
    inArgs.push_back("speedFactor");
}

void MexMoveRight::help(std::vector<std::string>& helpLines) const
{
    helpLines.push_back("This will move the camera right by one step.");

    helpLines.push_back("\tSpeedFactor -- this is a multiplier on how fast or how big the steps are for each move.");
}