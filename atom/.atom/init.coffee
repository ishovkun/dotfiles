# Overall required packaages:
# vim-mode-plus
# switch-header-source
# atom-commander
# atom-ide
# ide-cquery

path = require 'path'

atom.commands.add 'atom-workspace',
  'custom:open-todo-list': ->
    todoList = path.join(process.env.HOME, 'Dropbox/enotes/TODOs.org')
    atom.workspace.open(todoList)

  'atom-commander:show-and-focus': ->
    Commander = require("./packages/atom-commander")
    Commander.show(true);
    view = Commander.actions.getFocusedView();
    view.requestFocus();

  'custom:get-scope': ->
    scope = atom.workspace.getActiveTextEditor().getGrammar().scopeName;
    atom.notifications.addInfo(scope);
