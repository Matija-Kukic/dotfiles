# Lualine — Nordic Pill Style (manual)

The statusline design: two **accent pills** (` NORMAL` left, ` 1:1  Top` right) on a
solid themed bar, everything between in **muted grey**, no powerline triangles.
Reference: AlexvZyl's nordic.nvim showcase screenshot (`wallpapers/nordic_lualine.png.png`),
exact config recovered from **AlexvZyl/nvim@97425d3** (`lua/alex/ui/lualine.lua`), adapted
to be **colorscheme-agnostic** (works with catppuccin-mocha / everforest / gruvbox / monet
via `switch-theme`).

```
 NORMAL  tmux/tmux.conf  main  3  14         1:1   Top
└─ pill ─┘ └─ muted + bright ─┘ └──── all muted grey ────┘      └── one accent segment ──┘
```

**The only file:** `.config/nvim/lua/matijak/plugins/lualine.lua` (stow-linked live).

---

## How it works (5 pieces)

### 1. Theme name from the colorscheme system

```lua
local theme_name = "auto"
local ok, lines = pcall(vim.fn.readfile,
    vim.env.HOME .. "/.config/colorschemes/active/lualine-theme")
if ok and lines[1] and lines[1] ~= "" then theme_name = lines[1] end
```

Each scheme carries a one-line `colorschemes/<scheme>/lualine-theme` file
(`catppuccin-mocha` / `everforest` / `gruvbox-material` / `monet`). Fallback `"auto"`.

### 2. Theme surgery (makes any theme "nordic")

The scheme's official lualine theme **table** is loaded and tweaked in memory:

```lua
local tok, t = pcall(require, "lualine.themes." .. theme_name)
if tok and type(t) == "table" and t.normal then
    for _, m in pairs(t) do
        if m.b and m.c then m.b.bg = m.c.bg end   -- melt section b into the bar strip
    end
    theme = t
    local ia = t.inactive
    local muted = ia and ia.c and ia.c.fg          -- muted mid-bar fg per scheme
        or (t.normal.c and t.normal.c.fg)
    if muted then text_hl = { fg = muted } end
end
```

- lualine section→theme mapping is `a b c | x y z` → `a b c | c b a`, so pills come from
  `a` (mode) and `z` (location+progress, mapped to `a`). Keeping `c.bg` preserves the
  scheme's **solid statusline strip** (e.g. catppuccin mantle) instead of transparency.
- The muted grey is each theme's own `inactive.c.fg` (catppuccin overlay0, everforest
  grey0, …) — that's the "elegant" part: mid-bar never competes with the pills.
- Plugin-shipped themes (catppuccin, monet) resolve because the colorscheme plugin loads
  first (priority 1000 > lualine's 50).

### 3. Separators — component-level caps only

```lua
component_separators = { left = "", right = "" },
section_separators   = { left = "", right = "" },
```

**All** pill caps are set on the components (`separator = { left/right = … }`).
Do NOT use section separators for caps: they draw with transitional colors and render as
thin slivers. Component-level caps always draw full-thickness in the component's colors.

```lua
mode_pill = { "mode", fmt = fmt_mode, icon = { "" },
    separator = { left = "", right = "" } }
loc  = { "location", icon = { "", align = "left" }, separator = { left = "" } }
prog = { "progress", icon = { "", align = "left" }, separator = { right = "", left = "" } }
```

`loc` + `prog` share section `z`, so they form ONE continuous accent segment
` 1:1   Top` (pixel-verified against the reference).

### 4. Sections (mirror the reference layout)

| Section | Contents | Colors |
|---|---|---|
| `a` | `mode` (`` icon, `fmt_mode` truncates to 6 chars: COMMND/V-BLCK/TERMNL) | accent pill |
| `b` | *(empty)* | — |
| `c` | `parent_folder()` (`` + `tmux/`) · `tail()` (`tmux.conf`) · `branch` (``) · `diff` (`  `) | folder/branch/diff all **muted** (icons AND counts); filename bright |
| `x` | `diagnostics` (`   󱤅`, `colored = true`) · `lsp_clients()` (`` + client names) | diagnostics colored; LSP muted |
| `y` | *(empty)* | — |
| `z` | `location` (``) + `progress` (``) | one accent segment |

### 5. globalstatus + neo-tree extension

`globalstatus = true` → exactly one bar at the bottom, always (lualine sets `laststatus=3`
itself). A `tree` extension for `filetypes = { "neo-tree" }` shows a calm bar when the tree
is focused (mode pill · ` ~/cwd` muted · right pills) instead of the raw buffer name.

---

## Glyph table (all verified present in installed FiraCode Nerd Font)

| Element | Glyph | Codepoint | Name |
|---|---|---|---|
| mode icon |  | U+E62B | custom-vim (reads as small chevron) |
| folder |  | U+F07C | fa-folder_open |
| branch |  | U+EBA1 | cod-github_inverted |
| diff added |  | U+F0FE | fa-plus_square |
| diff modified |  | U+F14B | fa-pencil_square |
| diff removed |  | U+F146 | fa-minus_square |
| diag error |  | U+F057 | fa-times_circle |
| diag warn |  | U+F06A | fa-exclamation_circle |
| diag info |  | U+F05A | fa-info_circle |
| diag hint | 󱤅 | U+F1905 | md-leaf_circle (NF v3) |
| LSP icon |  | U+F085 | fa-cogs (double gear) |
| location |  | U+F05B | fa-crosshairs |
| progress |  | U+E612 | seti default-file (looks like ☰) |
| pill caps |   | U+E0B6 / U+E0B4 | powerline half-circles |

## Hard-won lesson: glyph writes

PUA glyphs (U+E000–U+F8FF) can silently vanish when writing files through some tools.
Always write configs containing them via `python3` with explicit `\uXXXX` escapes, then verify:

```bash
grep -o 'pattern.' file | hexdump -C        # expect ee 82 b6 for  etc.
fc-list ':charset=e62b' family              # font coverage check
```

## Tweaking cheatsheet

- **Mode icon**: change `icon = { "" }` in `mode_pill` (e.g. ``, ``).
- **Pill padding**: add `left_padding`/`right_padding = 2` to `mode_pill`/`loc`/`prog`.
- **Muted shade**: replace the `inactive.c.fg` lookup with a fixed hex in `text_hl`.
- **Colored diff counts**: delete the `diff_color = …` line (icons/counts get theme colors).
- **Per-mode pill colors**: free — insert=green, visual=mauve, etc. come from the theme's
  per-mode `a` tables automatically.
- **Git ahead/behind**: his config had a `get_git_compare()` (`git rev-list --left-right
  --count HEAD...@@{upstream}`, icons 󱦳/󱦲 U+F19B3/U+F19B2) — dropped here (needs plenary);
  add as a `c` component if wanted.
