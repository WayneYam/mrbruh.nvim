# mrbruh.nvim

My runner, but really, unreasonably hacky

I made this because when I did competitive programming I wanted a fast method of compiling and running programs. Most of the code is not my own, but I made this more than two years ago so I forgot who I stole it from

## Installation

Why?

With `lazy.nvim`

```

  {
    "WayneYam/mrbruh.nvim",
    opts = {},
    cmd = { "CompileFile", "RunFile", "ToggleCompile", "ToggleRun" },
  },
```

## Dependency

- `toggleterm.nvim`

## Usage

Use either of the four functions to compile, run and toggle their respective terminals.
