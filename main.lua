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

SMODS.Atlas { key = 'deck', path = 'deck.png', px = 71, py = 95, }
SMODS.Atlas { key = 'creative_mode_deck', path = 'creative_mode_deck.png', px = 71, py = 95, }

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
            'Gain a {C:dark_edition}Negative{} {C:spectral}The Soul{} and {C:spectral}Genesis{} (if Mayhem loaded)',
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
                genesis:set_edition({ negative = true }, true)
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
            'Gain a {C:dark_edition}Negative{} {C:spectral}The Soul{} and {C:spectral}Genesis{} (if Mayhem loaded)',
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({ func = function()
            G.consumeables.config.card_limit = math.huge
            local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'creative_mode_deck')
            soul:add_to_deck()
            G.consumeables:emplace(soul)
            soul:set_edition({ negative = true }, true)
            if next(SMODS.find_mod('mayhem')) then
                local genesis = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_may_genesis', 'creative_mode_deck')
                genesis:add_to_deck()
                G.consumeables:emplace(genesis)
                genesis:set_edition({ negative = true }, true)
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
    atlas = 'deck',
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
            'Gain a {C:dark_edition}Negative{} {C:spectral}The Soul{} and {C:spectral}Genesis{} (if Mayhem loaded)',
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
                genesis:set_edition({ negative = true }, true)
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
