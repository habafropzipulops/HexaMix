
require( "utils" )

local cos30 = math.sqrt(3) / 2
local cos60 = 0.5
local displayWidth = display.contentWidth
local displayHeigth = display.contentHeight
local origin = { x = 0.0, y = 0.0 }
local displayCenter = { x = 0.5 * displayWidth, y = 0.5 * displayHeigth }

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

local function getGridBorders( gridCoords )
    local leftBorder, lowerBorder = -math.huge, -math.huge
    local rightBorder, upperBorder = math.huge, math.huge

    for _,coords in pairs( gridCoords ) do
        if leftBorder < coords.x then leftBorder = coords.x end
        if rightBorder > coords.x then rightBorder = coords.x end
        if lowerBorder < coords.z then lowerBorder = coords.z end
        if upperBorder > coords.z then upperBorder = coords.z end
    end

    return { left = leftBorder, right = rightBorder,
             lower = lowerBorder, upper = upperBorder }
end

local function findCoordinateCenter( borders, hexEgdeSize, displayCenter )
    local x = ( borders.right + borders.left ) / 2 
    local z = ( borders.upper + borders.lower ) / 2
    local y = - x - z
    local centerCoords = CubicCoordinates:new( x, y, z )
    local pixelCoords = centerCoords.convertToPixels( hexEgdeSize, origin )

    return { x = displayCenter.x - pixelCoords.x, y = displayCenter.y - pixelCoords.y}
end

local function calculateHexEgdeSize( borders, displayHeigth, displayWidth  )
    local gridWidth = math.abs(borders.left) + math.abs(borders.right) + 1
    local gridHeight = math.abs(borders.lower) + math.abs(borders.upper) + 1
    local displayRatio = displayHeigth / displayWidth
    local gridRatio = gridHeight / gridWidth
    local hexEgdeSize = 0

    local k = math.sqrt( displayRatio / gridRatio )

    if k >= 1 then
        hexEgdeSize = displayWidth / ( 2 * gridWidth )
    else
        hexEgdeSize = k * displayWidth / ( 2 * gridWidth )
    end

    return hexEgdeSize
end

function HexGrid:new()

    local grid = {}
    grid.coords = { defaultCenter }

    function grid:standardGridGeneration( gridLevel )
        local borderHexes = { defaultCenter }        

        for borderLevel = 1, gridLevel do
            local newBorderHexes = {}
            
            for _,hexCoord in ipairs( borderHexes ) do
                borderHexNeighbors = findBorderNeighborHexes( hexCoord, borderLevel )
                newBorderHexes = mergeTables( newBorderHexes, borderHexNeighbors )
            end
         
            borderHexes = getUniqueElements( newBorderHexes )
            grid.coords = mergeTables( grid.coords, borderHexes )
        end

    end

    function grid:randomGridGeneration( hexAmount, componentsAmount, winColor )
        local neighborsIndex = { 1, 2, 3, 4, 5, 6 }
        local colorComponents = winColor.decomposition( componentsAmount )
        local randomHexes = {}
        local gridSize = 1

        defaultCenter.color = colorComponents[1]

        randomHexes[defaultCenter.uniqKey()] = defaultCenter

        
        while gridSize < hexAmount do
            randomHex = getRandomItem( randomHexes )
            shuffle( neighborsIndex )

            for _, index in ipairs(neighborsIndex) do
                newRandomHex = randomHex + relativeNeighbors[index]
                key = newRandomHex.uniqKey()

                if not randomHexes[key] then

                    if gridSize < componentsAmount then
                        newRandomHex.color = colorComponents[gridSize]
                        randomHexes[key] = newRandomHex
                    end

                    gridSize = gridSize + 1
                    randomHexes[key] = newRandomHex
                    break
                
                end

            end

        end

        grid.winColor = winColor
        grid.coords = randomHexes

    end

    function grid:drawGrid( event )
        local gap = 2
        local drawnGrid = {}
        local gridBorders = getGridBorders( grid.coords )
        local hexEgdeSize = calculateHexEgdeSize( gridBorders, displayHeigth, displayWidth )
        local coordinateCenter = findCoordinateCenter( gridBorders, hexEgdeSize, displayCenter )

        for key, hexCubicCoords in pairs(grid.coords) do
            hexCenter = hexCubicCoords.convertToPixels( hexEgdeSize, coordinateCenter )
            newHex = Hexagon:new( hexCenter, hexEgdeSize - gap, grid.coords[key].color )
         
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
