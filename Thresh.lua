
local function Initialize_menu()
    Menu = {}
    menu.label("Simple Thresh");

    menu.label("Combo")
    Menu.combo_use_q = menu.checkbox("Use Q", true)
    Menu.combo_mana_q = menu.slider_int( "Mana Q", 0, 100, 10)
    Menu.combo_use_e = menu.checkbox("Use E", true)
    Menu.combo_mana_e = menu.slider_int( "Mana E", 0, 100, 10)


    menu.label("Draw")
    Menu.draw_q = menu.checkbox("Draw Q range", true)

end

local function Init()
    Spell_limiter_q, Spell_limiter_w, Spell_limiter_e, Spell_limiter_r, max_mana  = 0,0,0,0,0

    Initialize_menu()
end

local function Use_Q(target)
    if Local_spellbook:get_spell_slot( spell_slot_t.q ):is_ready() and globals.get_game_time() > Spell_limiter_q then
        --pred speed, travel range, width, cast time
        local pred_pos = target:get_predicted_position( Local_hero:get_position() , 1000, 1100, 50, 0.25 )
        if pred_pos:length() > 1 and not collision.is_minion_in_line( pred_pos, 50 ) then
            input.send_spell( spell_slot_t.q , pred_pos )
            Spell_limiter_q = globals.get_game_time() + 0.5
        end
    end
end

local function Use_E(target)
    if Local_spellbook:get_spell_slot( spell_slot_t.e ):is_ready() and globals.get_game_time() > Spell_limiter_e then
        local pred_pos = target:get_predicted_position( Local_hero:get_position() , 3000, 400, 50, 0.25 )
        if pred_pos:length() > 1 then
            input.send_spell( spell_slot_t.e , pred_pos )
            Spell_limiter_e = globals.get_game_time() + 0.5
        end
    end
end




local function Combo()
    local orbwalker_target = orbwalker.get_target()
    if orbwalker_target ~= -1 then
        local target = object_manager.get_by_index( orbwalker_target )
        if Menu.combo_use_q:get_value() and Local_hero:get_mana() > max_mana * (Menu.combo_mana_q:get_value()/100) and Local_hero:get_mana() > 40 then Use_Q(target) end
        if Menu.combo_use_e:get_value() and Local_hero:get_mana() > max_mana * (Menu.combo_mana_e:get_value()/100) and Local_hero:get_mana() > 40 then Use_E(target) end
    end
end


local function Draw()
    Local_hero = object_manager.get_local()
    Local_spellbook = Local_hero:get_spell_book()

    if Menu.draw_q:get_value() then render.circle_3d( Local_hero:get_position() , 1100, color:new( 0,125,255, 100 ) ) end

    if Local_hero:get_mana() > max_mana then max_mana = Local_hero:get_mana() return end
end

local function Tick()
    if input.is_key_down(67) then Combo() return end
end

Init()
register_callback( "draw", Tick )
register_callback( "draw", Draw )
