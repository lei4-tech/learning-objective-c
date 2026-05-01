#pragma once
#include "Command.h"
#include <stack>
#include <memory>

// 命令历史栈：管理 execute / undo
class CommandManager {
public:
    void   execute(std::unique_ptr<ICommand> cmd);
    void   undo();
    bool   canUndo() const;
    size_t historyDepth() const;
    void   clear();
private:
    std::stack<std::unique_ptr<ICommand>> _history;
};
