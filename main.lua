--- STEAMODDED HEADER
--- MOD_NAME: Sandbox Deck
--- MOD_ID: SandboxDeck
--- MOD_AUTHOR: [M-That-One : Extracted from Mayhem]
--- MOD_DESCRIPTION: Adds the Sandbox Deck from Mayhem as standalone deck back. Massive joker/consumable slots, pick all cards from packs, starts with Overstock Plus and a Negative Soul.
--- PRIORITY: 0
--- VERSION: 4.2.0.3

SMODS.Atlas {key = "modicon",path = "icon.png",px = 17,py = 17,}:register()


SMODS.Atlas {
    key = 'deck',
    path = 'deck.png',
    px = 71,
    py = 95,
}

SMODS.Atlas {
    key = 'creative_mode_deck',
    path = 'creative_mode_deck.png',
    px = 71,
    py = 95,
}

SMODS.Back {
    name = 'Sandbox Deck',
    key = 'sandbox_deck',
    atlas = 'deck',
    pos = { x = 0, y = 0 },
    config = {
        joker_slot = 1e100,
		consumable_slot = 1e100,
        vouchers = { 'v_overstock_plus' },
    },
    loc_txt = {
        name = 'Sandbox Deck',
        text = {
            '{C:attention}+1e100{} Joker and Consumable Slots',
            'You can select {C:green}all cards{} from {C:attention}Booster Packs{}',
            'Start run with {C:attention}Overstock Plus{}',
            'and a {C:dark_edition}Negative{} copy of {C:spectral}The Soul{}',
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({ func = function()
            G.consumeables.config.card_limit = math.huge
            local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'sandbox_deck')
            soul:add_to_deck()
            G.consumeables:emplace(soul)
            soul:set_edition({ negative = true }, true)
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
        vouchers = { 'v_overstock_plus' },
    },
    loc_txt = {
        name = 'Creative Mode Deck',
        text = {
            '{C:attention}+1e100{} Joker and Consumable Slots',
			'{C:red}+1e100{} Discards and {C:blue}+1e100{} hands',
            'You can select {C:green}all cards{} from {C:attention}Booster Packs{}',
            'Start run with {C:attention}Overstock Plus{}',
            'and a {C:dark_edition}Negative{} copy of {C:spectral}The Soul{}',
        },
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({ func = function()
            G.consumeables.config.card_limit = math.huge
            local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'creative_mode_deck/')
            soul:add_to_deck()
            G.consumeables:emplace(soul)
            soul:set_edition({ negative = true }, true)
        return true end }))
    end,
    calculate = function(self, card, context)
        if context.open_booster then
            G.GAME.pack_choices = G.GAME.pack_size
        end
    end,
}
