
local displayW = display.contentWidth
local displayH = display.contentHeight

local relativeNeighbors = CubicCoordinates:relativeNeighbors()
local defaultCenter = CubicCoordinates:center()
local inactiveHexColor = { 0.5, 0.5, 0.5 }
local inactiveHexStrokeWidth = 0
local defaultStrokeColor = { 1.0, 1.0, 1.0 }
local defaultStrokeWidth = 2
local neighborHexStrokeColor = { 1.0, 0.0, 0.0 }
local neighborHexStrokeWidth = 10
local overlappingHexStrokeColor = { 0.0, 1.0, 0.0 }

local function areNeighbors( firstHex, secondHex )
    for _, relativeNeighbor in ipairs(relativeNeighbors) do

        if (firstHex.coords + relativeNeighbor == secondHex.coords) then
            return true
        end

    end

    return false
end

local function areOverlapped( firstObj, secondObj )
    if not (firstObj and secondObj) then
        return false
    end
    
    local dx = firstObj.x - secondObj.x
    local dy = firstObj.y - secondObj.y

    local distance = math.sqrt( dx * dx + dy * dy ) * 2.5
    local objectSize = ( secondObj.contentWidth / 2 ) + ( firstObj.contentWidth / 2 )

    if ( distance > objectSize ) then
        return false
    end

    return true
end

local function moveObject( event, objWidth, objHeight )
    if ( event.x < objWidth / 4 ) then
        xCoord =  objWidth / 4
    elseif ( event.x > displayW - objWidth / 4 ) then
        xCoord = displayW - objWidth / 4
    else
        xCoord = event.x
    end

    if ( event.y < objHeight / 2 ) then
        yCoord = objHeight / 2
    elseif (event.y > displayH - objHeight / 2) then
        yCoord = displayH - objHeight / 2
    else
        yCoord = event.y
    end

    return { x = xCoord, y = yCoord }
end 

function dragHex( event )  
    local target = event.target 
    local phase = event.phase
    local drawnGrid = target.super
    local hexOnHex = false

    if ( phase == "began" ) then

        display.getCurrentStage():setFocus( target ) 
        target.isFocus = true
        target.xStart = target.x
        target.yStart = target.y
        target:toFront()

        for hexId, drawnHex in pairs( drawnGrid ) do

            if not areNeighbors( drawnHex, target ) and ( drawnHex ~= target ) then
                drawnHex:setFillColor( unpack( inactiveHexColor ) )
                drawnHex.strokeWidth = inactiveHexStrokeWidth
            elseif areNeighbors( drawnHex, target ) then
                drawnHex.strokeWidth = neighborHexStrokeWidth
            end

        end

    elseif ( target.isFocus ) then

        if ( phase == "moved" ) then

            for key, drawnHex in pairs( drawnGrid ) do

                if ( drawnHex ~= target ) and areOverlapped( drawnHex, target ) then 
                    drawnHex:setStrokeColor( unpack( overlappingHexStrokeColor ) )
                else
                    drawnHex:setStrokeColor( unpack( neighborHexStrokeColor ) )
                end

            end
            
            movingCoords = moveObject( event, target.width, target.height )
            target.x = movingCoords.x
            target.y = movingCoords.y

        elseif ( phase == "ended" or phase == "cancelled" ) then
                
            display.getCurrentStage():setFocus( nil )
                
            for key, drawnHex in pairs( drawnGrid ) do

                if ( drawnHex ~= target ) and areNeighbors( drawnHex, target ) and areOverlapped( drawnHex, target ) then
                    drawnHex.color = drawnHex.color + target.color
                    hexOverlapsHex = true
                end

                drawnHex:setFillColor( unpack( drawnHex.color.convertToRgb() ) )
                drawnHex.strokeWidth = defaultStrokeWidth
                drawnHex:setStrokeColor( unpack( defaultStrokeColor ) )
            end
            
            target.isFocus = false

            if hexOverlapsHex then
                display.remove( target )
                drawnGrid[target.id] = nil
                target = nil
                hexOverlapsHex = false
            else
                target.x = target.xStart
                target.y = target.yStart
            end

        end
    
    end
    
    return true
end
