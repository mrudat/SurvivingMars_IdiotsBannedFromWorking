local orig_print = print
if Mods.mrudat_TestingMods then
  print = orig_print
else
  print = empty_func
end

local CurrentModId = rawget(_G, 'CurrentModId') or rawget(_G, 'CurrentModId_X')
local CurrentModDef = rawget(_G, 'CurrentModDef') or rawget(_G, 'CurrentModDef_X')
if not CurrentModId then

  -- copied shamelessly from Expanded Cheat Menu
  local Mods, rawset = Mods, rawset
  for id, mod in pairs(Mods) do
    rawset(mod.env, "CurrentModId_X", id)
    rawset(mod.env, "CurrentModDef_X", mod)
  end

  CurrentModId = CurrentModId_X
  CurrentModDef = CurrentModDef_X
end

orig_print("loading", CurrentModId, "-", CurrentModDef.title)

local function find_method(class_name, method_name, seen)
  seen = seen or {}
  local class = _G[class_name]
  local method = class[method_name]
  if method then return method end
  local find_method = mrudat_AllowBuildingInDome.find_method
  for _, parent_class_name in ipairs(class.__parents or empty_table) do
    if not seen[parent_class_name] then
      method = find_method(parent_class_name, method_name, seen)
      if method then return method end
      seen[parent_class_name] = true
    end
  end
end

local function wrap_method(class_name, method_name, wrapper)
  local orig_method = _G[class_name][method_name]
  if not orig_method then
    if RecursiveCallOrder[method_name] ~= nil or AutoResolveMethods[method_name] then
      orig_method = empty_func
    else
      orig_method = find_method(class_name, method_name)
    end
  end
  if not orig_method then orig_print("Error: couldn't find method to wrap for", class_name, method_name, "refusing to proceed") return end
  _G[class_name][method_name] = function(self, ...)
    return wrapper(self, orig_method, ...)
  end
end

wrap_method('Colonist', 'CanWork', function(self, orig_func)
  return not self.traits.Idiot and orig_func(self)
end)


orig_print("loaded", CurrentModId, "-", CurrentModDef.title)
