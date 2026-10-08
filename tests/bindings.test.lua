local bindings, unbound, events, emitted, timer, held = {}, {}, {}, {}, nil, {}
hl = {
    dsp = { global = function(name) return name end },
    dispatch = function(action) emitted[#emitted + 1] = action end,
    unbind = function(key) unbound[key] = true end,
    bind = function(key, action) assert(unbound[key]); bindings[key] = action end,
    on = function(event, handler) events[event] = handler end,
    timer = function(callback) timer = callback end,
    is_key_down = function(key) return held[key] == true end,
}
dofile('bindings.lua')
assert(bindings['ALT + TAB'] == 'switch-magic:workspace')
assert(bindings['ALT + SHIFT + TAB'] == 'switch-magic:monitor')
assert(bindings['CTRL + ALT + TAB'] == 'switch-magic:all')
events['input.keyboard.key'](23, 0, 0)
assert(timer == nil)
events['input.keyboard.key'](64, 0, 1)
assert(timer == nil)
events['input.keyboard.key'](64, 0, 0)
assert(timer)
held.Alt_R = true; timer(); assert(#emitted == 0)
held.Alt_R = false; timer(); assert(emitted[1] == 'switch-magic:commit')
print('Lua bindings: scopes, unrelated keys, Alt release and dual-Alt checks passed')
