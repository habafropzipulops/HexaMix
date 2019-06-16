
local cos30 = math.sqrt(3) / 2
local cos60 = 0.5

Hexagon = {}

function Hexagon:new( hexCenter, hexEdgeSize )

    local hex = {}
    hex.centX = hexCenter.x
    hex.centY = hexCenter.y
    X = hex.centX
    Y = hex.centY
    hex.edgeSize = hexEdgeSize
    hex.color = { 0, 0, 0 }
    hex.vertices = { X - hexEdgeSize * cos30, Y + hexEdgeSize / 2,
                     X, Y + hexEdgeSize * cos60 + hexEdgeSize / 2,
                     X + hexEdgeSize * cos30, Y + hexEdgeSize / 2,
                     X + hexEdgeSize * cos30, Y - hexEdgeSize / 2,
                     X, Y - hexEdgeSize * cos60 - hexEdgeSize / 2,
                     X - hexEdgeSize * cos30, Y - hexEdgeSize / 2 }

    function hex:drawHex()

        local newHex = display.newPolygon( X, Y, hex.vertices )
        newHex.strokeWidth = 2
        newHex:setStrokeColor( 1.0, 1.0, 1.0 )
        newHex.color = RYBcolor:randomColor()
        newHex:setFillColor( unpack( newHex.color.convertToRgb() ) )
        return newHex

    end 

    setmetatable(hex, self)
    self.__index = self; return hex
end
