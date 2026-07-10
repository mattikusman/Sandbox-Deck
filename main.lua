--- STEAMODDED HEADER
--- MOD_NAME: Sandbox
--- MOD_ID: Sandbox
--- MOD_AUTHOR: [M-That-One : Extracted from Mayhem]
--- MOD_DESCRIPTION: Adds the Sandbox Deck from Mayhem as standalone deck back.
--- PRIORITY: 0
--- VERSION: 4.2.0.4
SMODS.Atlas {key = "modicon",path = "icon.png",px = 34,py = 34,}:register()

-- Animated color tables (values mutated every frame)

G.C.ANIM_JOKER    = {1,   0,   0,   1}
G.C.ANIM_CONSM    = {1,   0.9, 0,   1}
G.C.ANIM_CARDS    = {0.2, 0.9, 0.2, 1}
G.C.ANIM_OVST     = {0.6, 0.1, 0.9, 1}
G.C.ANIM_DICE     = {1,   0.4, 0.7, 1}  -- cycles: pink -> yellow -> purple -> red
G.C.MAROON        = {0.5, 0,   0,   1}

-- Per-deck animated description background colors (mutated every frame)
G.C.PULSE_SANDBOX  = {0.06, 0.01, 0.03, 1}  -- Sandbox: dark crimson
G.C.PULSE_CREATIVE = {0.07, 0.05, 0.18, 1}  -- Creative: deep violet
G.C.PULSE_DICE     = {0.10, 0.02, 0.04, 1}  -- Child of the Dice: dark rose

-- Per-deck animated wrapper border colors (bright, matches card art border palette)
G.C.BORDER_SANDBOX  = {0.53, 0.0,  0.80, 1}  -- violet (Sandbox outer border color)
G.C.BORDER_CREATIVE = {1.0,  0.75, 0.0,  1}  -- gold   (Creative outer border color)
G.C.BORDER_DICE     = {0.65, 0.35, 0.40, 1}  -- blend  (Dice: mix of both)

-- Color stop cycles for each deck's background (matched to card art palette)
local _SANDBOX_BG_STOPS = {   -- crimson → deep red → dark rose
    {0.05, 0.01, 0.02},
    {0.28, 0.02, 0.09},
    {0.18, 0.01, 0.06},
    {0.08, 0.01, 0.03},
}
local _CREATIVE_BG_STOPS = {  -- deep violet → dark gold → indigo
    {0.07, 0.04, 0.18},
    {0.24, 0.18, 0.03},
    {0.16, 0.06, 0.14},
    {0.10, 0.07, 0.20},
}
local _DICE_BG_STOPS = {      -- blends both decks: rose → gold → violet → crimson
    {0.14, 0.02, 0.06},
    {0.18, 0.15, 0.02},
    {0.08, 0.03, 0.20},
    {0.12, 0.01, 0.04},
}

