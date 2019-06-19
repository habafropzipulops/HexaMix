
local json = require( "json" )
local colorsJson = system.pathForFile( "preset_ryb_colors.json", system.ResourceDirectory )
local presetRybColors = json.decodeFile( colorsJson )

RYBcolor = {}

function RYBcolor:new( red, yellow, blue )
    local color = {}
    color = { r = red, y = yellow, b = blue }
   
    function RYBcolor.__add( firstColor, secondColor)
        local mixedColor = RYBcolor:new()

        for _, index in ipairs({ "r", "y", "b" }) do
            mixedColor[index] = ( firstColor[index] + secondColor[index] ) / 2
        end

        return mixedColor
    end

function color:convertToRgb() 
    local r0, y0, b0 = color.r, color.y, color.b
    local r = r0 * r0 * ( 3 - 2 * r0 ) -- weight(r)
    local y = y0 * y0 * ( 3 - 2 * y0 ) -- weight(y)
    local b = b0 * b0 * ( 3 - 2 * b0 ) -- weight(b)

    return { 1.0 + b * ( -0.837 + r * ( 0.337 - 0.137 * y ) - 0.163 * y ),
             1.0 + b * ( -0.627 + r * (0.627 - 0.693 * y) + 0.287 * y) + r * ( -1.0 + 0.5 * y ),
             1.0 + b * ( -0.4 + r * (0.9 - 1.1 * y ) + 0.6 * y ) - y + r * ( y - 1.0 ) }
end

--[[
function color:split()
    local r1, y1, b1 = 2 * color.r - math.random(), 2 * color.y - math.random(), 2 * color.b - math.random()
    local r2, y2, b2 = 2 * color.r - r1, 2 * color.y - y1, 2 * color.b - b1
    return RYBcolor:new(r1, y1, b1), RYBcolor:new(r2, y2, b2)
end
]]--

    setmetatable(color, self)
    self.__index = self; return color
end

function RYBcolor:presetColor( colorName )
    return RYBcolor:new( unpack(presetRybColors[colorName]) )
end

function RYBcolor:randomColor()
    return RYBcolor:new( math.random(), math.random(), math.random() )
end
