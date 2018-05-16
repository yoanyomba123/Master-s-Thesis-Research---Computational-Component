#include <queue>
#include "windows.h"

class Message
{
public:
	Message() { command="null"; data=NULL; }
	std::string command;
	void *data;
};

class DataQueue
{
public:
	DataQueue();
	~DataQueue();
	Message getNextMessage();
	void writeMessage(std::string cmd, void* data);
	size_t DataQueue::getNumMessages();
	void clear();

private:
	HANDLE mutex;
	std::queue<Message> messages;
	void addMessage(Message msg);
};