-- Color stop cycles for wrapper borders (bright, pulled from card art)
local _SANDBOX_BORDER_STOPS = {   -- violet ↔ crimson (the card's actual border hues)
    {0.53, 0.00, 0.80},   -- violet
    {0.80, 0.00, 0.13},   -- crimson
    {0.65, 0.00, 0.45},   -- violet-crimson blend
    {0.38, 0.00, 0.68},   -- deeper violet
}
local _CREATIVE_BORDER_STOPS = {  -- gold ↔ violet (card's actual border hues)
    {1.00, 0.75, 0.00},   -- bright gold
    {0.40, 0.00, 0.80},   -- violet
    {0.80, 0.45, 0.00},   -- amber-gold
    {0.60, 0.00, 0.70},   -- purple
}
local _DICE_BORDER_STOPS = {      -- blends Sandbox and Creative borders
    {0.65, 0.35, 0.40},   -- pink-gold blend
    {0.70, 0.55, 0.00},   -- warm gold
    {0.45, 0.00, 0.72},   -- violet
    {0.80, 0.00, 0.25},   -- crimson-violet
}


-- Per-deck ring color sequences for the description popup border texture.
-- Drawn outer→inner, matching the nested ring pattern on each deck's card art.
-- Format: {R, G, B} for each ring line (alternating bright/dark mimics card border).
local _DESC_RING_COLORS = {
    ['Sandbox Deck'] = {
        {0.62, 0.00, 0.92},  -- bright violet   (outermost)
        {0.05, 0.00, 0.08},  -- near black
        {0.90, 0.00, 0.15},  -- bright crimson
        {0.04, 0.00, 0.03},  -- near black
        {0.48, 0.00, 0.75},  -- mid violet      (innermost)
    },
    ['Creative Mode Deck'] = {
        {1.00, 0.82, 0.00},  -- bright gold     (outermost)
        {0.05, 0.03, 0.00},  -- near black
        {0.55, 0.00, 0.92},  -- bright violet
        {0.04, 0.00, 0.08},  -- near black
        {0.85, 0.55, 0.00},  -- amber-gold      (innermost)
    },
    ['Child of the Dice Deck'] = {
        {1.00, 0.15, 0.65},  -- hot pink        (outermost)
        {0.04, 0.00, 0.04},  -- near black
        {0.98, 0.88, 0.00},  -- bright yellow
        {0.04, 0.00, 0.04},  -- near black
        {0.00, 0.72, 1.00},  -- bright cyan     (innermost)
    },
}

-- Register custom keys with the loc_colour lookup

local orig_loc_colour = loc_colour
loc_colour = function(_c, _default)
    if _c == 'anim_joker' then return G.C.ANIM_JOKER end
    if _c == 'anim_consm' then return G.C.ANIM_CONSM end
    if _c == 'anim_cards' then return G.C.ANIM_CARDS end
    if _c == 'anim_ovst'  then return G.C.ANIM_OVST  end
    if _c == 'maroon'     then return G.C.MAROON      end
    return orig_loc_colour(_c, _default)
end

-- Intercept DynaText creation for our deck name.

local orig_DynaText_init = DynaText.init
DynaText.init = function(self, config)
    if type(config) == 'table'
    and type(config.string) == 'string'
    and config.string:find('Child of the Dice Deck') then
        config.colours = {G.C.ANIM_DICE}
    end
    return orig_DynaText_init(self, config)
end

-- Canvas-based animated deck texture for Child of the Dice Deck.

local _dice_canvas = nil
local _dice_atlas  = nil
local _dice_img1   = nil
local _dice_img2   = nil

local function find_our_mod_prefix()
    if not G.ASSET_ATLAS then return nil end
    if G.ASSET_ATLAS['dice_anim'] then return '' end
    local sfx = '_dice_anim'
    for k in pairs(G.ASSET_ATLAS) do
        if #k > #sfx and k:sub(-#sfx) == sfx then
            return k:sub(1, #k - #sfx)
        end
    end
    return nil
end

local function init_dice_canvas()
    if _dice_canvas then return end
    local prefix = find_our_mod_prefix()
    if prefix == nil then return end

    local function ga(base)
        return G.ASSET_ATLAS[(prefix == '') and base or (prefix .. '_' .. base)]
    end

    local da = ga('dice_anim')
    local d1 = ga('deck')
    local d2 = ga('creative_mode_deck')
    if not (da and d1 and d2 and d1.image and d2.image) then return end

    _dice_atlas  = da
    _dice_img1   = d1.image
    _dice_img2   = d2.image
    _dice_canvas = love.graphics.newCanvas(71, 95)
    _dice_atlas.image = _dice_canvas
end

local function update_dice_canvas(blend)
    local r, g, b, a = love.graphics.getColor()
    local bm, bma    = love.graphics.getBlendMode()

    love.graphics.setCanvas(_dice_canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(_dice_img1)
    love.graphics.setColor(1, 1, 1, blend)
    love.graphics.draw(_dice_img2)
    love.graphics.setCanvas()

    love.graphics.setBlendMode(bm, bma)
    love.graphics.setColor(r, g, b, a)
end

-- Color stops for the deck name: pink -> yellow -> purple -> red -> (loop)

local _DICE_STOPS = {
    {1, 0.4, 0.7},   -- pink
    {1, 1,   0  },   -- yellow
    {0.6, 0, 1  },   -- purple
    {1,   0, 0  },   -- red
}

-- Pulse shader for description box backgrounds

local _pulse_shader = nil
local _ok, _err = pcall(function()
    _pulse_shader = love.graphics.newShader([[
        extern float time;
        extern vec3 shimmer_colour;
        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            float slow    = (sin(time * 1.8) + 1.0) * 0.5;
            float shimmer = (sin(time * 9.0 + screen_coords.y * 0.06) + 1.0) * 0.03;
            float glow    = slow * 0.18 + shimmer;
            vec3  c       = color.rgb * (1.0 + glow * 0.5) + shimmer_colour * glow;
            return vec4(clamp(c, 0.0, 1.0), color.a);
        }
    ]])
end)
if not _ok then print('[Sandbox] pulse shader failed: ' .. tostring(_err)) end

-- Deck name → pulse colour table; also used as a truthy presence check
local _BACK_PULSE = {
    ['Sandbox Deck']           = G.C.PULSE_SANDBOX,
    ['Creative Mode Deck']     = G.C.PULSE_CREATIVE,
    ['Child of the Dice Deck'] = G.C.PULSE_DICE,
}

-- Deck name → border colour table (for the white wrapper ring)
local _BACK_BORDER = {
    ['Sandbox Deck']           = G.C.BORDER_SANDBOX,
    ['Creative Mode Deck']     = G.C.BORDER_CREATIVE,
    ['Child of the Dice Deck'] = G.C.BORDER_DICE,
}

-- Set of all pulse colour tables for fast membership test in draw_self
local _PULSE_SET = {
    [G.C.PULSE_SANDBOX]  = true,
    [G.C.PULSE_CREATIVE] = true,
    [G.C.PULSE_DICE]     = true,
}

-- Concentric ring brightness fractions for the outer deck panel border texture.
-- Drawn outer→inner, mimicking the card art's nested ring pattern.
-- Each deck defines 4 rings: outermost (bright) → innermost (dark).
local _RING_FRACS = {
    ['Sandbox Deck']           = {1.00, 0.65, 0.38, 0.18},  -- violet→crimson, bright→dark
    ['Creative Mode Deck']     = {1.00, 0.68, 0.40, 0.18},  -- gold→violet, bright→dark
    ['Child of the Dice Deck'] = {1.00, 0.66, 0.39, 0.18},  -- blended, bright→dark
}

-- Per-deck shimmer tint (the colour added during the bright phase of the glow)
local _SHIMMER = {
    [G.C.PULSE_SANDBOX]  = {0.55, 0.04, 0.18},  -- pink-red  (Sandbox card lines)
    [G.C.PULSE_CREATIVE] = {0.50, 0.35, 0.02},  -- warm gold (Creative card lines)
    [G.C.PULSE_DICE]     = {0.40, 0.18, 0.22},  -- mixed warm (both decks blended)
}

-- Per-deck shimmer for the border (brighter, matches the border colour cycle)
local _BORDER_SHIMMER = {
    [G.C.BORDER_SANDBOX]  = {0.80, 0.50, 1.00},  -- bright violet-white
    [G.C.BORDER_CREATIVE] = {1.00, 1.00, 0.50},  -- bright gold-white
    [G.C.BORDER_DICE]     = {0.90, 0.60, 0.70},  -- warm pink-white blend
}

local _SANDBOX_BACKS = _BACK_PULSE  -- legacy alias used elsewhere


-- Inject the per-deck animated colour into each deck's description container

local _orig_Back_generate_UI = Back.generate_UI
Back.generate_UI = function(self, other, ui_scale, min_dims, challenge)
    local result = _orig_Back_generate_UI(self, other, ui_scale, min_dims, challenge)
    local name   = (other and other.name) or self.name
    local pulse  = _BACK_PULSE[name]
    if pulse and result.nodes and result.nodes[1] then
        local desc = result.nodes[1]
        desc.config.colour = pulse
        desc.config.r      = desc.config.r or 0.1
    end
    return result
end

-- Apply the shader when drawing elements that use our pulse colour (ROOT and
-- desc_from_rows container injected by Back:generate_UI above).

-- Search `el`'s children from min_depth to max_depth for an O element containing
-- a deck description UIBox.  Returns the deck name string, or nil.
local function _find_desc_deck_id(el, min_d, max_d)
    if max_d < 1 then return nil end
    for _, ch in ipairs((el and el.children) or {}) do
        if type(ch) == 'table' then
            if min_d <= 1 and ch.config and ch.config.object then
                local ub = ch.config.object
                if ub and ub.UIRoot and ub.UIRoot.config then
                    local id = ub.UIRoot.config.id
                    if _BACK_BORDER[id] then return id end
                end
            end
            if max_d > 1 and ch.UIT then
                local id = _find_desc_deck_id(ch, min_d - 1, max_d - 1)
                if id then return id end
            end
        end
    end
end

-- Like _find_desc_deck_id but crosses UIBox boundaries: when it finds an O element
-- with an embedded UIBox it also searches that UIBox's UIRoot recursively.
-- Needed to match intermediate UIBoxes (parent[6], parent[7]) whose UIElement trees
-- don't directly contain the deck description but reach it through nested UIBoxes.
local function _find_desc_deep(el, max_d)
    if not el or max_d < 0 then return nil end
    for _, ch in ipairs((el and el.children) or {}) do
        if type(ch) == 'table' then
            if ch.config and ch.config.object then
                local ub = ch.config.object
                if ub and ub.UIRoot then
                    local id = ub.UIRoot.config and ub.UIRoot.config.id
                    if id and _BACK_BORDER[id] then return id end
                    if max_d > 0 then
                        local rid = _find_desc_deep(ub.UIRoot, max_d - 1)
                        if rid then return rid end
                    end
                end
            end
            if ch.UIT and max_d > 0 then
                local rid = _find_desc_deep(ch, max_d - 1)
                if rid then return rid end
            end
        end
    end
end

-- Search el's direct O children for one whose embedded UIBox IS or CONTAINS
-- a deck description UIBox.  Identifies the WHITE R wrapper element.
local function _find_container_deck_id(el)
    for _, ch in ipairs((el and el.children) or {}) do
        if type(ch) == 'table' and ch.config and ch.config.object then
            local ub = ch.config.object
            if ub and ub.UIRoot then
                -- Direct check: is THIS embedded UIBox itself the description UIBox?
                local id = ub.UIRoot.config and ub.UIRoot.config.id
                if id and _BACK_BORDER[id] then return id end
                -- Indirect: does it contain the description UIBox further down?
                local deck_id = _find_desc_deep(ub.UIRoot, 15)
                if deck_id then return deck_id end
            end
        end
    end
end

-- Find the outermost UIElement with r > 0 that contains the deck description.
-- This is the gray popup container (the actual "border" the user sees).
-- Stays within one UIBox boundary (does not cross O elements with objects).
local function _find_popup_container_el(el, depth)
    if not el or depth < 0 then return nil end
    for _, ch in ipairs((el and el.children) or {}) do
        if type(ch) == 'table' and not (ch.config and ch.config.object) then
            if ch.config and ch.config.r and ch.config.r > 0 then
                -- Check if this element directly contains the description O element
                if _find_desc_deck_id(ch, 1, 6) then return ch end
            end
            if depth > 0 then
                local found = _find_popup_container_el(ch, depth - 1)
                if found then return found end
            end
        end
    end
    return nil
end

-- Weak set of UIElements whose draw_self backgrounds should be suppressed
-- because they sit inside a popup container (our rounded dark fill handles it).
local _popup_inner_els = setmetatable({}, {__mode = 'k'})

-- Draw the ring pattern for the popup container element from within
-- UIElement.draw_self, using the element's own VT as the coordinate origin.
-- This fires at exactly the right Z-order: after the black outer elements,
-- before the R-row children, so rings show in the border and dark fills
-- the interior which children then paint over.
local function _draw_rings_for_el(el, rings)
    if not (el.VT and el.VT.w and el.VT.w > 0) then return end
    local r_col, g_col, b_col, a_col = love.graphics.getColor()
    local t       = (G.TIMERS and G.TIMERS.REAL) or love.timer.getTime()
    local pulse   = 0.85 + 0.15 * math.sin(t * 2.5)
    local rr_base = (el.config.r or 0.1) * G.TILESIZE
    local ew = el.VT.w * G.TILESIZE
    local eh = el.VT.h * G.TILESIZE
    local n  = #rings
    local bw = 0.1 * G.TILESIZE / n   -- fill the 0.1-tile border band exactly
    prep_draw(el, 1)
    love.graphics.scale(1 / G.TILESIZE)
    -- Painter: outermost ring fills full area, each inner ring covers the previous
    for i, rc in ipairs(rings) do
        local off    = (i - 1) * bw
        local rr     = math.max(1, rr_base - off)
        local bright = (i % 2 == 1) and pulse or 1.0
        love.graphics.setColor(rc[1]*bright, rc[2]*bright, rc[3]*bright, 1.0)
        love.graphics.rectangle('fill', off, off, ew - 2*off, eh - 2*off, rr, rr)
    end
    -- Dark interior — R-row children will draw on top of this
    local ioff = n * bw
    love.graphics.setColor(0.04, 0.02, 0.04, 1.0)
    love.graphics.rectangle('fill', ioff, ioff, ew - 2*ioff, eh - 2*ioff,
        rr_base, rr_base)
    love.graphics.pop()
    love.graphics.setColor(r_col, g_col, b_col, a_col)
end

local _orig_UIElement_draw_self = UIElement.draw_self
UIElement.draw_self = function(self)
    -- Intercept the gray C popup container: replace its background with rings.
    -- This fires at the right Z-order (after outer black elements, before R children).
    -- Suppress background for R rows inside the popup — our rounded dark fill handles it
    if _popup_inner_els[self] then return end

    if self.UIT == G.UIT.C and self.config and self.config.r and self.config.r > 0 then
        local ring_id = _find_desc_deck_id(self, 1, 6)
        if ring_id then
            local rings = _DESC_RING_COLORS[ring_id]
            if rings then _draw_rings_for_el(self, rings) end
            -- Register direct children so their own backgrounds are skipped
            for _, ch in ipairs(self.children or {}) do
                if type(ch) == 'table' then _popup_inner_els[ch] = true end
            end
            return  -- skip original gray background draw
        end
    end

    -- Pulse shader for elements whose colour is one of our animated deck colours
    local pulse_col = self.config and self.config.colour
    local apply = _pulse_shader
        and _PULSE_SET[pulse_col]
        and (self.UIT == G.UIT.C or self.UIT == G.UIT.R or self.UIT == G.UIT.ROOT)
    if apply then
        local sc = _SHIMMER[pulse_col] or {0.22, 0.06, 0.48}
        _pulse_shader:send('shimmer_colour', sc)
        _pulse_shader:send('time', (G.TIMERS and G.TIMERS.REAL) or love.timer.getTime())
        love.graphics.setShader(_pulse_shader)
    end

    _orig_UIElement_draw_self(self)

    if apply then love.graphics.setShader() end
end

-- Fill the outer white wrapper by drawing directly in UIBox.draw.
-- UIBox.parent = O UIElement, O UIElement.parent = white wrapper R.
-- We draw BEFORE the normal UIBox content so the white wrapper's background
-- is overwritten but the text still renders on top.

-- Draw the pulsing fill at the wrapper's exact VT position BEFORE the normal
-- UIBox content (which overlays text on top).  The white wrapper's draw_self
-- already fired (outer screen UIBox draws before inner desc UIBox), so we
-- paint over it here.
--
-- Coordinate recipe copied from UIElement.draw_self / draw_self for R elements:
--   prep_draw(el, 1)          → push + scale(G.TILESCALE*G.TILESIZE) + translate(VT.x,VT.y)
--   scale(1/G.TILESIZE)       → effective scale = G.TILESCALE
--   rectangle(0,0, VT.w*G.TILESIZE, VT.h*G.TILESIZE)  → correct pixel size
--   pop()                     → pair for prep_draw's push

local _orig_UIBox_draw = UIBox.draw
UIBox.draw = function(self)
    local deck_id   = self.UIRoot and self.UIRoot.config and self.UIRoot.config.id
    local pulse_col = deck_id and _BACK_PULSE[deck_id]
    -- Paint the description UIBox's interior with the dark animated pulse colour.
    -- This covers any white area adjacent to the text content.
    -- The wrapper R border (drawn earlier by the outer UIBox) is handled in
    -- UIElement.draw_self via _deck_wrapper_bord_col.
    if pulse_col and self.states and self.states.visible
    and self.VT and self.VT.w > 0 then
        local r_col, g_col, b_col, a_col = love.graphics.getColor()
        local prev_shader = love.graphics.getShader()
        if _pulse_shader then
            local sc = _SHIMMER[pulse_col] or {0.22, 0.06, 0.48}
            _pulse_shader:send('shimmer_colour', sc)
            _pulse_shader:send('time', (G.TIMERS and G.TIMERS.REAL) or love.timer.getTime())
            love.graphics.setShader(_pulse_shader)
        end
        love.graphics.setColor(pulse_col[1], pulse_col[2], pulse_col[3], 1)
        prep_draw(self, 1)
        love.graphics.scale(1 / G.TILESIZE)
        love.graphics.rectangle('fill', 0, 0,
            self.VT.w * G.TILESIZE, self.VT.h * G.TILESIZE)
        love.graphics.pop()
        love.graphics.setShader(prev_shader)
        love.graphics.setColor(r_col, g_col, b_col, a_col)
    end
    -- Ring drawing is now handled in UIElement.draw_self for the gray C container.
    -- Nothing else to do here for popup rings.

    _orig_UIBox_draw(self)
end

-- Animate all color tables every frame

local _anim_t = 0
local function lerp(a, b, t) return a + (b - a) * t end

-- Smoothly cycle through a table of RGB stops at the given speed (stops/sec)
local function cycle_bg(stops, speed)
    local n     = #stops
    local phase = (_anim_t * speed) % n
    local idx   = math.floor(phase) + 1
    local frac  = phase - math.floor(phase)
    local c1    = stops[idx]
    local c2    = stops[idx % n + 1]
    return lerp(c1[1], c2[1], frac),
           lerp(c1[2], c2[2], frac),
           lerp(c1[3], c2[3], frac)
end

local orig_love_update = love.update
love.update = function(dt)
    _anim_t = _anim_t + dt * 1.5
    local f1 = (math.sin(_anim_t + 0.0) + 1) / 2
    local f2 = (math.sin(_anim_t + 1.1) + 1) / 2
    local f3 = (math.sin(_anim_t + 2.2) + 1) / 2
    local f4 = (math.sin(_anim_t + 3.3) + 1) / 2
    local f6 = (math.sin(_anim_t * 0.6) + 1) / 2

    -- red <-> light pink
    G.C.ANIM_JOKER[1] = 1
    G.C.ANIM_JOKER[2] = lerp(0,   0.6, f1)
    G.C.ANIM_JOKER[3] = lerp(0,   0.6, f1)

    -- yellow <-> orange
    G.C.ANIM_CONSM[1] = 1
    G.C.ANIM_CONSM[2] = lerp(0.9, 0.5, f2)
    G.C.ANIM_CONSM[3] = 0

    -- green <-> light green
    G.C.ANIM_CARDS[1] = lerp(0.2, 0.6, f3)
    G.C.ANIM_CARDS[2] = lerp(0.9, 1,   f3)
    G.C.ANIM_CARDS[3] = lerp(0.2, 0.6, f3)

    -- purple <-> red
    G.C.ANIM_OVST[1] = lerp(0.6, 1,   f4)
    G.C.ANIM_OVST[2] = 0
    G.C.ANIM_OVST[3] = lerp(0.9, 0,   f4)

    -- deck name: smoothly step through pink -> yellow -> purple -> red -> loop
    local n      = #_DICE_STOPS
    local phase  = (_anim_t * 0.2) % n          -- 0..n, one stop per ~2 s
    local idx    = math.floor(phase) + 1         -- 1-based current stop
    local t      = phase - math.floor(phase)     -- 0..1 within the step
    local c1     = _DICE_STOPS[idx]
    local c2     = _DICE_STOPS[idx % n + 1]     -- wraps from 4 back to 1
    G.C.ANIM_DICE[1] = lerp(c1[1], c2[1], t)
    G.C.ANIM_DICE[2] = lerp(c1[2], c2[2], t)
    G.C.ANIM_DICE[3] = lerp(c1[3], c2[3], t)

    -- Per-deck description backgrounds (each cycles through its own palette)
    G.C.PULSE_SANDBOX[1],  G.C.PULSE_SANDBOX[2],  G.C.PULSE_SANDBOX[3]
        = cycle_bg(_SANDBOX_BG_STOPS,  0.12)   -- slow crimson/red cycle
    G.C.PULSE_CREATIVE[1], G.C.PULSE_CREATIVE[2], G.C.PULSE_CREATIVE[3]
        = cycle_bg(_CREATIVE_BG_STOPS, 0.12)   -- slow violet/gold cycle
    G.C.PULSE_DICE[1],     G.C.PULSE_DICE[2],     G.C.PULSE_DICE[3]
        = cycle_bg(_DICE_BG_STOPS,     0.20)   -- slightly faster, blended cycle

    -- Per-deck wrapper border colors (brighter, matches card art border palette)
    G.C.BORDER_SANDBOX[1],  G.C.BORDER_SANDBOX[2],  G.C.BORDER_SANDBOX[3]
        = cycle_bg(_SANDBOX_BORDER_STOPS,  0.10)  -- violet ↔ crimson, slightly slower
    G.C.BORDER_CREATIVE[1], G.C.BORDER_CREATIVE[2], G.C.BORDER_CREATIVE[3]
        = cycle_bg(_CREATIVE_BORDER_STOPS, 0.10)  -- gold ↔ violet
    G.C.BORDER_DICE[1],     G.C.BORDER_DICE[2],     G.C.BORDER_DICE[3]
        = cycle_bg(_DICE_BORDER_STOPS,     0.15)  -- blended


    -- canvas crossfade
    init_dice_canvas()
    if _dice_canvas and love.graphics.isActive() then
        update_dice_canvas(f6)
    end

    return orig_love_update(dt)
end

-- Pack size fix

local orig_Card_open = Card.open
Card.open = function(self, ...)
    if self.ability.set == 'Booster' and G.GAME and G.GAME.child_of_dice_deck_active then
        self.ability.extra = (self.ability.extra or 0) + 8
    end
    return orig_Card_open(self, ...)
end

--Deck Images

SMODS.Atlas { key = 'deck',               path = 'deck.png',               px = 71, py = 95 }
SMODS.Atlas { key = 'creative_mode_deck', path = 'creative_mode_deck.png', px = 71, py = 95 }
SMODS.Atlas { key = 'dice_anim',          path = 'deck.png',               px = 71, py = 95 }

--Decks

--Sandbox Deck

SMODS.Back {
    name = 'Sandbox Deck',
    key = 'sandbox_deck',
    atlas = 'deck',
    pos = { x = 0, y = 0 },
    config = {
        joker_slot = 1e100,
        consumable_slot = 1e100,
        vouchers = { 'v_overstock_norm' },
    },
    loc_txt = {
        name = 'Sandbox Deck',
        text = {
            '{C:anim_joker}+1e100 Joker{} and {C:anim_consm}+1e100 Consumable{} Slots',
            'You can select {C:anim_cards}all cards{} from {C:attention}Booster Packs{}',
            'Start run with {C:anim_ovst}Overstock{}',
            'Gain a {C:dark_edition}Negative{} copy of {C:spectral}The Soul{}',
            'Gain {C:spectral}Genesis{} if {C:maroon}Mayhem{} is loaded',
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({ func = function()
            G.consumeables.config.card_limit = math.huge
            local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'sandbox_deck')
            soul:add_to_deck()
            G.consumeables:emplace(soul)
            soul:set_edition({ negative = true }, true)
            if next(SMODS.find_mod('mayhem')) then
                local genesis = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_may_genesis', 'sandbox_deck')
                genesis:add_to_deck()
                G.consumeables:emplace(genesis)
            end
        return true end }))
    end,
    calculate = function(self, card, context)
        if context.open_booster then
            G.GAME.pack_choices = G.GAME.pack_size
        end
    end,
}

--Creative Mode Deck

SMODS.Back {
    name = 'Creative Mode Deck',
    key = 'Creative Mode Deck',
    atlas = 'creative_mode_deck',
    pos = { x = 0, y = 0 },
    config = {
        hands = 1e100,
        discards = 1e100,
        joker_slot = 1e100,
        consumable_slot = 1e100,
        vouchers = { 'v_overstock_norm','v_overstock_plus' },
    },
    loc_txt = {
        name = 'Creative Mode Deck',
        text = {
            '{C:anim_joker}+1e100 Joker{} and {C:anim_consm}+1e100 Consumable{} Slots',
            '{C:red}+1e100{} Discards and {C:blue}+1e100{} Hands',
            'You can select {C:anim_cards}all cards{} from {C:attention}Booster Packs{}',
            'Start run with {C:anim_ovst}Overstock{} and {C:anim_ovst}Overstock Plus{}',
            'Gain a {C:dark_edition}Negative{} copy of {C:spectral}The Soul{}',
            'Gain {C:spectral}Genesis{} if {C:maroon}Mayhem{} is loaded',
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({ func = function()
            G.consumeables.config.card_limit = math.huge
            local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'creative_mode_deck/')
            soul:add_to_deck()
            G.consumeables:emplace(soul)
            soul:set_edition({ negative = true }, true)
            if next(SMODS.find_mod('mayhem')) then
                local genesis = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_may_genesis', 'creative_mode_deck')
                genesis:add_to_deck()
                G.consumeables:emplace(genesis)
            end
        return true end }))
    end,
    calculate = function(self, card, context)
        if context.open_booster then
            G.GAME.pack_choices = G.GAME.pack_size
        end
    end,
}

--Child of the Dice Deck

SMODS.Back {
    name = 'Child of the Dice Deck',
    key = 'Child_of_the_Dice_Deck',
    atlas = 'dice_anim',
    pos = { x = 0, y = 0 },
    config = {
        joker_slot = 1e100,
        consumable_slot = 1e100,
        vouchers = { 'v_overstock_norm', 'v_overstock_plus' },
        dollars = 16,
        discount = 50,
    },
    loc_txt = {
        name = 'Child of the Dice Deck',
        text = {
            '{C:anim_joker}+1e100 Joker{} and {C:anim_consm}+1e100 Consumable{} Slots',
            'You can select {C:anim_cards}all cards{} from {C:attention}Booster Packs{}',
            'Start run with {C:anim_ovst}Overstock{} and {C:anim_ovst}Overstock Plus{}',
            'Gain a {C:dark_edition}Negative{} copy of {C:spectral}The Soul{}',
            'Gain {C:spectral}Genesis{} if {C:maroon}Mayhem{} is loaded',
            '{C:money}20${} and {C:legendary}+8{} Pack Size',
            'All {C:attention}cards{} in {C:attention}shop{} are {C:attention}50%{} {C:money}cheaper{}',
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({ func = function()
            G.GAME.child_of_dice_deck_active = true
            G.GAME.discount_percent = self.config.discount
            for k, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
            end
            G.consumeables.config.card_limit = math.huge
            local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'Child_of_the_Dice_Deck')
            soul:add_to_deck()
            G.consumeables:emplace(soul)
            soul:set_edition({ negative = true }, true)
            if next(SMODS.find_mod('mayhem')) then
                local genesis = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_may_genesis', 'Child_of_the_Dice_Deck')
                genesis:add_to_deck()
                G.consumeables:emplace(genesis)
            end
            return true
        end }))
    end,
    calculate = function(self, card, context)
        if context.open_booster then
            G.GAME.pack_choices = G.GAME.pack_size
        end
    end,
}
