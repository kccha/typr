local M = {
  ns = vim.api.nvim_create_namespace "Typr",
  pad = 2, -- inner padding of the content
  xpad = 2, -- left offset of the content, set when centering
  ypad = 0, -- top offset of the content, set when centering
  stats_xpad = 2,
  stats_ypad = 0,
  stats_h = 0,
  w = 80,
  h = 20,
  linecount = 3,
  linecounts = { 3, 6, 9, 12, 15, 18, 21, 24, 27, 30 }, -- picked with the keys 1 to 9 and 0
  default_lines = {},
  ui_lines = {},
  lastchar = nil,
  header_h = 4, -- rows above the words
  words_row = 4,
  timer = vim.uv.new_timer(),
  secs = 0,
  months_toggled = false,
  tab = "  Dashboard",
  winlayout = "horizontal",
  horiz_i = 1,

  -- temporary!
  -- stats = {} -- data stored here after test finishes
  -- then saved to disk and this table is reset

  ----------------------- user config -----------------------
  config = {
    mode = "words", -- words, phrases, code
    winlayout = "responsive",
    kblayout = "qwerty",
    wpm_goal = 130,
    numbers = false,
    symbols = false,
    random = false,
    phrases = nil, -- can be a table of strings
    code = {
      lang = "cpp", -- snippets used by the code mode
      -- snippets per language, replacing the built-in ones for that language
      -- each snippet is a multi-line string, e.g.
      -- snippets = { rust = { "fn main() {\n    println!(\"hi\");\n}" } },
      snippets = nil,
      -- directories (or files) to take code from instead of the snippets,
      -- e.g. { "~/projects/engine/src" }; also set by `:Typr <dir>`
      paths = nil,
      -- only these filetypes from paths, e.g. { "cpp", "c" }; all code by default
      filetypes = nil,
    },
    insert_on_start = false,
    stats_filepath = vim.fn.stdpath "data" .. "/typrstats",
    mappings = nil,
    -- or function(buf) end
    -- mappings = function(buf)
    --  vim.keymap.set("n", "a, anything, { buffer = buf })
    -- end,
    on_attach = nil,
    -- or function(buf) end
    -- on_attach = function(buf)
    --  vim.b[buf].minipairs_disable = true
    -- end,
  },

  -- for stats
  data = {},
}

M.reset_vars = function()
  M.finished = false
  M.lastchar = nil
  M.secs = 0

  M.stats = {
    accuracy = 0,
    wpm = 0,
    rawpm = 0,
    correct_word_ratio = "?",
    total_char_count = 0,
    typed_char_count = 0,
    char_times = {},
    char_stats = { all = 0, wrong = 0 },
    word_stats = { all = 0, wrong = 0 },
  }

  M.timer:stop()
end

M.reset_vars()

M.w_with_pad = M.w - (2 * M.pad)

return M
