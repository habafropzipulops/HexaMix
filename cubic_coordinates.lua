
CubicCoordinates = {}

local cos30 = math.sqrt(3) / 2
local cos60 = 0.5

function CubicCoordinates:new( xCoord, yCoord, zCoord )
    local coords = { x = xCoord, y = yCoord, z = zCoord }

    function CubicCoordinates.__add( firstCoords, secondCoords )
        local coordsSum = CubicCoordinates:new()

        for _,index in ipairs({ "x", "y", "z" }) do
            coordsSum[index] = firstCoords[index] + secondCoords[index]
        end

        return coordsSum
    end

    function CubicCoordinates.__eq( firstCoords, secondCoords )
        for _,index in ipairs({ "x", "y", "z" }) do

            if firstCoords[index] ~= secondCoords[index] then
                return false
            end

        end

        return true
    end

    function coords.convertToPixels( hexEgdeSize, coordinateCenter )
        hexCenterX = hexEgdeSize * cos30 * ( 2 * coords.x + coords.z ) + coordinateCenter.x
        hexCenterY = 3 * cos60 * hexEgdeSize * coords.z + coordinateCenter.y
        return { x = hexCenterX, y = hexCenterY }
    end

    function coords:absMaxCoord()
        return math.max( math.abs(coords.x), math.abs(coords.y), math.abs(coords.z) )
    end

    function coords:uniqKey()
        return ( coords.x .. ";" .. coords.y .. ";" .. coords.z )
    end

    setmetatable(coords, self)
    self.__index = self; return coords
end

function CubicCoordinates:relativeNeighbors()
    return { CubicCoordinates:new( 1, -1, 0 ), CubicCoordinates:new( 1, 0, -1 ),
             CubicCoordinates:new( 0, 1, -1 ), CubicCoordinates:new( -1, 1, 0 ),
             CubicCoordinates:new( -1, 0, 1 ), CubicCoordinates:new( 0, -1, 1 ) }
end

function CubicCoordinates:center()
    return CubicCoordinates:new( 0, 0, 0 )
end
