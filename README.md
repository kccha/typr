# Typr

A Neovim plugin for practice typing with a very beautiful dashboard.

![typr](https://github.com/user-attachments/assets/4426d1c4-c4d3-4da7-987a-3b4c4395a4b5)
![typrstats](https://github.com/user-attachments/assets/b1653de3-05f3-4b90-b35e-9341eed8bf3e)
![typrstats vertical](https://github.com/user-attachments/assets/1ca824a0-5227-48c4-991c-f793cf62074a)

# Install

- Users which used typr before, delete your previous typrstats file.

```lua
{
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
}
```

- Note: Activity UI is still WIP so dont expect it to work.

# Config

https://github.com/nvzone/typr/blob/main/lua/typr/state.lua#L18

## Disable completion

Typr disables blink.cmp, nvim-cmp, mini.completion, the builtin `autocomplete`, mini.pairs and
auto-pairs in its buffer by itself. For any other completion plugin, disable it for the `typr`
filetype (see its documentation), or do it in `on_attach`.

# Layout

`:Typr` and `:TyprStats` open in the current window as a normal buffer (no floating window).
The UI is centered in that window and re-centers whenever the window is resized; `q` or `<ESC>`
brings back the buffer that was there before.

# Mappings

Whatever buttons you see, the mapping starts from their first letter i.e

In Typr window

- s = toggle symbols
- n = toggle numbers
- r = toggle random
- p = toggle phrases
- c = toggle code
- 1 to 9, 0 = set 3, 6, 9 ... 27 or 30 lines (3 per key, 0 is 30)

# Code mode

Practice typing code instead of prose: press `c` in the Typr window, or make it the default with
`mode = "code"`. Snippets are typed line by line with their indentation; `<Tab>` fills in a line's
indentation for you. C++ snippets are built in, and you can add your own or other languages:

```lua
opts = {
  mode = "code",
  code = {
    lang = "rust", -- default "cpp"
    snippets = {
      -- replaces the built-in snippets for that language
      rust = {
        "fn main() {\n    let v: Vec<i32> = (1..=10).collect();\n    println!(\"{:?}\", v);\n}",
      },
    },
  },
}
```

Lines wider than the typing area (76 columns) are skipped.

## Code from your own files

`:Typr ~/projects/engine/src` types code from the files in that directory (searched recursively,
skipping hidden directories, `node_modules`, `build` and the like). To make it the default:

```lua
opts = {
  mode = "code",
  code = {
    paths = { "~/projects/engine/src" },
    filetypes = { "cpp", "c" }, -- optional, programming languages by default
  },
}
```

Tests start at good spots: functions and classes found with treesitter (using the
nvim-treesitter-textobjects queries when installed), or, for languages without a parser, at
unindented lines after a blank line. From there the file is read on, dedented to the first line, and
stops before lines that are too wide, contain non-ASCII characters, or leave the scope it started
in. The file and line a test came from is shown below the code until you start typing.

Everything has to be typed by hand: Typr turns off completion (blink.cmp, nvim-cmp, mini.completion
and the builtin `autocomplete`) and auto pairing (mini.pairs, auto-pairs) in its buffer, and maps
brackets and quotes to insert only themselves, so no closing pair is ever added for you.

In Typrstats vertical window

- D = dashboard
- H = history
- K = Keystrokes
