local n_seaflora = function(pos,radius)
	local minp  = vector.subtract(pos,radius)
	local maxp  = vector.add(pos,radius)
	local flora = minetest.find_nodes_in_area(minp,maxp, {'group:seaflora'})
	return #flora
end

local habitable = function(pos, kind)
	local Y1 = {x = 0, y = 1, z = 0}

	-- Habitable if node above is water and is receiving light between 2 and 12.
	if kind == 'seaweed' and
	   minetest.get_node(vector.add(pos,Y1)).name == 'default:water_source' and
	   minetest.get_node_light(pos, 0.5) >= 2 and
	   minetest.get_node_light(pos, 0.5) <= 12 then
		return true
	end

	-- Habitable if node above is water, node below is sand, and receiving light
	-- between 3 and 9.
	if kind == 'coral' and
	   minetest.get_node(vector.add(pos,Y1)).name == 'default:water_source' and
	   minetest.get_node(vector.subtract(pos,Y1)).name == 'default:sand' and
	   minetest.get_node_light(pos, 0.5) >= 3 and
	   minetest.get_node_light(pos, 0.5) <= 9 then
		return true
	end

	return false
end

local grow_seaweed = function(pos, elapsed)
	local Y = {x = 0, y = 1, z = 0}

	-- Grow if habitable above.
	if habitable(vector.add(pos,Y), 'seaweed') then
		minetest.set_node(vector.add(pos,Y), {name = 'fishing:seaweed'})
	end

	-- Check if node survives to propatate.
	if minetest.get_node(vector.subtract(pos,Y)).name == 'default:sand' then
		-- Start a new node timer to grow again.
		minetest.get_node_timer(pos):start(math.random(300,900))

		-- Find a nearby habitable node and propagate if its not too crowded.
		local poss = minetest.find_nodes_in_area(
			vector.subtract(pos, 1),
			vector.add(pos, 1),
			{'default:water_source'}
		)
		if #poss > 0 then
			local npos = poss[math.random(#poss)]
			if n_seaflora(pos,1) < 6 and habitable(npos, 'seaweed') and
				minetest.get_node(vector.subtract(npos,Y)).name == 'default:sand' then
				minetest.set_node(npos, {name = 'fishing:seaweed'})
			end
		end
	end

	return false
end

-- Seaweed
minetest.register_node('fishing:seaweed', {
	description = 'Seaweed',
	drawtype = 'plantlike',
	waving = 1,
	is_ground_content = true,
	tiles = {'seaweed.png'},
	inventory_image = 'seaweed.png',
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
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(300,900))
	end,
	on_timer = grow_seaweed
})

local grow_coral = function(pos, elapsed)
	if habitable(pos, 'coral') then
		-- Node survives to grow again.
		minetest.get_node_timer(pos):start(math.random(900,1500))
	else
		return false
	end

	-- Find a nearby habitable node and propagate if its not too crowded.
	local minp  = vector.subtract(pos,1)
	local maxp  = vector.add(pos,1)
	local poss  = minetest.find_nodes_in_area(minp,maxp, {'default:water_source'})
	local flora = minetest.find_nodes_in_area(minp,maxp, {'group:coral'})
	local pos   = poss[math.random(#poss)]

	-- Assuming parent is under one water, abort unless there is more water.
	if #poss > 1 and #flora < 4 and habitable(pos, 'coral') then
		minetest.set_node(pos, {name = 'fishing:coral'..math.random(1,5)})
	end

	return false
end

local register_coral = function(name, def)
	def.drawtype = 'plantlike'
	def.waving = 1
	def.is_ground_content = true
	def.paramtype = 'light'
	def.selection_box = {type = 'fixed', fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}}
	def.groups = {
			--not_in_creative_inventory = 1,
			seaflora = 1,
			coral = 1,
			snappy=3
		}
	def.sounds = default.node_sound_leaves_defaults()
	def.on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(900,1500))
	end
	def.on_timer = grow_coral

	minetest.register_node(name, def)
end

-- Yellow Coral
register_coral('fishing:coral1', {
	description = 'Yellow Coral',
	tiles = {'coral1.png'},
	inventory_image = 'coral1.png',
})

-- Blue Coral
register_coral('fishing:coral2', {
	description = 'Blue Coral',
	tiles = {'coral2.png'},
	inventory_image = 'coral2.png',
})

-- Orange Coral
register_coral('fishing:coral3', {
	description = 'Orange Coral',
	tiles = {'coral3.png'},
	inventory_image = 'coral3.png',
})

-- Pink Coral
register_coral('fishing:coral4', {
	description = 'Pink Coral',
	tiles = {'coral4.png'},
	inventory_image = 'coral4.png',
})

-- Green Coral
register_coral('fishing:coral5', {
	description = 'Green Coral',
	tiles = {'coral5.png'},
	inventory_image = 'coral5.png',
})

-- Randomly generate Coral
minetest.register_lbm({
	name = 'fishing:spawn_seaflora',
	nodenames = {'default:sand'},
	run_at_every_load = true,
	action = function(pos, node)
		pos = vector.add(pos,{x = 0, y = 1, z = 0})
		if minetest.get_node(pos).name == 'default:water_source' and
		   n_seaflora(pos,16) == 0 then
			if math.random(4) == 1 and habitable(pos, 'seaweed') then
				minetest.set_node(pos, {name = 'fishing:seaweed'})
			elseif habitable(pos, 'coral') then
				minetest.set_node(pos, {name = 'fishing:coral'..math.random(1,5)})
			end
		end
	end
})

--[[
-- Remove all seaflora.
minetest.register_lbm({
	name = 'fishing:remove_seaflora',
	nodenames = {
		'fishing:coral2',
		'fishing:coral3',
		'fishing:coral4',
		'fishing:seaweed'
	},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.set_node(pos, {name = 'default:water_source'})
	end
})
--]]
