
local cos30 = math.sqrt(3) / 2
local cos60 = 0.5

Hexagon = {}

function Hexagon:new( hexCenter, hexEdgeSize, color )

    local hex = {}
    local X = hexCenter.x
    local Y = hexCenter.y

    hex.centX = X
    hex.centY = Y
    hex.edgeSize = hexEdgeSize
    hex.vertices = { X - hexEdgeSize * cos30, Y + hexEdgeSize / 2,
                     X, Y + hexEdgeSize * cos60 + hexEdgeSize / 2,
                     X + hexEdgeSize * cos30, Y + hexEdgeSize / 2,
                     X + hexEdgeSize * cos30, Y - hexEdgeSize / 2,
                     X, Y - hexEdgeSize * cos60 - hexEdgeSize / 2,
                     X - hexEdgeSize * cos30, Y - hexEdgeSize / 2 }
    if color then
        hex.color = color
    else
        hex.color = RYBcolor:randomColor()
    end

    function hex:drawHex()

        local newHex = display.newPolygon( X, Y, hex.vertices )
        newHex.strokeWidth = 2
        newHex:setStrokeColor( 1.0, 1.0, 1.0 )
        newHex.color = hex.color
        newHex:setFillColor( unpack( newHex.color.convertToRgb() ) )
        return newHex

    end 

    setmetatable(hex, self)
    self.__index = self; return hex
end
