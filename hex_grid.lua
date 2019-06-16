
require( "utils" )

local cos30 = math.sqrt(3) / 2
local cos60 = 0.5
local displayWidth = display.contentWidth
local displayHeigth = display.contentHeight
local displayCenter = { x = (0.5 * displayWidth), y = (0.5 * displayHeigth) }

HexGrid = {}

local defaultCenter = CubicCoordinates:center()
local relativeNeighbors = CubicCoordinates:relativeNeighbors()
local defaultColor = {}

local function findBorderNeighborHexes( hexCoords, borderLevel )
    borderHexNeighbors = {}

    for _,relativeNeighbor in pairs(relativeNeighbors) do
        hexNeighbors = hexCoords + relativeNeighbor

        if hexNeighbors:absMaxCoord() == borderLevel then
            borderHexNeighbors[#borderHexNeighbors + 1] = hexNeighbors
        end

    end

    return borderHexNeighbors
end

local function getGridProportions( gridCoords )
    local gridLeft, gridDown = -1000000, -1000000
    local gridRight, gridUp = 1000000, 1000000

        for _,coords in ipairs( gridCoords ) do
            if gridLeft < coords.x then gridLeft = coords.x end
            if gridRight > coords.x then gridRight = coords.x end
            if gridDown < coords.z then gridDown = coords.z end
            if gridUp > coords.z then gridUp = coords.z end
        end

    local gridWidth = - gridRight + gridLeft + 1
    local gridHeight = - gridUp + gridDown + 1
    
    return { width = gridWidth, height = gridHeight }
end


local function calculateHexEgdeSize( gridCoords, displayHeigth, displayWidth  )
    local gridProportions = getGridProportions( gridCoords )
    local displayRatio = displayHeigth / displayWidth
    local gridRatio = gridProportions.height / gridProportions.width
    local k = math.sqrt( displayRatio / gridRatio )

    if k >= 1 then
        hexEgdeSize = displayWidth / ( 2 * gridProportions.width )
    else
        hexEgdeSize = k * displayWigth / ( 2 * gridProportions.width )
    end

    return hexEgdeSize
end

function HexGrid:new( gridSize )

    local grid = {}
    grid.coords = { defaultCenter }
    grid.size = gridSize

    function grid:coordsGeneration()
        local borderHexes = { defaultCenter }
        
        for borderLevel = 1, grid.size do
            local newBorderHexes = {}
            
            for _,hexCoord in ipairs( borderHexes ) do
                borderHexNeighbors = findBorderNeighborHexes( hexCoord, borderLevel )
                newBorderHexes = mergeTables( newBorderHexes, borderHexNeighbors )
            end
         
            borderHexes = getUniqueElements( newBorderHexes )
            grid.coords = mergeTables( grid.coords, borderHexes )
        end

    end

    function grid:drawGrid( event )
        local hexEgdeSize
        local gap = 2
        local drawnGrid = {}
        local hexEgdeSize = calculateHexEgdeSize( grid.coords, displayHeigth, displayWidth )

        for _, hexCubicCoords in ipairs(grid.coords) do
            hexCenter = hexCubicCoords.convertToPixels( hexEgdeSize, displayCenter )

            newHex = Hexagon:new( hexCenter, hexEgdeSize - gap )
         
            drawnHex = newHex:drawHex()
            drawnHex.coords = hexCubicCoords
            drawnHex.id = hexCubicCoords.uniqKey()
            drawnHex.width = drawnHex.contentWidth
            drawnHex.height = drawnHex.contentHeight
            drawnGrid[drawnHex.id] = drawnHex
            drawnHex.super = drawnGrid
        end

        return drawnGrid
    end

    setmetatable(grid, self)
    self.__index = self; return grid
end
