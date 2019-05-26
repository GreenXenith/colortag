local function hex_is_valid(color)
	local patterns = {"%x%x%x%x%x%x", "%x%x%x", "%x%x%x%x%x%x%x%x"} -- Standard, shortened, alpha
	for _, pat in pairs(patterns) do
		if color:find("^#"..pat.."$") then
			return true
		end
	end
	return false
end

-- Convert between 1000 units and 256
local function from_slider_rgb(value)
	value = tonumber(value)
	return math.floor((255/1000*value)+0.5)
end

-- ...and back
local function to_slider_rgb(value)
	return 1000/255*value
end

local function show_colortag_form(player)
	local rgba = player:get_nametag_attributes().color
	local name = player:get_player_name()
	minetest.show_formspec(name, "colortag",
		-- Init formspec
		"size[6,3;true]"..
		"position[0.5, 0.45]"..
		-- RGBA sliders
		"scrollbar[0,1;5,0.3;horizontal;r;"..tostring(to_slider_rgb(rgba.r)).."]"..
		"label[5.1,0.9;R: "..tostring(rgba.r).."]"..
		"scrollbar[0,1.6;5,0.3;horizontal;g;"..tostring(to_slider_rgb(rgba.g)).."]"..
		"label[5.1,1.5;G: "..tostring(rgba.g).."]"..
		"scrollbar[0,2.2;5,0.3;horizontal;b;"..tostring(to_slider_rgb(rgba.b)).."]"..
		"label[5.1,2.1;B: "..tostring(rgba.b).."]"..
		"scrollbar[0,2.8;5,0.3;horizontal;a;"..tostring(to_slider_rgb(rgba.a)).."]"..
		"label[5.1,2.7;A: "..tostring(rgba.a).."]"..
		-- Preview
		"label[0,0.5;"..minetest.colorize(minetest.rgba(rgba.r, rgba.g, rgba.b, rgba.a), name).."]"
	)
end

minetest.register_chatcommand("colortag",{
	params = "[r g b [a] | #hex]",
	description = "Sets player nametag color. Accepts RGB[A] format or hexidecimal. Leave empty to show formspec. (!) Color is not saved on logout.",
	privs = {shout = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not param or param == "" then
			show_colortag_form(player)
			return true
		end
		param = param:split(" ")
		local color
		if #param == 1 then
			color = param[1]
		elseif #param >= 3 then
			param[4] = param[4] or 255
			for _, val in pairs(param) do
				if not tonumber(val) then
					return false, "Invalid color."
				end
			end
			color = minetest.rgba(param[1], param[2], param[3], param[4])
		else
			return false, "Invalid usage. See /help colortag."
		end
		if not hex_is_valid(color) then
			return false, "Invalid color."
		end
		player:set_nametag_attributes({
			color = color,
		})
		return true, "Nametag color set."
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "colortag" then
		if fields.r or fields.g or fields.b or fields.a then
			local function sval(value)
				return from_slider_rgb(value:gsub(".*:", ""))
			end
			player:set_nametag_attributes({
				color = minetest.rgba(sval(fields.r), sval(fields.g), sval(fields.b), sval(fields.a))
			})
			show_colortag_form(player)
		end
	end
end)
