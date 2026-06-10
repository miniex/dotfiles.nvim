# Keymaps

Leader: `<Space>`. `<localleader>` also `<Space>` (most localleader bindings live inside grug-far's buffer).

## Global

| Key                      | Mode | Description                                              |
| ------------------------ | ---- | -------------------------------------------------------- |
| `<C-h/j/k/l>`            | N/T  | Pane navigation with tmux-style return-to-last           |
| `<C-Left/Right/Up/Down>` | N    | Resize the focused edge window (in an edgy sidebar)      |
| `<A-h/j/k/l>`            | N/V  | mini.move: shuffle line / block (reindents on h/l)       |
| `<C-a>` / `<C-x>`        | N/V  | dial: smart inc/dec (bools, dates, semver, hex, &&↔\|\|) |
| `g<C-a>` / `g<C-x>`      | V    | dial: cumulative inc/dec across selection                |
| `<leader>h`              | N    | Clear search highlight                                   |
| `<Esc>`                  | N    | Clear search highlight                                   |
| `<leader>bs`             | N    | Save (writes auto-mkdir parent dirs)                     |
| `<leader>D`              | N/V  | Delete without yank (`<leader>d` reserved for dap)       |
| `<leader>p`              | N    | Paste + auto-reindent (`=` over pasted lines)            |
| `<leader>p`              | V    | Paste without overwriting register                       |
| `<leader>P`              | V    | Paste over + auto-reindent                               |
| `<` / `>`                | V    | Indent / outdent (keep selection)                        |
| `J` / `<leader>j`        | N    | Join lines keeping cursor / without a space (`gJ`)       |
| `gx`                     | N    | Open URL / file under cursor (`vim.ui.open`)             |

> `n`, `N`, `*`, `#`, `g*`, `g#`, `<C-o>`, `<C-i>` auto-center the cursor (`zvzz`); `[c`/`]c` do too, in diff mode.
> The jumplist is session-local (cleared at startup), so `<C-o>` / `<C-i>` only revisit files opened this session.
> `:s/…` shows a live split preview (`inccommand`); `:grep` uses ripgrep; visual-block edits extend past line-end.
> Yank → system clipboard via `wl-copy` / `xclip` / `pbcopy` / `clip.exe` (first available), else OSC52 over SSH.
> `p` / `P` feed a yank ring (yanky); `]y` / `[y` cycle to a newer / older yank right after pasting.
> Macro recording shows a `recording @a` / `saved @a` toast plus `● @a` in the statusline while active.
> Spell check (camelCase-aware) on `gitcommit` / `markdown` / `text`; `:q` / `:bd` prompt to save on unsaved changes.

## Find & Navigate

> Modal floats (pickers, snacks terminal, lazy, Mason, harpoon menu, lazygit, Neo-tree) are mutually exclusive; auxiliary floats (hover, completion, notifier, …) stack on top.

| Key                                   | Description                                                     |
| ------------------------------------- | --------------------------------------------------------------- |
| `<leader>ff`                          | fff.nvim: find files (Rust-backed, sub-10ms on huge codebases)  |
| `<leader>fF`                          | fff.nvim: find files in current directory                       |
| `<leader>fg` / `fr` / `fb` / `fh`     | snacks.picker: grep / recent / buffers / help                   |
| `<leader>fB`                          | snacks.picker: live grep across open buffers (the tab list)     |
| `<leader>fi` / `fH`                   | snacks.picker: insert icon / inspect highlight groups           |
| `<leader>ft`                          | TODO comments                                                   |
| `<leader>fp`                          | snacks.picker: recent projects (cd + restore)                   |
| `<leader>fR`                          | Rename current file (LSP-aware)                                 |
| `<leader>fS`                          | Snippets (LuaSnip, ft + inherited + all)                        |
| `<leader>zz` / `z'`                   | fzf-lua: builtin menu / resume last picker                      |
| `<leader>e` / `<leader>o`             | Neo-tree: toggle / reveal                                       |
| `<cr>` / `l` / `h` (in Neo-tree)      | Open file in main window; folder expand / collapse              |
| `<leader>L`                           | View current file in `less` (read-only, own tab)                |
| `s` / `S` (n/x/o)                     | flash: jump / treesitter jump                                   |
| `r` / `R` / `<C-s>`                   | flash: remote (o) / treesitter search (o/x) / toggle in `/` (c) |
| `w` / `e` / `b` / `ge` (n/o/x)        | nvim-spider: sub-word (camelCase / snake_case) motion           |
| `[j` / `]j`, `[l` / `]l`, `[u` / `]u` | mini.bracketed: jumplist / loclist / undo-state nav             |
| `<leader>?`                           | which-key: all keymaps (`<C-d>`/`<C-u>` flip pages)             |

## fzf-lua (`<leader>z*`)

Native `fzf` binary. `<C-q>` → quickfix; `<C-d>`/`<C-u>` paginate preview; `<C-/>` toggles the help.

| Key                      | Description                                                       |
| ------------------------ | ----------------------------------------------------------------- |
| `<leader>zz` / `z'`      | Builtin picker menu / resume last                                 |
| `<leader>zw`             | Grep word under cursor (n) / visual selection (x)                 |
| `<leader>zg/zc/zC/zb/zh` | Git: status / buffer commits / project commits / branches / stash |
| `<leader>zs` / `zS`      | LSP: document / live workspace symbols                            |
| `<leader>zd` / `zD`      | Diagnostics: buffer / workspace                                   |
| `<leader>zl/zk/zm/zr`    | blines / keymaps / marks / registers                              |
| `<leader>z:` / `z/`      | Command / search history                                          |
| `<leader>z;` / `zt`      | Commands (palette) / colorschemes (live preview)                  |

## Marks (harpoon v2)

Per-project file slots under `~/.local/share/nvim/harpoon/`.

| Key                         | Description                  |
| --------------------------- | ---------------------------- |
| `<leader>ma` / `<leader>mm` | Add file / toggle quick menu |
| `<leader>mn` / `<leader>mp` | Next / previous slot         |
| `]m` / `[m`                 | Next / previous slot (alias) |
| `<leader>m1` … `<leader>m5` | Jump to slot 1–5             |
| `<leader>md`                | Remove current file          |

## Multi-Cursors (multicursor.nvim)

Under `<leader>M` (capital); `<leader>m` belongs to harpoon.
`<Esc>` priority: clear cursor set → exit visual (if any) → `nohlsearch`. Visual mode `<Esc>` works normally when no multi-cursors are active.

| Key                         | Mode | Description                                                                     |
| --------------------------- | ---- | ------------------------------------------------------------------------------- |
| `<leader>Mn` / `<leader>MN` | n/x  | Add cursor + jump to next/prev `<cword>`                                        |
| `<leader>Ms` / `<leader>MS` | n/x  | Skip current match forward / backward                                           |
| `<leader>MA`                | n/x  | Cursor on every match in buffer                                                 |
| `<leader>M/`                | x    | Split visual selection by regex                                                 |
| `<C-Up>` / `<C-Down>`       | n/x  | Add cursor above / below                                                        |
| `<leader>Ma`                | n/x  | Align cursors with spaces                                                       |
| `<leader>Mu`                | n    | Restore last cursor set                                                         |
| `<leader>Mx`                | n/x  | Delete focused cursor                                                           |
| `<left>` / `<right>`        | n/x  | Focus prev / next cursor (falls through to normal motion when no extra cursors) |
| `<c-leftmouse>`             | n    | Add cursor at click                                                             |

## Undo History (`:Undotree`, 0.12 built-in)

| Key          | Description                                  |
| ------------ | -------------------------------------------- |
| `<leader>uU` | Open undo tree; j/k to step through history. |

## Search & Replace (grug-far)

Inside the grug-far buffer (`<localleader>` = `<Space>`): `r` replace · `s` / `l` sync all / current line to disk · `q` → quickfix · `<enter>` / `o` go to / open location · `i` preview · `f` refresh · `t` / `a` history open / add · `e` swap engine · `w` toggle command · `c` close · `b` abort · `g?` help.

| Key          | Mode | Description                          |
| ------------ | ---- | ------------------------------------ |
| `<leader>rr` | n    | Open at project root                 |
| `<leader>rR` | v    | Open with visual selection prefilled |
| `<leader>rf` | n    | Scoped to current file               |
| `<leader>rw` | n    | Prefilled with `<cword>`             |
| `<leader>ri` | v    | Search & replace within range        |
| `<leader>rs` | n/x  | Structural (AST-aware) replace — ssr |

## Session (persistence.nvim)

Bare `nvim` (and `nvim <dir>`, which cd's in) auto-restores the cwd session (skipped in headless or when it has no real files). File launches (`nvim <file>` / `nvim a b`) don't; `nvim dir1 dir2` keeps per-dir sessions but manual (`<leader>qs`). See Launch modes in FEATURES. Only window-visible buffers persist.

| Key          | Description                 |
| ------------ | --------------------------- |
| `<leader>qs` | Restore session for cwd     |
| `<leader>qS` | Select session from list    |
| `<leader>ql` | Restore last session        |
| `<leader>qd` | Don't save on exit          |
| `<leader>qR` | Restart Neovim (`:restart`) |

## Profiler (snacks.nvim)

`PROF=1 nvim` for startup; runtime keys below.

| Key          | Description                |
| ------------ | -------------------------- |
| `<leader>Pp` | Toggle profiler            |
| `<leader>Ps` | Profiler scratch buffer    |
| `<leader>Pf` | Pick captured frame        |
| `<leader>Ph` | Toggle profiler highlights |

## LSP / Diagnostics

> Neovim 0.11+'s default `grr`/`gri`/`grn`/`gra` are deleted on `LspAttach` so `gr` (References) fires without a `timeoutlen` wait; `gO` is remapped to Trouble below.
> `gd`/`gr`/`gi`/`gy` open an fzf-lua picker (auto-jumps on a single result).
>
> Severity-sorted; gutter signs `✗`/`!`/`i`/`?` mirror lualine; colors match the scrollbar marks. Diag float shows source when ambiguous.
> nvim-lightbulb: `❋` sign when a code action is available.

| Key                         | Description                                                        |
| --------------------------- | ------------------------------------------------------------------ |
| `K` / `<C-k>` (i)           | Hover / signature help                                             |
| `gd` / `gD`                 | Definition / declaration                                           |
| `gr` / `gi` / `gy`          | References / implementation / type definition                      |
| `<leader>cI` / `cG` / `cH`  | Incoming / outgoing calls / type hierarchy (sub+super picker)      |
| `<leader>rn`                | Rename (inc-rename live preview)                                   |
| `<leader>cc` / `<leader>ca` | Diagnostics float / code action (n+x, fzf picker)                  |
| `<leader>cr`                | Refactor: extract / inline (n+x picker, refactoring.nvim)          |
| `<leader>cf`                | Format buffer (native LSP); visual selection = range format        |
| `<leader>ci` / `<leader>uh` | Toggle inlay hints (alias)                                         |
| `<leader>uy`                | Toggle LSP semantic tokens                                         |
| `<leader>cd` / `<leader>cl` | Toggle inline diagnostic / virtual_lines (current line)            |
| `<leader>cM`                | Toggle multi-diagnostic on cursorline                              |
| `<leader>ud`                | Toggle all diagnostics (Snacks)                                    |
| `<leader>cL`                | Run CodeLens (rust-analyzer, gopls, elixir-ls, ocamllsp, lua_ls)   |
| `<leader>cs`                | `:LspRestart` (recover from a hung server)                         |
| `<leader>cO` / `<leader>cN` | aerial: outline / outline nav                                      |
| `[o` / `]o`                 | aerial: previous / next symbol                                     |
| `<leader>cm`                | Open Mason                                                         |
| `<leader>xx/xd/xq/xl`       | Trouble: diagnostics / buf / qf / loclist                          |
| `<leader>xr` / `<leader>xs` | Trouble: LSP references / symbols                                  |
| `gO`                        | Trouble: LSP defs / refs (overrides the 0.11 default)              |
| `<leader>x<` / `<leader>x>` | Quickfix stack: older / newer list                                 |
| `<leader>xQ` / `<leader>xL` | quicker.nvim: editable quickfix / loclist (`>`/`<` expand context) |
| `<leader>xE` / `<leader>xe` | Diagnostics → native quickfix / buffer loclist                     |
| `<leader>xt` / `<leader>xT` | Trouble: TODOs / TODO+FIX+FIXME                                    |
| `[q` / `]q`                 | Prev / next item (Trouble + qf fallback)                           |
| `[d` / `]d`                 | Prev / next diagnostic (any severity)                              |
| `[e` / `]e`                 | Prev / next **error** only                                         |
| `[W` / `]W`                 | Prev / next **warning** only                                       |
| `[t` / `]t`                 | Prev / next TODO comment                                           |

## Treesitter Textobjects & Context

| Key                         | Mode  | Description                                                               |
| --------------------------- | ----- | ------------------------------------------------------------------------- |
| `af` / `if`                 | x/o   | Function (outer / inner)                                                  |
| `ac` / `ic`                 | x/o   | Class                                                                     |
| `aa` / `ia`                 | x/o   | Parameter / argument                                                      |
| `ai` / `ii`                 | x/o   | Conditional                                                               |
| `al` / `il`                 | x/o   | Loop                                                                      |
| `a/` / `i/`                 | x/o   | Comment                                                                   |
| `a=` / `i=`                 | x/o   | Assignment                                                                |
| `am` / `im`                 | x/o   | Call                                                                      |
| `aB` / `iB`                 | x/o   | Block (capital — `b` is word-back)                                        |
| `aS`                        | x/o   | Statement                                                                 |
| `iI` / `aI`                 | x/o   | Indentation block (various-textobjs)                                      |
| `iv` / `av`                 | x/o   | Config value after `:` / `=` (various-textobjs)                           |
| `ik` / `ak`                 | x/o   | Config key (various-textobjs)                                             |
| `]f` / `[f`                 | n/x/o | Next / prev function start                                                |
| `]F` / `[F`                 | n/x/o | Next / prev function end                                                  |
| `]C` / `[C`                 | n/x/o | Next / prev class start (lowercase `]c`/`[c` left for diff change motion) |
| `]a` / `[a`                 | n/x/o | Next / prev parameter                                                     |
| `;` / `,`                   | n/x/o | Repeat last move forward / backward (TS goto / `f` / `t`)                 |
| `<leader>cA` / `<leader>cS` | n     | Swap parameter with next / prev                                           |
| `<leader>cj` / `<leader>ck` | n     | Swap function with next / prev sibling                                    |
| `<leader>cJ`                | n     | Split/join node — toggle one-line ↔ multi-line (treesj)                   |
| `gnn`                       | n     | Init incremental selection                                                |
| `gnm` / `gnM`               | x     | Expand / shrink node                                                      |
| `<leader>uc`                | n     | Toggle treesitter context                                                 |
| `<leader>uC`                | n     | Toggle nvim-colorizer                                                     |
| `<leader>uU`                | n     | Toggle undotree                                                           |
| `<leader>uz` / `<leader>uZ` | n     | Snacks zen / zen zoom                                                     |
| `<leader>uD`                | n     | Toggle database UI (dadbod-ui)                                            |
| `<leader>us` / `<leader>ur` | n     | Snacks toggle: spell / relative number                                    |
| `<leader>ul` / `<leader>uo` | n     | Snacks toggle: line number / conceal                                      |
| `<leader>ui`                | n     | Snacks toggle: list chars (whitespace)                                    |
| `<leader>uT` / `<leader>ux` | n     | Toggle treesitter highlight (Snacks) / hex view                           |
| `[x`                        | n     | Jump to context start                                                     |

> **mini.ai** adds bracket/quote/tag textobjects (`a(` / `i"` / `at`) with next/last search — `an(` / `in"` (next), `aL(` / `iL"` (last) — plus `ag`/`ig` (whole buffer) and `ad`/`id` (number).

## Winbar Breadcrumb (dropbar)

Inside the menu: `q`/`<Esc>` close, `h` parent (no-op at top), `l` open entry.

| Key          | Description                          |
| ------------ | ------------------------------------ |
| `<leader>uw` | Pick segment to jump to              |
| `[w` / `]w`  | Jump to context start / next context |

## Git

| Key                                           | Description                                                                                       |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `<leader>gs/gb/gd/gl/gc/gp/gP`                | fugitive: status/blame/diff/log/commit/push/pull                                                  |
| `<leader>gdv`                                 | fugitive: 3-way diffsplit (`:Gvdiffsplit!`) — for merge conflicts                                 |
| `<leader>gg/gf/gL`                            | lazygit: open / file history / log                                                                |
| `<leader>gB`                                  | gitbrowse: open current line in browser (n/v)                                                     |
| `<leader>gvo/gvc/gvr`                         | Diffview: open / close / refresh                                                                  |
| `<leader>gvf/gvF/gvh`                         | Diffview file history: current / repo / stash                                                     |
| `<leader>gvt` / `<leader>gvp`                 | Diffview: toggle / focus files panel                                                              |
| `<leader>gvg` / `<leader>gvG`                 | gitgraph.nvim: all branches / current (`<cr>` → diffview)                                         |
| `<leader>gvs` / `<leader>gvA`                 | gitgraph.nvim: prompt for `--since` / `--author` filter                                           |
| `<leader>gH`                                  | advanced-git-search: search history by content (log -S/-G/-L)                                     |
| `[h` / `]h`                                   | Prev / next hunk                                                                                  |
| `<leader>ghs/r/S/R/p/b/c/d/D`                 | Stage (toggle) / reset / stage-buf / reset-buf / preview / blame-line / blame-file / diff / diff~ |
| `<leader>ghq`                                 | gitsigns: hunks (attached buffers) to quickfix                                                    |
| `<leader>gtb` / `<leader>gtd` / `<leader>gtw` | Toggle line blame / show deleted / word diff                                                      |
| `ih` / `ah` (o/x)                             | gitsigns hunk textobject (`d ih`, `v ah`)                                                         |
| `<leader>gxq`                                 | git-conflict: conflicts to quickfix                                                               |
| `[X` / `]X`                                   | Prev / next conflict                                                                              |
| `co/ct/cb/c0`                                 | Inside conflict: ours / theirs / both / none                                                      |

## Debugger (DAP)

| Key                           | Description                                                     |
| ----------------------------- | --------------------------------------------------------------- |
| `<leader>db` / `dB` / `dX`    | Toggle / conditional / clear-all breakpoint (persisted per-cwd) |
| `<leader>dE`                  | Exception breakpoints (pick the adapter's filters)              |
| `<leader>dc` / `dC`           | Continue / run-to-cursor                                        |
| `<leader>di` / `dO` / `do`    | Step into / over / out                                          |
| `<leader>dg` / `dj` / `dk`    | Go to line / Down / Up frame                                    |
| `<leader>dl/dr/dp/dt/ds/du`   | Last / REPL / pause / terminate / session / toggle UI           |
| `<leader>dW`                  | Scopes as a centered float (dap.ui.widgets)                     |
| `<leader>de` / `<leader>dh`   | Eval cursor / selection (n+v) / hover value                     |
| `<leader>dL`                  | Log point (message breakpoint)                                  |
| `<leader>dGt` / `<leader>dGl` | Go: nearest test / last test                                    |
| `<leader>dPt` / `<leader>dPc` | Python: test method / class                                     |

## Test (neotest)

Python (pytest), Go (gotestsum), Elixir (mix), C/C++ (gtest), Lua (busted), Rust (rustaceanvim), Zig, JS-TS (vitest / jest). `:RustLsp testables` still works as a Rust-only picker. Summary window state restored across sessions. Inside the summary window: `<Tab>` / `zo` expand, `zR` expand all.

| Key                        | Description                                  |
| -------------------------- | -------------------------------------------- |
| `<leader>nr` / `nf` / `nA` | Run nearest / file / all (cwd)               |
| `<leader>nl` / `nd` / `nx` | Last / debug (DAP) / stop                    |
| `<leader>ns/no/nO/nw`      | Summary / output / output panel / watch file |
| `<leader>nc` / `nC`        | Coverage: load & show / summary              |
| `]T` / `[T`                | Next / prev failed test                      |

## Tasks (overseer)

Build / run via overseer's auto-detected templates (make / npm / cargo / go / just / cmake).

| Key          | Description       |
| ------------ | ----------------- |
| `<leader>Rr` | Run a task        |
| `<leader>Rt` | Toggle task list  |
| `<leader>Rc` | Run shell command |
| `<leader>Ra` | Task quick action |
| `<leader>Ri` | Overseer info     |

## REPL (iron)

Send-to-REPL for python / lua / sh / elixir / js-ts.

| Key                 | Mode | Description             |
| ------------------- | ---- | ----------------------- |
| `<leader>ii` / `iR` | n    | Toggle / restart REPL   |
| `<leader>is`        | n/x  | Send motion / selection |
| `<leader>il` / `if` | n    | Send line / file        |
| `<leader>iq` / `ic` | n    | Exit / clear REPL       |

## REST (kulala)

HTTP client for `.http` / `.rest` files.

| Key          | Description              |
| ------------ | ------------------------ |
| `<leader>kr` | Run request under cursor |
| `<leader>ka` | Run all requests in file |
| `<leader>kp` | Replay last request      |
| `<leader>ki` | Inspect parsed request   |
| `<leader>kc` | Copy request as `curl`   |

## Comment (Comment.nvim)

ts-context-commentstring picks the right syntax for embedded languages (JSX, Vue, …).

| Key                 | Mode | Description                            |
| ------------------- | ---- | -------------------------------------- |
| `gcc` / `gbc`       | n    | Toggle current line — line / block     |
| `gc{motion}` / `gb` | n/x  | Toggle linewise / blockwise (operator) |
| `gco` / `gcO`       | n    | Add comment line below / above         |
| `gcA`               | n    | Add comment at end of line             |

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

## Operators (mini.operators)

Uppercase prefixes — lowercase `gr` / `gs` / `gx` are taken (LSP refs / surround / open-URL).

| Key                  | Description                        | Example                  |
| -------------------- | ---------------------------------- | ------------------------ |
| `gR{motion}` / `gRR` | Replace with register (no clobber) | `gRiw` → paste over word |
| `gX{motion}` ×2      | Exchange two regions               | `gXiw` … `gXiw`          |
| `gS{motion}` / `gSS` | Sort                               | `gSip` → sort paragraph  |
| `g={motion}`         | Evaluate (replace with Lua result) |                          |

## Terminal & Buffers

In the toggle terminal, `$EDITOR`/`$VISUAL`/`$GIT_EDITOR` forward to the parent Neovim via `scripts/term-bin/nvim` — `git commit` opens a split in the outer instance.

| Key                                        | Description                                                                                                                |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `<leader>t` (n/t)                          | Toggle terminal (centered float)                                                                                           |
| `<C-x>`                                    | Hide terminal                                                                                                              |
| `<leader>w`                                | Smart buffer delete (last file → dashboard, or exit in a single-file launch; on dashboard → file buf if any, else `:qall`) |
| `:q` / `:wq` / `:x` / `:exit` / `ZZ`       | Smart quit: bufdelete on last window, else `:quit`. `!` keeps force semantics. On dashboard → `:qall`; in `q:` → `:quit`.  |
| `ZQ`                                       | Force smart quit (no save)                                                                                                 |
| `<leader>;`                                | Toggle dashboard (peek; press again to return)                                                                             |
| `<leader>bd` / `<leader>bD`                | Snacks.bufdelete: confirm-on-modified / force                                                                              |
| `<leader>.` / `<leader>bS`                 | Snacks scratch: toggle / select buffer                                                                                     |
| `<leader>sn`                               | Snacks scratch: per-project markdown notes                                                                                 |
| `<leader>1` … `<leader>9` · `<leader>0`    | Jump to bufferline position 1–9 / 10                                                                                       |
| `[b` / `]b` · `<S-h>` / `<S-l>`            | Prev / next buffer (open-order)                                                                                            |
| `<leader>bp` / `<leader>bc`                | bufferline: pick buffer by letter / pick to close                                                                          |
| `<leader>cn` / `<leader>un`                | Notification history / dismiss all                                                                                         |
| `<leader>yp` / `<leader>yP` / `<leader>yl` | Yank file path to `+`: absolute / relative / relative:line                                                                 |
| `<leader>yg`                               | Yank git permalink for the current line                                                                                    |
| `<leader>yh`                               | Yanky ring history: pick an earlier yank and put it                                                                        |
| `]]` / `[[`                                | LSP word: next / previous reference                                                                                        |
| `[i` / `]i`                                | Snacks scope: jump to top / bottom edge                                                                                    |

## Language-specific

| Key                                        | Description                                               |
| ------------------------------------------ | --------------------------------------------------------- |
| `<leader>ch`                               | C/C++: switch source ↔ header                             |
| `<leader>cR` / `<leader>cD` / `<leader>cT` | Rust: code action / debuggables / testables               |
| `<leader>cE` / `<leader>cP`                | Rust: expand macro / jump to parent module                |
| `<leader>cI` / `<leader>cU`                | TS/JS: organize imports / remove unused                   |
| `<leader>cI` / `<leader>cX`                | Python: organize imports / fix all (ruff)                 |
| `<leader>cI` / `<leader>cX`                | Go: organize imports / fix all (gopls)                    |
| `<leader>cv/cF/cu/cU/cD` (Cargo.toml)      | crates: versions / features / update / upgrade / docs     |
| `<leader>cv/cu/cU/cD` (package.json)       | package-info: versions / update / change version / delete |

## Misc

- **Open URL** (`gx`, n/v): `vim.ui.open()` on link / path under cursor.
- **Hex** (`xxd`): auto for binary files; `<leader>ux` toggle, `:HexDump`, `:HexAssemble`, or `nvim -b <file>`.
- **Messages** (`:messages`): opens the message log in a centered modal (`q` / `<Esc>` to close).
- **Completion** (insert): `<Tab>`/`<S-Tab>` (or `<C-n>`/`<C-p>`) next/prev · `<C-Space>` trigger · `<CR>` confirm · `<C-e>` close · `<C-k>` signature · `<C-f>`/`<C-b>` scroll docs · `<M-e>` wrap pair (autopairs). Menu columns: `label · source · kind`.
