local plate = {}
screwdriver = screwdriver or {}

local function door_toggle(pos_actuator, pos_door, player)
	local actuator = minetest.get_node(pos_actuator)
	local door = doors.get(pos_door)

	if actuator.name:sub(-4) == "_off" then
		minetest.set_node(pos_actuator,
			{name=actuator.name:gsub("_off", "_on"), param2=actuator.param2})
	end
	door:open(player)

	minetest.after(2, function()
		if minetest.get_node(pos_actuator).name:sub(-3) == "_on" then
			minetest.set_node(pos_actuator,
				{name=actuator.name, param2=actuator.param2})
		end
		door:close(player)
	end)
end

function plate.construct(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(0.1)
end

function plate.timer(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.8)
	if objs == {} or not doors.get then
		return true
	end
	local minp = {x = pos.x - 2, y = pos.y, z = pos.z - 2}
	local maxp = {x = pos.x + 2, y = pos.y, z = pos.z + 2}
	local doors = minetest.find_nodes_in_area(minp, maxp, "group:door")

	for _, player in pairs(objs) do
		if player:is_player() then
			for i = 1, #doors do
				door_toggle(pos, doors[i], player)
			end
			break
		end
	end
	return true
end

function plate.register(material, desc, def) -- TODO pick one
	minetest.register_node("mechanisms:pressure_"..material.."_off", {
		description = desc.." Pressure Plate",
		tiles = {"mechanisms_pressure_"..material..".png"},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.4375, -0.5, -0.4375, 0.4375, -0.4375, 0.4375}}
		},
		groups = def.groups,
		sounds = def.sounds,
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		on_construct = plate.construct,
		on_timer = plate.timer
	})
	minetest.register_node("mechanisms:pressure_"..material.."_on", {
		tiles = {"mechanisms_pressure_"..material..".png"},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.4375, -0.5, -0.4375, 0.4375, -0.475, 0.4375}}
		},
		groups = def.groups,
		sounds = def.sounds,
		drop = "mechanisms:pressure_"..material.."_off",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple
	})
end

plate.register("wood", "Wooden", {
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = default.dig.wood, flammable=2}
})

plate.register("stone", "Stone", {
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky = default.dig.stone}
})

minetest.register_node("mechanisms:lever_off", {
	description = "Lever",
	tiles = {"mechanisms_lever_off.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.375, -0.4375, 0.4375, 0.375, 0.4375, 0.5}}
	},
	groups = {cracky=3, oddly_breakable_by_hand=2},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.rotate_simple,
	on_rightclick = function(pos, node, clicker)
		if not doors.get then
			return
		end
		local minp = {x=pos.x-2, y=pos.y-1, z=pos.z-2}
		local maxp = {x=pos.x+2, y=pos.y+1, z=pos.z+2}
		local doors = minetest.find_nodes_in_area(minp, maxp, "group:door")

		for i = 1, #doors do
			door_toggle(pos, doors[i], clicker)
		end
	end
})

minetest.register_node("mechanisms:lever_on", {
	tiles = {"mechanisms_lever_on.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.375, -0.4375, 0.4375, 0.375, 0.4375, 0.5}}
	},
	groups = {cracky = default.dig.stone},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.rotate_simple,
	drop = "mechanisms:lever_off"
})

minetest.register_craft({
	type = "shapeless",
	output = "mechanisms:pressure_wood_off",
	recipe = {"default:wood", "default:wood"}
})

minetest.register_craft({
	type = "shapeless",
	output = "mechanisms:pressure_stone_off",
	recipe = {"default:stone", "default:stone"}
})

minetest.register_craft({
	output = "mechanisms:lever_off",
	recipe = {
		{"default:stick"},
		{"default:stone"}
	}
})
