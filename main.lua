--- STEAMODDED HEADER
--- MOD_NAME: Sandbox Deck
--- MOD_ID: SandboxDeck
--- MOD_AUTHOR: [M-That-One : Extracted from Mayhem]
--- MOD_DESCRIPTION: Adds the Sandbox Deck from Mayhem as standalone deck back.
--- PRIORITY: 0
--- VERSION: 4.2.0.4
SMODS.Atlas {key = "modicon",path = "icon.png",px = 17,py = 17,}:register()

-- Animated color tables (values mutated every frame)

G.C.ANIM_JOKER = {1,   0,   0,   1}
G.C.ANIM_CONSM = {1,   0.9, 0,   1}
G.C.ANIM_CARDS = {0.2, 0.9, 0.2, 1}
G.C.ANIM_OVST  = {0.6, 0.1, 0.9, 1}
G.C.ANIM_DICE  = {0.5, 0.5, 0.5, 1}  -- dark grey <-> light grey

-- Register custom keys with the loc_colour lookup

local orig_loc_colour = loc_colour
loc_colour = function(_c, _default)
    if _c == 'anim_joker' then return G.C.ANIM_JOKER end
    if _c == 'anim_consm' then return G.C.ANIM_CONSM end
    if _c == 'anim_cards' then return G.C.ANIM_CARDS end
    if _c == 'anim_ovst'  then return G.C.ANIM_OVST  end
    return orig_loc_colour(_c, _default)
end

-- Intercept DynaText creation for our deck name.
-- Replace colours with our animated ANIM_DICE table.
-- DynaText reads self.colours[1] at draw time, so mutating the table
-- animates the color even if the DynaText is recreated frequently.

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
-- Crossfades between deck.png and creative_mode_deck.png.
--
-- G.ASSET_ATLAS keys are prefixed by the mod's SMODS prefix.
-- We derive the prefix by searching for 'dice_anim' (unique to our mod),
-- then use that same prefix for all three atlas lookups — no ambiguity.

local _dice_canvas = nil
local _dice_atlas  = nil
local _dice_img1   = nil
local _dice_img2   = nil

local function find_our_mod_prefix()
    if not G.ASSET_ATLAS then return nil end
    -- no-prefix case: key is exactly 'dice_anim'
    if G.ASSET_ATLAS['dice_anim'] then return '' end
    -- prefixed case: key is '{prefix}_dice_anim'
    local sfx = '_dice_anim'
    for k in pairs(G.ASSET_ATLAS) do
        if #k > #sfx and k:sub(-#sfx) == sfx then
            return k:sub(1, #k - #sfx)   -- e.g. 'SandboxDeck'
        end
    end
    return nil  -- atlases not loaded yet
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
    -- Save graphics state so we don't disturb the game's rendering
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

    -- Restore
    love.graphics.setBlendMode(bm, bma)
    love.graphics.setColor(r, g, b, a)
end

-- Animate all color tables every frame

local _anim_t = 0
local function lerp(a, b, t) return a + (b - a) * t end

local orig_love_update = love.update
love.update = function(dt)
    _anim_t = _anim_t + dt * 1.5
    local f1 = (math.sin(_anim_t + 0.0) + 1) / 2
    local f2 = (math.sin(_anim_t + 1.1) + 1) / 2
    local f3 = (math.sin(_anim_t + 2.2) + 1) / 2
    local f4 = (math.sin(_anim_t + 3.3) + 1) / 2
    local f5 = (math.sin(_anim_t * 1.2 + 4.4) + 1) / 2
    local f6 = (math.sin(_anim_t * 0.6) + 1) / 2   -- slow crossfade

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

    -- dark grey <-> light grey (deck name)
    local v = lerp(0.25, 0.75, f5)
    G.C.ANIM_DICE[1] = v
    G.C.ANIM_DICE[2] = v
    G.C.ANIM_DICE[3] = v

    -- canvas crossfade (lazy-init on first available frame)
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
-- dice_anim starts as a copy of deck.png; its .image is swapped to a canvas at runtime
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
    atlas = 'dice_anim',   -- canvas crossfade between deck.png and creative_mode_deck.png
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
