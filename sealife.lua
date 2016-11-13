-- Seaweed
minetest.register_node('fishing:seaweed', {
	description = 'Seaweed',
	drawtype = 'plantlike',
	waving = 1,
	is_ground_content = true,
	tiles = {'seaweed.png'},
	inventory_image = 'seaweed.png',
	wield_image = 'seaweed.png',
	paramtype = 'light',
	walkable = false,
	climbable = true,
	drowning = 1,
	selection_box = {type = 'fixed', fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},
	post_effect_color = {a=64, r=100, g=100, b=200},
	groups = {
			not_in_creative_inventory = 1,
			seaflora = 1,
			snappy=3
		},
	on_use = minetest.item_eat(1),
	sounds = default.node_sound_leaves_defaults(),
})

-- Blue Coral
minetest.register_node('fishing:coral2', {
	description = 'Blue Coral',
	drawtype = 'plantlike',
	waving = 1,
	is_ground_content = true,
	tiles = {'coral2.png'},
	inventory_image = 'coral2.png',
	paramtype = 'light',
	selection_box = {type = 'fixed', fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}},
	light_source = 3,
	groups = {
			not_in_creative_inventory = 1,
			seaflora = 1,
			coral = 1,
			snappy=3
		},
	sounds = default.node_sound_leaves_defaults(),
})

-- Orange Coral
minetest.register_node('fishing:coral3', {
	description = 'Orange Coral',
	drawtype = 'plantlike',
	waving = 1,
	is_ground_content = true,
	tiles = {'coral3.png'},
	inventory_image = 'coral3.png',
	paramtype = 'light',
	selection_box = {type = 'fixed', fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}},
	light_source = 3,
	groups = {
			not_in_creative_inventory = 1,
			seaflora = 1,
			coral = 1,
			snappy=3
		},
	sounds = default.node_sound_leaves_defaults(),
})

-- Pink Coral
minetest.register_node('fishing:coral4', {
	description = 'Pink Coral',
	drawtype = 'plantlike',
	waving = 1,
	is_ground_content = true,
	tiles = {'coral4.png'},
	inventory_image = 'coral4.png',
	paramtype = 'light',
	selection_box = {type = 'fixed', fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}},
	light_source = 3,
	groups = {
			not_in_creative_inventory = 1,
			seaflora = 1,
			coral = 1,
			snappy=3
		},
	sounds = default.node_sound_leaves_defaults(),
})

-- Randomly generate Coral or Seaweed
minetest.register_abm({
	nodenames = {'default:sand'},
	neighbors = {'group:water'},
	interval = 15,
	chance = 96,

	action = function(pos, node)
		pos.y = pos.y + 1

		--  Check if there's too much corals and seaweed around.
		local pos0 = {x = pos.x - 4, y = pos.y - 4, z = pos.z - 4}
		local pos1 = {x = pos.x + 4, y = pos.y + 4, z = pos.z + 4}
		local seaflora = minetest.find_nodes_in_area(pos0, pos1, "group:seaflora")
		if #seaflora > 3 then
			return
		end

		-- Generate a new coral or seaweed
		if pos.y < 2  and  minetest.get_node(pos).name == 'default:water_source' then
			local sel = math.random(1,4)

			-- 25% of the time, it's a seaweed
			if sel == 1 then
				minetest.set_node(pos, {name='fishing:seaweed'})

			-- 75% of the time, it's corals (1-3)
			else
				minetest.set_node(pos, {name='fishing:coral'..sel})

			end
		end
	end,
})


-- Grow seaweed
minetest.register_abm({
	nodenames = {'fishing:seaweed'},
	neighbors = {'group:sand'},
	interval = 12,
	chance = 83,

	action = function(pos, node)

		-- Check that there is sand below
		pos.y = pos.y - 1
		if minetest.get_item_group(minetest.get_node(pos).name, "sand") == 0 then
			return
		end

		-- Get plant height
		pos.y = pos.y + 1
		local height = 0
		while node.name == "fishing:seaweed" and height < 14 do
			height = height + 1
			pos.y = pos.y + 1
			node = minetest.get_node(pos)
		end

		-- Make sure it's not too tall and that there is water above
		if height == 14 or node.name ~= "default:water_source" then
			return
		end

		-- Prevent growth to surface
		pos.y = pos.y + 1
		if minetest.get_node(pos).name ~= "default:water_source" then
			return
		end
		pos.y = pos.y - 1

		minetest.set_node(pos, {name = "fishing:seaweed"})
		return true

	end,
})
