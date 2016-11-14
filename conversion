-- Handle unknown blocks for removing fishing:sandy

minetest.register_lbm({
	name = 'modname:remove_sandy',
	nodenames = {'fishing:sandy'},
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:sand"})
	end,
})
