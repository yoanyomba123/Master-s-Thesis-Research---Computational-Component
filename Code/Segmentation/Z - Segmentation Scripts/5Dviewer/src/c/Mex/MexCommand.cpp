#include "MexCommand.h"

#define INSTANCE_COMMANDS
#include "CommandList.h"
#undef INSTANCE_COMMANDS

#define BUILD_COMMANDS
#include "CommandList.h"
#undef BUILD_COMMANDS

// Module name info
HMODULE ModuleInfo::hModule;
std::string ModuleInfo::name;

__declspec(dllexport) BOOL WINAPI DllMain(HINSTANCE hInstDLL, DWORD fdwReason, LPVOID lpReserved)
{
	if(fdwReason==DLL_PROCESS_ATTACH)
		ModuleInfo::setModuleHandle(hInstDLL);

	return TRUE;
}

// MexCommandInfo - This command can be used to provide an easy to parse matlab command info structure for all MEX commands.
std::string MexInfo::check(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
	if(nrhs > 0)
		return "No input arguments are supported.";

	if(nlhs!=1)
		return "Expected a single ouput arugment.";

	return "";
}

void MexInfo::execute(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
	const char* fieldNames[] = {"command","outArgs","inArgs","helpLines"};
	const int numFields = sizeof(fieldNames)/sizeof(char*);

	std::vector<MexCommand*> commandList = MexCommand::getCommandList();

	mxArray* outArray = mxCreateStructMatrix(commandList.size(), 1, numFields, fieldNames);
	if(outArray==NULL)
		throw(std::runtime_error("Unable to allocate matlab output structure."));

	for(int i = 0; i < commandList.size(); ++i)
	{
		std::string command;
		std::vector<std::string> inArgs;
		std::vector<std::string> outArgs;
		std::vector<std::string> helpLines;

		command = commandList[i]->command();
		commandList[i]->usage(outArgs, inArgs);
		commandList[i]->help(helpLines);

		mxArray* cmdStrArray = mxCreateString(commandList[i]->command().c_str());
		mxArray* outArgArray = mxCreateCellMatrix(outArgs.size(), 1);
		mxArray* inArgArray = mxCreateCellMatrix(inArgs.size(), 1);
		mxArray* helpArray = mxCreateCellMatrix(helpLines.size(), 1);

		for(int j = 0; j < outArgs.size(); ++j)
			mxSetCell(outArgArray, j, mxCreateString(outArgs[j].c_str()));

		for(int j = 0; j < inArgs.size(); ++j)
			mxSetCell(inArgArray, j, mxCreateString(inArgs[j].c_str()));

		for(int j = 0; j < helpLines.size(); ++j)
			mxSetCell(helpArray, j, mxCreateString(helpLines[j].c_str()));

		mxSetField(outArray, i, "command", cmdStrArray);
		mxSetField(outArray, i, "outArgs", outArgArray);
		mxSetField(outArray, i, "inArgs", inArgArray);
		mxSetField(outArray, i, "helpLines", helpArray);
	}

	plhs[0] = outArray;

	return;
}

void MexInfo::usage(std::vector<std::string>& outArgs, std::vector<std::string>& inArgs) const
{
	outArgs.push_back("commandInfo");
}

void MexInfo::help(std::vector<std::string>& helpLines) const
{
	helpLines.push_back("Get information on all available mex commands.");
	helpLines.push_back("Returns commandInfo structure array containing information on all mex commands.");
	helpLines.push_back("   commandInfo.command - Command string");
	helpLines.push_back("   commandInfo.outArgs - Cell array of output arguments");
	helpLines.push_back("   commandInfo.inArgs - Cell array of input arguments");
	helpLines.push_back("   commandInfo.helpLines - Cell array of input arguments");
}

// MexCommandHelp - This is the help command which can be used to print usage of other commands
std::string MexHelp::check(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
	if(nrhs > 1||(nrhs==1&&!mxIsChar(prhs[0])))
		return "Expected a single command string argument.";

	if(nlhs > 0)
		return "Output arguments are not supported for this command";

	// Valid: Print full usage list.
	if(nrhs==0)
		return "";

	char cmdBuffer[256];
	int cmdLen = mxGetString(prhs[0], cmdBuffer, 256);

	MexCommand* mexCmd = MexCommand::getCommand(cmdBuffer);
	if(mexCmd==NULL)
		return std::string("Unrecognized command ")+cmdBuffer;

	return "";
}

void MexHelp::execute(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) const
{
	// Print command list.
	if(nrhs==0)
	{
		mexPrintf("%s", MexCommand::printUsageList().c_str());
		return;
	}

	// Otherwise print specified command usage
	char cmdBuffer[256];
	int cmdLen = mxGetString(prhs[0], cmdBuffer, 256);

	MexCommand* mexCmd = MexCommand::getCommand(cmdBuffer);
	if(mexCmd==NULL)
		return;

	mexPrintf("%s", MexCommand::printCommandHelp(mexCmd).c_str());

	return;
}

void MexHelp::usage(std::vector<std::string>& outArgs, std::vector<std::string>& inArgs) const
{
	inArgs.push_back("command");
}

void MexHelp::help(std::vector<std::string>& helpLines) const
{
	helpLines.push_back("Help on a specified command.");
	helpLines.push_back("Print detailed usage information for the specified command.");
}
