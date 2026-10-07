# Keymaps

Leader: `<Space>`. `<localleader>` also `<Space>` (most localleader bindings live inside grug-far's buffer).

## Global

| Key                 | Mode | Description                                                      |
| ------------------- | ---- | ---------------------------------------------------------------- |
| `<C-h/j/k/l>`       | N    | Pane navigation: nvim splits + tmux/wezterm panes (smart-splits) |
| `<A-h/j/k/l>`       | N/V  | mini.move: shuffle line / block (reindents on h/l)               |
| `<leader>h`         | N    | Clear search highlight                                           |
| `<Esc>`             | N    | Clear search highlight                                           |
| `<leader>bs`        | N    | Save (writes auto-mkdir parent dirs)                             |
| `<leader>D`         | N/V  | Delete without yank (`<leader>d` reserved for dap)               |
| `<leader>p`         | N    | Paste + auto-reindent (plain paste in indent-sensitive ft)       |
| `<leader>p`         | V    | Paste without overwriting register                               |
| `<leader>P`         | V    | Paste over + auto-reindent                                       |
| `<` / `>`           | V    | Indent / outdent (keep selection)                                |
| `J` / `<leader>j`   | N    | Join lines keeping cursor / without a space (`gJ`)               |

> `n`, `N`, `*`, `#`, `g*`, `g#` auto-center the cursor (`zvzz`); `[c`/`]c` do too, in diff mode.
> The jumplist is session-local (cleared at startup), so `<C-o>` / `<C-i>` only revisit files opened this session.
> `:s/…` shows a live split preview (`inccommand`); `:grep` uses ripgrep; visual-block edits extend past line-end.
> `y` yanks also land in the system clipboard (nvim's provider: wl-copy / xclip / xsel / pbcopy / clip.exe, OSC52 over SSH).
> Macro recording shows `@a` in the statusline while active.
> Spell check (camelCase-aware) on `gitcommit` / `markdown` / `text`; `:q` / `:bd` prompt to save on unsaved changes.

## Find & Navigate

> Modal floats (pickers, snacks terminal, lazy, Mason, lazygit, checkhealth) are mutually exclusive; auxiliary floats (hover, completion, notifier, …) stack on top.

| Key                                   | Description                                                      |
| ------------------------------------- | ---------------------------------------------------------------- |
| `<leader>ff`                          | fff: find files (Rust-backed, sub-10ms on huge codebases)        |
| `<leader>fF`                          | fff: find files in current directory                             |
| `<leader>fg`                          | fzf-lua live grep                                                |
| `<leader>fr` / `fb` / `fh`            | snacks.picker: recent / buffers / help                           |
| `<leader>fB`                          | snacks.picker: live grep across open buffers                     |
| `<leader>fi` / `fH`                   | snacks.picker: insert icon / inspect highlight groups            |
| `<leader>ft`                          | TODO comments                                                    |
| `<leader>fp`                          | snacks.picker: recent projects (cd + restore)                    |
| `<leader>fR`                          | Rename current file (LSP-aware)                                  |
| `<leader>fS`                          | Snippets (LuaSnip, ft + inherited + all)                         |
| `<leader>fs`                          | Edit the current filetype's snippet file (LuaSnip)               |
| `<leader>zz` / `z'`                   | fzf-lua: builtin menu / resume last picker                       |
| `<leader>-` / `<leader>fy`            | yazi: open at current file / in cwd (needs `yazi` binary)        |
| `<leader>e`                           | oil: edit current dir as a buffer (rename/move/delete via edits) |
| `s` / `S` (n/x/o)                     | flash: jump / treesitter jump                                    |
| `r` / `R` / `<C-s>`                   | flash: remote (o) / treesitter search (o/x) / toggle in `/` (c)  |
| `[j` / `]j`, `[l` / `]l`, `[u` / `]u` | mini.bracketed: jumplist / loclist / undo-state nav              |
| `<leader>?`                           | which-key: all keymaps (`<C-d>`/`<C-u>` flip pages)              |

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

## Session (persistence.nvim)

Bare `nvim` (and `nvim <dir>`, which cd's in) auto-restores the cwd session (skipped in headless or when it has no real files). File launches (`nvim <file>` / `nvim a b`) don't; `nvim dir1 dir2` keeps per-dir sessions but manual (`<leader>qs`). See Launch modes in FEATURES. Only window-visible buffers persist. Sessions are scoped per git branch — feature branches keep separate layouts (main/master share the base session).

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
> `gd`/`gr`/`gI`/`gy` open an fzf-lua picker (auto-jumps on a single result).
>
> Severity-sorted; gutter signs `✗`/`!`/`i`/`?` (statusline shows `E`/`W`/`I`/`H` counts). Diag float shows source when ambiguous.

| Key                         | Description                                                          |
| --------------------------- | -------------------------------------------------------------------- |
| `K` / `<C-k>` (i)           | Hover / signature help                                               |
| `gd` / `gD`                 | Definition / declaration                                             |
| `gr` / `gI` / `gy`          | References / implementation / type definition                        |
| `<leader>cI` / `cG` / `cH`  | Incoming / outgoing calls / type hierarchy (sub+super picker)        |
| `<leader>rn`                | Rename (inc-rename live preview)                                     |
| `<leader>cc` / `<leader>ca` | Diagnostics float / code action (n+x, tiny-code-action diff preview) |
| `<leader>cf`                | Format buffer (native LSP); visual selection = range format          |
| `<leader>ci` / `<leader>uh` | Toggle inlay hints (alias)                                           |
| `<leader>uy`                | Toggle LSP semantic tokens                                           |
| `<leader>cd` / `<leader>cl` | Toggle inline diagnostic / virtual_lines (current line)              |
| `<leader>cM`                | Toggle multi-diagnostic on cursorline                                |
| `<leader>ud`                | Toggle all diagnostics (Snacks)                                      |
| `<leader>cL`                | Run CodeLens (rust-analyzer, gopls, elixir-ls, ocamllsp, lua_ls)     |
| `<leader>cs`                | `:LspRestart` (recover from a hung server)                           |
| `<leader>cO` / `<leader>cN` | aerial: outline / outline nav                                        |
| `[o` / `]o`                 | aerial: previous / next symbol                                       |
| `<leader>cm`                | Open Mason                                                           |
| `<leader>xx/xd/xq/xl`       | Trouble: diagnostics / buf / qf / loclist                            |
| `<leader>xr` / `<leader>xs` | Trouble: LSP references / symbols                                    |
| `gO`                        | Trouble: LSP defs / refs (overrides the 0.11 default)                |
| `<leader>xi` / `<leader>xo` | Trouble: incoming / outgoing calls                                   |
| `<leader>xy` / `<leader>xm` | Trouble: type definitions / implementations                          |
| `<leader>x<` / `<leader>x>` | Quickfix stack: older / newer list                                   |
| `<leader>xQ` / `<leader>xL` | quicker.nvim: editable quickfix / loclist (`>`/`<` expand context)   |
| `<leader>xE` / `<leader>xe` | Diagnostics → native quickfix / buffer loclist                       |
| `<leader>xt` / `<leader>xT` | Trouble: TODOs / TODO+FIX+FIXME                                      |
| `[q` / `]q`                 | Prev / next item (Trouble + qf fallback)                             |
| `[d` / `]d`                 | Prev / next diagnostic, any severity (Neovim built-in)               |
| `[e` / `]e`                 | Prev / next **error** only                                           |
| `[W` / `]W`                 | Prev / next **warning** only                                         |
| `[t` / `]t`                 | Prev / next TODO comment (`;`/`,` repeats)                           |

> Severity jumps (`[e` / `]e` / `[W` / `]W`) open the diagnostic float.

> In the quickfix window (nvim-bqf): `o` open · `O` open & close · `<C-s>` / `<C-v>` split / vsplit · `t` / `T` tab / tab (bg) · `z,` toggle preview · `K` scroll preview up.

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
| `]f` / `[f`                 | n/x/o | Next / prev function start                                                |
| `]F` / `[F`                 | n/x/o | Next / prev function end                                                  |
| `]C` / `[C`                 | n/x/o | Next / prev class start (lowercase `]c`/`[c` left for diff change motion) |
| `]a` / `[a`                 | n/x/o | Next / prev parameter                                                     |
| `;` / `,`                   | n/x/o | Repeat last move forward / backward (TS goto / `f` / `t` / hunk / TODO)   |
| `<leader>cA` / `<leader>cS` | n     | Swap parameter with next / prev                                           |
| `<leader>cj` / `<leader>ck` | n     | Swap function with next / prev sibling                                    |
| `an` / `in`                 | x/o   | TS select: expand to parent / shrink to child node (0.12 native)          |
| `]n` / `[n`                 | x/o   | TS select: next / prev sibling node (0.12 native)                         |
| `<leader>uc`                | n     | Toggle treesitter context                                                 |
| `<leader>uC`                | n     | Toggle nvim-colorizer                                                     |
| `<leader>uU`                | n     | Toggle undotree                                                           |
| `<leader>uz` / `<leader>uZ` | n     | Snacks zen / zen zoom                                                     |
| `<leader>uD`                | n     | Toggle database UI (dadbod-ui)                                            |
| `<leader>us` / `<leader>ur` | n     | Snacks toggle: spell / relative number                                    |
| `<leader>ul` / `<leader>uo` | n     | Snacks toggle: line number / conceal                                      |
| `<leader>ui`                | n     | Snacks toggle: list chars (whitespace)                                    |
| `<leader>uT` / `<leader>ux` | n     | Toggle treesitter highlight (Snacks) / hex view                           |
| `<leader>ut`                | n     | Inspect treesitter tree (`:InspectTree`)                                  |
| `<leader>um` / `<leader>ug` | n     | Snacks toggle: zoom (maximize) / indent guides                            |
| `[x`                        | n     | Jump to context start                                                     |

> **mini.ai** adds bracket/quote/tag textobjects (`a(` / `i"` / `at`) with next/last search — `aN(` / `iN"` (next), `aL(` / `iL"` (last) — plus `ag`/`ig` (whole buffer) and `ad`/`id` (number).

## Git

| Key                                           | Description                                                                                                        |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `<leader>gs/gb/gd/gl/gc/gp/gP`                | fugitive: status/blame/diff/log/commit/push/pull                                                                   |
| `<leader>gD`                                  | fugitive: 3-way diffsplit (`:Gvdiffsplit!`) — for merge conflicts                                                  |
| `<leader>gg/gf/gL`                            | lazygit: open / file history / log                                                                                 |
| `<leader>gB`                                  | gitbrowse: open current line in browser (n/v)                                                                      |
| `[h` / `]h`                                   | Prev / next hunk (auto-preview on jump; `;`/`,` repeats)                                                           |
| `[H` / `]H`                                   | Prev / next staged hunk                                                                                            |
| `<leader>ghs/r/S/R/p/i/b/c/d/D`               | Stage (toggle) / reset / stage-buf / reset-buf / preview / inline preview / blame-line / blame-file / diff / diff~ |
| `<leader>ghq` / `ghQ`                         | gitsigns: hunks to quickfix — attached buffers / whole repo                                                        |
| `<leader>ghv`                                 | gitsigns: show the file at the index (read-only)                                                                   |
| `<leader>gtb` / `<leader>gtd` / `<leader>gtw` | Toggle line blame / show deleted / word diff                                                                       |
| `ih` / `ah` (o/x)                             | gitsigns hunk textobject (`d ih`, `v ah`)                                                                          |

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
| `<leader>dH`                  | Hit-condition breakpoint (break on the Nth hit)                 |
| `<leader>dGt` / `<leader>dGl` | Go: nearest test / last test                                    |
| `<leader>dPt` / `<leader>dPc` | Python: test method / class                                     |

## Test (neotest)

Python (pytest), Go (gotestsum), Elixir (mix), C/C++ (gtest + ctest: Catch2 / doctest), Lua (busted + plenary), Rust (rustaceanvim), Zig, JS-TS (vitest / jest). `:RustLsp testables` still works as a Rust-only picker. Summary window state restored across sessions. Inside the summary window: `<Tab>` / `zo` expand, `zR` expand all.

| Key                        | Description                                  |
| -------------------------- | -------------------------------------------- |
| `<leader>nr` / `nf` / `nA` | Run nearest / file / all (cwd)               |
| `<leader>nl` / `nd` / `nx` | Last / debug (DAP) / stop                    |
| `<leader>ns/no/nO/nw`      | Summary / output / output panel / watch file |
| `<leader>nc` / `nC`        | Coverage: load & show / summary              |
| `<leader>nv` / `nX`        | Coverage: toggle signs / clear               |
| `]T` / `[T`                | Next / prev failed test                      |

## Tasks (overseer)

Build / run via overseer's auto-detected templates (make / npm / cargo / go / just / cmake).

| Key          | Description       |
| ------------ | ----------------- |
| `<leader>Rr` | Run a task        |
| `<leader>Rt` | Toggle task list  |
| `<leader>Rc` | Run shell command |
| `<leader>Ra` | Task action       |

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

## Comment (built-in `gc`)

Built-in `gc` picks the right syntax for embedded languages (JSX, Vue, md fences); `gco` / `gcO` / `gcA` are rebuilt on top of it in `lua/config/keymaps.lua`.

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

Open keys only open or focus — never close — so `<space>t` stays typable at the shell prompt.

| Key                                        | Description                                                                                                                |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `<leader>t`                                | Open / focus terminal #1 (centered float; `N<leader>t` → instance N)                                                       |
| `<leader>T`                                | Open / focus terminal #2                                                                                                   |
| `<Esc>` (normal mode)                      | Hide terminal. Terminal mode keeps Esc for lazygit / shell TUIs.                                                           |
| `<C-x>`                                    | Hide terminal (works in terminal mode too)                                                                                 |
| `<leader>w`                                | Delete buffer (on dashboard → file buf if any, else `:qall`)                                                               |
| `<leader>;`                                | Toggle dashboard (peek; press again to return)                                                                             |
| `<leader>bd` / `<leader>bD`                | Snacks.bufdelete: confirm-on-modified / force                                                                              |
| `<leader>.` / `<leader>bS`                 | Snacks scratch: toggle / select buffer                                                                                     |
| `<leader>sn`                               | Snacks scratch: per-project markdown notes                                                                                 |
| `[b` / `]b` · `<S-h>` / `<S-l>`            | Prev / next buffer (mini.bracketed / `:bprevious` `:bnext`); `<leader>fb` to pick                                          |
| `<leader>cn` / `<leader>un`                | Notification history / dismiss all                                                                                         |
| `<leader>yp` / `<leader>yP` / `<leader>yl` | Yank file path to `+`: absolute / relative / relative:line                                                                 |
| `<leader>yg`                               | Yank git permalink for the current line                                                                                    |
| `]]` / `[[`                                | LSP word: next / previous reference                                                                                        |
| `[i` / `]i`                                | Snacks scope: jump to top / bottom edge                                                                                    |

## Language-specific

| Key                                        | Description                                               |
| ------------------------------------------ | --------------------------------------------------------- |
| `<leader>ch`                               | C/C++: switch source ↔ header                             |
| `<leader>cR` / `<leader>dR` / `<leader>cT` | Rust: code action / debuggables / testables               |
| `<leader>cE` / `<leader>cP`                | Rust: expand macro / jump to parent module                |
| `<leader>co` / `<leader>cU`                | TS/JS: organize imports / remove unused                   |
| `<leader>co` / `<leader>cX`                | Python: organize imports / fix all (ruff)                 |
| `<leader>co` / `<leader>cX`                | Go: organize imports / fix all (gopls)                    |
| `<leader>cv/cF/cu/cU/cD` (Cargo.toml)      | crates: versions / features / update / upgrade / docs     |
| `<leader>cv/cu/cU/cD` (package.json)       | package-info: versions / update / change version / delete |

## Misc

- **Open URL** (`gx`, n/v): stock nvim (LSP document links, treesitter URLs, paths).
- **Hex** (`xxd`): auto for binary files; `<leader>ux` toggle, `:HexDump`, `:HexAssemble`, or `nvim -b <file>`.
- **Completion** (insert): `<Tab>`/`<S-Tab>` (or `<C-n>`/`<C-p>`) next/prev · `<C-Space>` trigger · `<CR>` confirm · `<C-e>` close · `<C-k>` signature · `<C-f>`/`<C-b>` scroll docs · `<M-e>` wrap pair (autopairs). Menu columns: `label · source · kind`.
