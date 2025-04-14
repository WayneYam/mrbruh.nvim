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
    keys = { "<F9>", "<F8>", "<C-F9>", "<C-F8>" },
  },
```

## Dependency

- `toggleterm.nvim`

## Usage

`<F9>`/`<F8>` to compile/run, `<C-F9>`/`<C-F8>` to toggle the respective terminals.
