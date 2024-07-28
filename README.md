# Copilot Chat plugin for Neovim

## Description

`copilot-chat.lua` is a simple Neovim plugin for interacting with Copilot Chat.

## Status

Work in progress.

## Installation

The plugin depends on `plenary.nvim` and requires `curl` to be installed.
A Copilot plugin, either `copilot.lua` or `copilot.vim`, needs to be authenticated.

### Lazy.nvim

```lua
return {
  {
    "somnam/copilot-chat.lua",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    }
  },
}
```

## Usage

To use the plugin, follow these steps:

- `:CC <action>? <input>?` — Create a new chat buffer with optional input. Uses the `default` chat action if none is provided.

### Actions

Available Chat actions:
- `default[!]` - provide general suggestions or recommendations based on the input or context of the code
- `explain[!]` - learn more about the concepts or techniques used in the selected code
- `refactor[!]` - improve the structure, readability, or performance of the code
- `fix[!]` - identify and resolve bugs or problems in the code
- `tests[!]` - request suggestions for writing tests for code
- `new` - request suggestions for creating a new project
- `workspace` - help with tasks such as organizing files, configuring settings, or integrating external tools
- `commit` - generate commit messages

The current visual selection serves as context when executing the command.
Certain actions can be appended with an `!` to use the current file as the command context instead of visual selection.

### Chat buffer

After running the command a new markdown buffer is populated with the chat contents.
To continue the chat write a response in the buffer and run the `CC` command without any arguments.

## Examples

### Explain

Use visual mode to select a block of code and run `:CC explain`.

### Tests

Open a file and run `:CC tests!` to have unit tests generated for the file contents.

## Contributing

Please feel free to open an issue or submit a pull request if you have suggestions for improvements.
