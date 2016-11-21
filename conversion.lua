-- Handle unknown blocks for removing fishing:sandy

minetest.register_lbm({
	name = 'fishing:remove_sandy',
	nodenames = {'fishing:sandy'},
	action = function(pos, node)
		minetest.set_node(pos, {name = 'default:sand'})
	end,
})

minetest.register_alias('fishing:sandy', 'default:sand')
