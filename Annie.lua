
local function Initialize_menu()
    Menu = {}
    menu.label("Annie");

    menu.label("Combo")
    Menu.combo_use_q = menu.checkbox("Use Q", true)
    Menu.combo_mana_q = menu.slider_int( "Mana Q", 0, 100, 10)
    Menu.combo_use_w = menu.checkbox("Use W", true)
    Menu.combo_mana_w = menu.slider_int( "Mana W", 0, 100, 10)
    Menu.combo_use_r = menu.checkbox("Use R", true)
    Menu.combo_mana_r = menu.slider_int( "Mana R", 0, 100, 10)
    
    --menu.label("Mixed")
    --Menu.mixed_use_q = menu.checkbox("Use Q", true)
    --Menu.mixed_mana_q = menu.slider_int( "Mana Q", 0, 100, 10)

    menu.label("Draw")
    Menu.draw_q = menu.checkbox("Draw Q range", true)

end


--object:get_predicted_position( projectile_speed, projectile_range, projectile_width, cast_time ): vec3

local function Init()
    Spell_limiter_q, Spell_limiter_w, Spell_limiter_e, Spell_limiter_r, max_mana  = 0,0,0,0,0
    qSpeed = 10000
    qRange = 625
    qSize = 100
    wSpeed = 10000
    wRange = 550
    wSize = 600
    rSpeed = 10000
    rRange = 600
    rSize = 200
    Initialize_menu()
end





local function Use_Q(target)
    if Local_spellbook:get_spell_slot( spell_slot_t.q ):is_ready() and globals.get_game_time() > Spell_limiter_q then
        --pred speed, travel range, width, cast time
        local pred_pos = target:get_predicted_position( Local_hero:get_position() , qSpeed, qRange, qSize, 0.25 )
        if pred_pos:length() > 1 then
            input.send_spell( spell_slot_t.q , pred_pos )
            Spell_limiter_q = globals.get_game_time() + 0.5
        end
    end
end

local function Use_W(target)
    if Local_spellbook:get_spell_slot( spell_slot_t.w ):is_ready() and globals.get_game_time() > Spell_limiter_w then
        --pred speed, travel range, width, cast time
        local pred_pos = target:get_predicted_position( Local_hero:get_position() , wSpeed, wRange, wSize, 0.25 )
        if pred_pos:length() > 1  then
            input.send_spell( spell_slot_t.w , pred_pos )
            Spell_limiter_w = globals.get_game_time() + 0.5
        end
    end
end

local function Use_R(target)
    if Local_spellbook:get_spell_slot( spell_slot_t.r ):is_ready() and globals.get_game_time() > Spell_limiter_r then
        --pred speed, travel range, width, cast time
        local pred_pos = target:get_predicted_position( Local_hero:get_position() , rSpeed, rRange, rSize, 0.25 )
        if pred_pos:length() > 1  then
            input.send_spell( spell_slot_t.r , pred_pos )
            Spell_limiter_r = globals.get_game_time() + 0.5
        end
    end
end

local min = math.min

--local function GetEnemies()
--    enemyTable = object_manager.get_valid_enemy_heroes()
--    --enemyHpTable = {}
--    eTargetHp = 50000
--    eTarget = '0'
--    for i,e in ipairs(enemyTable) do 
--        if (Local_hero:get_position() - e:get_position()):length() <= qRange then 
--              if e:get_health() < eTargetHp then
--                eTargetHp = e:get_health()
--                eTarget = e
--              end
--        end
--    end
--    return eTarget
--end


local function Combo()
    local orbwalker_target = orbwalker.get_target()
    --local orbwalker_target = GetEnemies()
    render.text(vec2:new( 100, 100 ), tostring(orbwalker_target), 32, color:new( 255, 255, 255 ) )
    if orbwalker_target ~= -1 then
        local target = object_manager.get_by_index( orbwalker_target )
        if Menu.combo_use_q:get_value() and Local_hero:get_mana() > max_mana * (Menu.combo_mana_q:get_value()/100) and Local_hero:get_mana() > 40 then Use_Q(target) end
        if Menu.combo_use_w:get_value() and Local_hero:get_mana() > max_mana * (Menu.combo_mana_w:get_value()/100) and Local_hero:get_mana() > 40 then Use_W(target) end
        if Menu.combo_use_r:get_value() and Local_hero:get_mana() > max_mana * (Menu.combo_mana_r:get_value()/100) and Local_hero:get_mana() > 40 then Use_R(target) end
        
    end
end


    

local function Draw()
    Local_hero = object_manager.get_local()
    Local_spellbook = Local_hero:get_spell_book()
    myPosString = tostring(Local_hero:get_position())
    myBuffs = buff_manager:get_active_buffs(Local_hero)
    -- example usage
    --render.text( vec2:new( 100, 100 ), "im a text", 32, color:new( 255, 255, 255 ) )
    render.text(vec2:new( 100, 100 ), myBuffs, 32, color:new( 255, 255, 255 ) )
    if Menu.draw_q:get_value() then render.circle_3d( Local_hero:get_position() , 625, color:new( 0,125,255, 100 ) ) end
    if Local_hero:get_mana() > max_mana then max_mana = Local_hero:get_mana() return end
end

local function Tick()
    if input.is_key_down(67) then Combo() return end
    --if input.is_key_down(84) then Mixed() return end
end

Init()
register_callback( "draw", Tick )
register_callback( "draw", Draw )
--register_callback( "draw", GetEnemies )
