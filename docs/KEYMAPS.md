# Keymaps

Leader: `<Space>`. `<localleader>` also `<Space>` (most localleader bindings live inside grug-far's buffer).

## Global

| Key           | Mode | Description                                    |
| ------------- | ---- | ---------------------------------------------- |
| `<C-h/j/k/l>` | N/T  | Pane navigation with tmux-style return-to-last |
| `<leader>h`   | N    | Clear search highlight                         |
| `<leader>s`   | N    | Save                                           |
| `<leader>d`   | N/V  | Delete without yank                            |
| `<leader>p`   | V    | Paste without overwriting register             |
| `<` / `>`     | V    | Indent / outdent (keep selection)              |

## Find & Navigate

| Key                               | Description                                                    |
| --------------------------------- | -------------------------------------------------------------- |
| `<leader>ff`                      | fff.nvim: find files (Rust-backed, sub-10ms on huge codebases) |
| `<leader>fF`                      | fff.nvim: find files in current directory                      |
| `<leader>fg` / `fr` / `fb` / `fh` | snacks.picker: grep / recent / buffers / help                  |
| `<leader>ft`                      | TODO comments                                                  |
| `<leader>z` / `z'`                | fzf-lua: builtin menu / resume last picker                     |
| `<leader>e` / `<leader>o`         | Neo-tree: toggle / reveal                                      |
| `<cr>` / `l` (in neo-tree)        | Open file in new tabpage; folder expand/collapse               |
| `s` / `S` (n/x/o)                 | Flash: jump / treesitter jump                                  |
| `<leader>?`                       | which-key: buffer-local keymaps                                |

## fzf-lua (`<leader>z*`)

Native `fzf` binary. `<C-q>` → quickfix; `<C-d>`/`<C-u>` paginate preview.

| Key                   | Description                                               |
| --------------------- | --------------------------------------------------------- |
| `<leader>z` / `z'`    | Builtin picker menu / resume last                         |
| `<leader>zg/zc/zC/zb` | Git: status / buffer commits / project commits / branches |
| `<leader>zs` / `zS`   | LSP: document / live workspace symbols                    |
| `<leader>zd` / `zD`   | Diagnostics: buffer / workspace                           |
| `<leader>zl/zk/zm/zr` | blines / keymaps / marks / registers                      |
| `<leader>z:` / `z/`   | Command / search history                                  |

## Marks (harpoon v2)

Per-project file slots under `~/.local/share/nvim/harpoon/`.

| Key                         | Description                  |
| --------------------------- | ---------------------------- |
| `<leader>ma` / `<leader>mm` | Add file / toggle quick menu |
| `<leader>mn` / `<leader>mp` | Next / previous slot         |
| `<leader>m1` … `<leader>m5` | Jump to slot 1–5             |

> **Conflict:** multicursor.nvim also binds `<leader>mn`/`mN`/`ms`/`mS`/`mA`/`ma`/`mu`/`mx`. Harpoon's `mn`/`mp` wins on first registration; redefine in `multicursor.lua` if you need both.

## Multi-Cursors (multicursor.nvim)

`<Esc>` priority: clear cursor set → exit visual (if any) → `nohlsearch`. Visual mode `<Esc>` works normally when no multi-cursors are active.

| Key                         | Mode | Description                              |
| --------------------------- | ---- | ---------------------------------------- |
| `<leader>mn` / `<leader>mN` | n/x  | Add cursor + jump to next/prev `<cword>` |
| `<leader>ms` / `<leader>mS` | n/x  | Skip current match forward / backward    |
| `<leader>mA`                | n/x  | Cursor on every match in buffer          |
| `<leader>m/`                | x    | Split visual selection by regex          |
| `<C-Up>` / `<C-Down>`       | n/x  | Add cursor above / below                 |
| `<leader>ma`                | n/x  | Align cursors with spaces                |
| `<leader>mu`                | n    | Restore last cursor set                  |
| `<leader>mx`                | n/x  | Delete focused cursor                    |
| `<left>` / `<right>`        | n/x  | Focus prev / next cursor                 |
| `<c-leftmouse>`             | n    | Add cursor at click                      |

## Undo History (undotree)

| Key          | Description                                            |
| ------------ | ------------------------------------------------------ |
| `<leader>uU` | Toggle undotree (j/k navigate, p preview, `<cr>` jump) |

## Search & Replace (grug-far)

Inside the grug-far buffer: `<localleader>r` replace, `<localleader>s` sync to disk, `<localleader>q` → quickfix.

| Key          | Mode | Description                          |
| ------------ | ---- | ------------------------------------ |
| `<leader>S`  | n    | Open at project root                 |
| `<leader>S`  | v    | Open with visual selection prefilled |
| `<leader>cs` | n    | Scoped to current file               |

## Session (persistence.nvim)

| Key          | Description              |
| ------------ | ------------------------ |
| `<leader>qs` | Restore session for cwd  |
| `<leader>qS` | Select session from list |
| `<leader>ql` | Restore last session     |
| `<leader>qd` | Don't save on exit       |

## Profiler (snacks.nvim)

`PROF=1 nvim` for startup; runtime keys below.

| Key          | Description                |
| ------------ | -------------------------- |
| `<leader>pp` | Toggle profiler            |
| `<leader>ps` | Profiler scratch buffer    |
| `<leader>pf` | Pick captured frame        |
| `<leader>ph` | Toggle profiler highlights |

## LSP / Diagnostics

| Key                         | Description                                                        |
| --------------------------- | ------------------------------------------------------------------ |
| `K` / `<C-k>` (i)           | Hover / signature help                                             |
| `gd` / `gr` / `gi`          | Definition / references / implementation                           |
| `<leader>rn`                | Rename                                                             |
| `<leader>cc` / `<leader>ca` | Diagnostics float / code action                                    |
| `<leader>ci`                | Toggle inlay hints                                                 |
| `<leader>cd` / `<leader>cl` | Toggle inline diagnostic / `virtual_lines`                         |
| `<leader>cL`                | Run CodeLens (rust-analyzer, gopls, elixir-ls, ocamllsp, jdtls, …) |
| `<leader>cO` / `<leader>cN` | Aerial: outline / outline nav                                      |
| `[o` / `]o`                 | Aerial: previous / next symbol                                     |
| `<leader>cm`                | Open Mason                                                         |
| `<leader>xx/xd/xs/xq/xl`    | Trouble: diagnostics / buf / symbols / qf / loclist                |
| `<leader>xQ` / `<leader>xL` | quicker.nvim: editable quickfix / loclist (`>`/`<` expand context) |
| `<leader>xt` / `<leader>xT` | Trouble: TODOs / TODO+FIX+FIXME                                    |
| `[q` / `]q`                 | Prev / next item (Trouble + qf fallback)                           |
| `[t` / `]t`                 | Prev / next TODO comment                                           |

## Treesitter Textobjects & Context

| Key                       | Mode  | Description                        |
| ------------------------- | ----- | ---------------------------------- |
| `af` / `if`               | x/o   | Function (outer / inner)           |
| `ac` / `ic`               | x/o   | Class                              |
| `aa` / `ia`               | x/o   | Parameter / argument               |
| `ai` / `ii`               | x/o   | Conditional                        |
| `al` / `il`               | x/o   | Loop                               |
| `a/` / `i/`               | x/o   | Comment                            |
| `a=` / `i=`               | x/o   | Assignment                         |
| `am` / `im`               | x/o   | Call                               |
| `aB` / `iB`               | x/o   | Block (capital — `b` is word-back) |
| `aS`                      | x/o   | Statement                          |
| `]f` / `[f`               | n/x/o | Next / prev function start         |
| `]F` / `[F`               | n/x/o | Next / prev function end           |
| `]c` / `[c`               | n/x/o | Next / prev class start            |
| `]a` / `[a`               | n/x/o | Next / prev parameter              |
| `<leader>a` / `<leader>A` | n     | Swap parameter with next / prev    |
| `gnn`                     | n     | Init incremental selection         |
| `gnm` / `gnM`             | x     | Expand / shrink node               |
| `<leader>uc`              | n     | Toggle treesitter context          |
| `<leader>uC`              | n     | Toggle nvim-colorizer              |
| `<leader>um`              | n     | Toggle render-markdown             |
| `<leader>uU`              | n     | Toggle undotree                    |
| `[x`                      | n     | Jump to context start              |

## Winbar Breadcrumb (dropbar)

Picker uses rounded border + preview. Inside: `q`/`<Esc>` close, `h` parent menu, `l` open entry.

| Key          | Description                          |
| ------------ | ------------------------------------ |
| `<leader>uw` | Pick segment to jump to              |
| `[w` / `]w`  | Jump to context start / next context |

## Git

| Key                             | Description                                                                                  |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| `<leader>gs/gb/gd/gl/gc/gp/gP`  | Fugitive: status/blame/diff/log/commit/push/pull                                             |
| `<leader>gg/gf/gF/gL`           | LazyGit: full / current file / filter file / filter all                                      |
| `<leader>gvo/gvc/gvr`           | Diffview: open / close / refresh                                                             |
| `<leader>gvf/gvF/gvh`           | Diffview file history: current / repo / stash                                                |
| `<leader>gvg` / `<leader>gvG`   | gitgraph.nvim: all branches / current (`<cr>` → diffview)                                    |
| `[h` / `]h`                     | Prev / next hunk                                                                             |
| `<leader>ghs/r/S/u/R/p/i/b/d/D` | Stage / reset / stage-buf / undo-stage / reset-buf / preview / inline / blame / diff / diff~ |
| `<leader>gtb` / `<leader>gtd`   | Toggle line blame / show deleted                                                             |
| `<leader>gxq`                   | git-conflict: conflicts to quickfix                                                          |
| `[X` / `]X`                     | Prev / next conflict                                                                         |
| `co/ct/cb/c0`                   | Inside conflict: ours / theirs / both / none                                                 |

## Debugger (DAP)

| Key                           | Description                                                     |
| ----------------------------- | --------------------------------------------------------------- |
| `<leader>db` / `dB` / `dX`    | Toggle / conditional / clear-all breakpoint (persisted per-cwd) |
| `<leader>dc` / `dC`           | Continue / run-to-cursor                                        |
| `<leader>di` / `dO` / `do`    | Step into / over / out                                          |
| `<leader>dg` / `dj` / `dk`    | Go to line / Down / Up frame                                    |
| `<leader>dl/dr/dp/dt/ds/du`   | Last / REPL / pause / terminate / session / toggle UI           |
| `<leader>dGt` / `<leader>dGl` | Go: nearest test / last test                                    |
| `<leader>dPt` / `<leader>dPc` | Python: test method / class                                     |

## Test (neotest)

Python (pytest), Go (gotestsum), Elixir (mix), C/C++ (gtest). Rust uses `:RustLsp testables`.

| Key                        | Description                                  |
| -------------------------- | -------------------------------------------- |
| `<leader>nr` / `nf` / `nA` | Run nearest / file / all (cwd)               |
| `<leader>nl` / `nd` / `nx` | Last / debug (DAP) / stop                    |
| `<leader>ns/no/nO/nw`      | Summary / output / output panel / watch file |
| `]T` / `[T`                | Next / prev failed test                      |

## Surround (mini.surround)

`gs*` prefix — flash owns `s`.

| Key                 | Description         | Example                     |
| ------------------- | ------------------- | --------------------------- |
| `gsa{motion}{char}` | Add                 | `gsaiw"` → wrap word in `"` |
| `gsd{char}`         | Delete              | `gsd"`                      |
| `gsr{old}{new}`     | Replace             | `gsr"'`                     |
| `gsf` / `gsF`       | Find right / left   |                             |
| `gsh`               | Highlight           |                             |
| `gsn`               | Update search range |                             |

## Terminal & Buffers

In the toggle terminal, `$EDITOR`/`$VISUAL`/`$GIT_EDITOR` forward to the parent Neovim via `scripts/term-bin/nvim` — `git commit` opens a split in the outer instance.

| Key                         | Description                                 |
| --------------------------- | ------------------------------------------- |
| `<leader>t` (n/t)           | Toggle terminal (centered float)            |
| `<C-x>`                     | Hide terminal                               |
| `<leader>w`                 | Smart buffer delete (last file → dashboard) |
| `<leader>bd` / `<leader>bD` | mini.bufremove: delete / force-delete       |
| `<leader>1` … `<leader>9`   | Jump to bufferline position                 |
| `[b` / `]b`                 | Prev / next buffer (open-order)             |
| `<leader>cn` / `<leader>un` | Notification history / dismiss all          |
| `]]` / `[[`                 | LSP word: next / previous reference         |

## Language-specific

| Key                         | Description                     |
| --------------------------- | ------------------------------- |
| `<leader>ch`                | C/C++: switch source ↔ header   |
| `<leader>cR` / `<leader>cD` | Rust: code action / debuggables |

## Misc

- **Hex** (`xxd`): `:HexToggle`, `:HexDump`, `:HexAssemble`, or `nvim -b <file>`.
- **Completion** (insert): `<Tab>`/`<S-Tab>` next/prev · `<C-Space>` trigger · `<CR>` confirm · `<C-e>` close · `<C-f>`/`<C-S-f>` scroll docs.
