#include "CommandManager.h"

void CommandManager::execute(std::unique_ptr<ICommand> cmd) {
    cmd->execute();
    _history.push(std::move(cmd));
}

void CommandManager::undo() {
    if (!canUndo()) return;
    _history.top()->undo();
    _history.pop();
}

bool CommandManager::canUndo() const {
    return !_history.empty();
}

size_t CommandManager::historyDepth() const {
    return _history.size();
}

void CommandManager::clear() {
    while (!_history.empty()) _history.pop();
}
