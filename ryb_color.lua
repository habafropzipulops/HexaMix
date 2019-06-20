
local json = require( "json" )
local colorsJson = system.pathForFile( "preset_ryb_colors.json", system.ResourceDirectory )
local presetRybColors = json.decodeFile( colorsJson )

local defaultWeight = 1

RYBcolor = {}

function RYBcolor:new( red, yellow, blue, weight)
    local color = {}
    color = { r = red, y = yellow, b = blue }
    if weight then
       color.weight = weight
    else
       color.weight = defaultWeight
    end
   
    function RYBcolor.__add( color1, color2 )
        local mixedColor = RYBcolor:new()
        local w1, w2 = color1.weight, color2.weight
        local w3 = w1 + w2

        for _, index in ipairs( { "r", "y", "b" } ) do
            mixedColor[index] = ( w1 * color1[index] + w2 * color2[index] ) / w3
        end

        mixedColor.weight = w3

        return mixedColor
    end

    function color:split()
        local w3 = color.weight
        local w1 = 1
        local w2 = w3 - 1

        local function splitComponent( comp )
            local comp1, comp2

            if comp < ( w1 / w3 ) then
                comp1 = ( w3 / w1 ) * comp * math.random()
            else
                comp1 = ( 1.0 - comp ) * math.random() + comp
            end

            comp2 = ( w3 * comp - w1 * comp1 ) / w2

            return comp1, comp2
        end

        local r, y, b = color.r, color.y, color.b
        local r1, r2 = splitComponent( r )
        local y1, y2 = splitComponent( y )
        local b1, b2 = splitComponent( b )

        return RYBcolor:new(r1, y1, b1, w1), RYBcolor:new(r2, y2, b2, w2)
    end

    function color.decomposition( colorsAmount )
        color.weight = colorsAmount

        local colorComponents = {}
        local partibleColor = color

        for i = 1, colorsAmount - 1 do
            colorComponent, partibleColor = partibleColor.split()
            colorComponents[i] = colorComponent
        end

        colorComponents[colorsAmount] = partibleColor

        return colorComponents
    end

    function color:convertToRgb()  --https://github.com/bahamas10/node-ryb2rgb/blob/master/ryb2rgb.js
        local r0, y0, b0 = color.r, color.y, color.b

        if r0 < 0 or r0 > 1 or y0 < 0 or y0 > 1 or b0 < 0 or b0 > 1 then
            error("color convertion error")
        end

        local r = r0 * r0 * ( 3 - 2 * r0 ) -- weight(r)
        local y = y0 * y0 * ( 3 - 2 * y0 ) -- weight(y)
        local b = b0 * b0 * ( 3 - 2 * b0 ) -- weight(b)

        return { 1.0 + b * ( -0.837 + r * ( 0.337 - 0.137 * y ) - 0.163 * y ),
                 1.0 + b * ( -0.627 + r * (0.627 - 0.693 * y) + 0.287 * y ) + r * ( -1.0 + 0.5 * y ),
                 1.0 + b * ( -0.4 + r * (0.9 - 1.1 * y ) + 0.6 * y ) - y + r * ( y - 1.0 ) }
    end

    setmetatable(color, self)
    self.__index = self; return color
end

function RYBcolor:presetColor( colorName )
    return RYBcolor:new( unpack( presetRybColors[colorName] ) )
end

function RYBcolor:randomColor()
    return RYBcolor:new( math.random(), math.random(), math.random() )
end

function RYBcolor:randomColorChain( colorsAmount )
    local colorChain = {}
    local resultColor = RYBcolor:randomColor()
    
    colorChain[1] = resultColor

    for i = 2, colorsAmount do
        colorChain[i] = RYBcolor:randomColor()
        resultColor = resultColor + colorChain[i]
    end

    colorChain.result = resultColor

    return colorChain
end
