-- Omarchy themes ship their WM styling as a hyprlang fragment, and hl has
-- no hyprlang include: the subset those fragments actually use is applied
-- here. Sections become one hl.config call, bezier and animation lines
-- become hl.curve/hl.animation, windowrule lines and blocks become
-- hl.window_rule. Anything else is skipped and listed in the log, never
-- allowed to abort the config.

local M = {}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Booleans and numbers travel typed; everything else (colors, gradients,
-- "1.0 override") stays the raw hyprlang string, which hl accepts.
local function convert(v)
  local low = v:lower()
  if low == "true" or low == "yes" or low == "on" then return true end
  if low == "false" or low == "no" or low == "off" then return false end
  local n = tonumber(v)
  if n ~= nil then return n end
  return v
end

-- Walk key path segments ("decoration", "blur", "col.shadow" split too)
-- and assign into the nested config table.
local function assign(cfg, path, value)
  local node = cfg
  for i = 1, #path - 1 do
    local seg = path[i]
    if type(node[seg]) ~= "table" then node[seg] = {} end
    node = node[seg]
  end
  node[path[#path]] = value
end

local function split_key(key)
  local segs = {}
  for seg in key:gmatch("[^%.]+") do segs[#segs + 1] = seg end
  return segs
end

local rule_count = 0

local function apply_rule(spec, kind)
  rule_count = rule_count + 1
  if spec.name == nil then spec.name = "riso-theme-" .. rule_count end
  local ok, err = pcall(kind or hl.window_rule, spec)
  return ok, err
end

-- One v2 windowrule line: "match:class firefox, opacity 1.0 override"
local function rule_from_line(v)
  local spec = { match = {} }
  for raw_token in v:gmatch("[^,]+") do
    local token = trim(raw_token)
    local mk, mv = token:match("^match:([%w_]+)%s+(.*)$")
    if mk then
      spec.match[mk] = convert(mv)
    else
      local p, val = token:match("^([%w_]+)%s*(.*)$")
      if p then
        if val == "" then spec[p] = true else spec[p] = convert(val) end
      end
    end
  end
  return spec
end

function M.apply(path)
  local f = io.open(path, "r")
  if not f then return end
  local src = f:read("*a")
  f:close()

  local vars = {}
  local stack = {}
  local cfg = {}
  local rule = nil -- collecting a windowrule { } block
  local skipped = {}

  local function subst(v)
    return (v:gsub("%$([%w_]+)", function(n) return vars[n] or ("$" .. n) end))
  end

  for raw in src:gmatch("[^\r\n]+") do
    local line = trim((raw:gsub("#.*$", "")))
    if line ~= "" then
      local section = line:match("^([%w_%.]+)%s*{$")
      local vname, vval = line:match("^%$([%w_]+)%s*=%s*(.*)$")
      local key, value = line:match("^([%w_%.:]+)%s*=%s*(.*)$")

      if section then
        stack[#stack + 1] = section
        if section == "windowrule" and #stack == 1 then rule = { match = {} } end
      elseif line == "}" then
        if rule and #stack == 1 then
          apply_rule(rule)
          rule = nil
        end
        stack[#stack] = nil
      elseif vname then
        vars[vname] = subst(trim(vval))
      elseif key then
        value = subst(trim(value))
        if rule then
          local mk = key:match("^match:([%w_]+)$")
          if mk then
            rule.match[mk] = convert(value)
          elseif key == "name" then
            rule.name = value
          else
            rule[key] = convert(value)
          end
        elseif #stack == 0 then
          if key == "windowrule" then
            apply_rule(rule_from_line(value))
          elseif key == "layerrule" then
            apply_rule(rule_from_line(value), hl.layer_rule)
          else
            skipped[#skipped + 1] = raw
          end
        elseif stack[1] == "animations" and key == "bezier" then
          local parts = {}
          for p in value:gmatch("[^,]+") do parts[#parts + 1] = trim(p) end
          local nums = { tonumber(parts[2]), tonumber(parts[3]),
                         tonumber(parts[4]), tonumber(parts[5]) }
          if parts[1] and nums[1] and nums[2] and nums[3] and nums[4] then
            pcall(hl.curve, parts[1], {
              type = "bezier",
              points = { { nums[1], nums[2] }, { nums[3], nums[4] } },
            })
          else
            skipped[#skipped + 1] = raw
          end
        elseif stack[1] == "animations" and key == "animation" then
          local parts = {}
          for p in value:gmatch("[^,]+") do parts[#parts + 1] = trim(p) end
          if parts[1] then
            local spec = {
              leaf = parts[1],
              enabled = parts[2] == "1",
              speed = tonumber(parts[3]),
              bezier = parts[4],
            }
            if parts[5] then spec.style = parts[5] end
            pcall(hl.animation, spec)
          else
            skipped[#skipped + 1] = raw
          end
        else
          local segs = {}
          for _, s in ipairs(stack) do
            for _, seg in ipairs(split_key(s)) do segs[#segs + 1] = seg end
          end
          for _, seg in ipairs(split_key(key)) do segs[#segs + 1] = seg end
          assign(cfg, segs, convert(value))
        end
      else
        skipped[#skipped + 1] = raw
      end
    end
  end

  if next(cfg) ~= nil then
    local ok, err = pcall(hl.config, cfg)
    if not ok then
      print("hyprlang-compat: hl.config rejected " .. path .. ": " .. tostring(err))
    end
  end
  if #skipped > 0 then
    print("hyprlang-compat: skipped " .. #skipped .. " line(s) of " .. path)
  end
  return skipped
end

return M
