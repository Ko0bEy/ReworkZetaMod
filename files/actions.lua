new_zeta_action = 	{
		id          = "ZETA",
		name 		= "$action_zeta",
		description = "$actiondesc_zeta",
		sprite 		= "data/ui_gfx/gun_actions/zeta.png",
		sprite_unidentified = "data/ui_gfx/gun_actions/spread_reduce_unidentified.png",
		spawn_requires_flag = "card_unlocked_duplicate",
		type 		= ACTION_TYPE_OTHER,
		spawn_manual_unlock = true,
		recursive	= true,
		spawn_level                       = "5,6,10", -- MANA_REDUCE
		spawn_probability                 = "0.1,0.1,1", -- MANA_REDUCE
		price = 600,
		mana = 300,
		action 		= function( recursion_level, iteration )
			c.fire_rate_wait = c.fire_rate_wait + 50
			current_reload_time = current_reload_time + 75
			local entity_id = GetUpdatedEntityID()
			local x, y = EntityGetTransform( entity_id )
			local options = {}

			local children = EntityGetAllChildren( entity_id )
			local inventory = EntityGetFirstComponent( entity_id, "Inventory2Component" )

			local active_wand_encountered = false
			local actions_added = false

			local wands_since_active_wand = -1

			local iter = iteration or 1

			local only_modifiers = true

			if ( children ~= nil ) and ( inventory ~= nil ) then
				local active_wand = ComponentGetValue2( inventory, "mActiveItem" )

				for i,child_id in ipairs( children ) do
					if ( EntityGetName( child_id ) == "inventory_quick" ) then
						local wands = EntityGetAllChildren( child_id )

						if ( wands ~= nil ) then
							for k,wand_id in ipairs( wands ) do
								if ( wand_id == active_wand ) then
									active_wand_encountered = true
								end
								if active_wand_encountered then
									wands_since_active_wand = wands_since_active_wand + 1
								end
								if ( wand_id ~= active_wand ) and EntityHasTag( wand_id, "wand" ) and ( wands_since_active_wand == iter ) and not actions_added then
									local spells = EntityGetAllChildren( wand_id )

									if ( spells ~= nil ) then
										for j,spell_id in ipairs( spells ) do
											local comp = EntityGetFirstComponentIncludingDisabled( spell_id, "ItemActionComponent" )

											if ( comp ~= nil ) then
												local action_id = ComponentGetValue2( comp, "action_id" )

												table.insert( options, action_id )
											end
										end
									end
									actions_added = true
								end
							end
						end
					end
				end
			end

			if ( #options > 0 ) then
				--SetRandomSeed( x + GameGetFrameNum(), y + 251 )

				--local rnd = Random( 1, #options )
				--local action_id = options[rnd]
				for k, action_id in ipairs( options ) do
					for i,data in ipairs( actions ) do
						if ( data.id == action_id ) then
							local rec = check_recursion( data, recursion_level )
							if ( rec > -1 ) then
								if data.type == ACTION_TYPE_MODIFIER then
									dont_draw_actions = true
								else
									only_modifiers = false
								end
								if data.id == "ZETA" then
									data.action( rec, iter + 1 )
								else
									data.action( rec )
								end

								dont_draw_actions = false
							end
							break
						end
						end
					end
				end

			if only_modifiers then
				draw_actions( 1, true )
			end

		end,
	}

for i, action in ipairs(actions) do
	if action.id == "ZETA" then
		table.remove(actions, i)
		table.insert(actions, i, new_zeta_action)
	end
end

