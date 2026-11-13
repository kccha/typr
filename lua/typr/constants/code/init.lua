-- built-in snippets for the code mode, keyed by language
-- each language lives in its own module and is only loaded when used
return setmetatable({}, {
  __index = function(t, lang)
    local ok, snippets = pcall(require, "typr.constants.code." .. lang)
    t[lang] = ok and snippets or false
    return t[lang] or nil
  end,
})
