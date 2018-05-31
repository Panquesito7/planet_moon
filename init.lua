

-- http://dev.minetest.net/PerlinNoiseMap

-- basic planet material noise
local base_params = {
   offset = 0,
   scale = 1,
   spread = {x=1024, y=512, z=1024},
   seed = 3468584,
   octaves = 5,
   persist = 0.6
}

-- ore params
local ore_params = {
   offset = 0,
   scale = 1,
   spread = {x=1024, y=512, z=1024},
   seed = 23085729,
   octaves = 5,
   persist = 0.6
}

minetest.register_on_generated(function(minp, maxp, seed)

	if minp.y < 100 or minp.y > 280 then
		return
	end

	-- colid layer
	local is_solid = minp.y < 200

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local side_length = maxp.x - minp.x + 1 -- 80
	local map_lengths_xyz = {x=side_length, y=side_length, z=side_length}

	local base_perlin_map = minetest.get_perlin_map(base_params, map_lengths_xyz):get3dMap_flat(minp)
	local ore_perlin_map = minetest.get_perlin_map(ore_params, map_lengths_xyz):get3dMap_flat(minp)

	local c_base = minetest.get_content_id("default:stone")
	local c_ore1 = minetest.get_content_id("default:mese")
	local c_ore2 = minetest.get_content_id("default:goldblock")
	local c_ore3 = minetest.get_content_id("default:diamondblock")
	local c_air = minetest.get_content_id("air")

	local i = 1
	for z=minp.z,maxp.z do
	for y=minp.y,maxp.y do
	for x=minp.x,maxp.x do


		local index = area:index(x,y,z)

		-- higher elevation = lower chance
		local chance = (y-minp.y) / side_length

		if data[index] == c_air then
			-- unpopulated node

			local base_n = base_perlin_map[i]
			local ore_n = ore_perlin_map[i]

			if is_solid or base_n > chance then

				local ore_hit = ore_n - chance

				if ore_hit > 0.2 then
					data[index] = c_ore3

				elseif ore_hit > -0.3 then
					data[index] = c_ore2

				elseif ore_hit > -0.5 then
					data[index] = c_ore1

				else
					-- base material
					data[index] = c_base
				end

			end
		end

		i = i + 1

	end --x
	end --y
	end --z
 
	vm:set_data(data)
	vm:write_to_map()

end)


print("[OK] Planet: moon")