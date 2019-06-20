
math.randomseed( os.time() )

require( "ryb_color" )
require( "cubic_coordinates" )
require( "hexagon" )
require( "hex_grid" )
require( "hex_interaction" )

newGrid = HexGrid:new()
local winColor = RYBcolor:randomColor()
--newGrid:standardGridGeneration( 1 )
newGrid:randomGridGeneration( 25, 5, winColor )
drawnGrid = newGrid:drawGrid()

for _, drawnHex in pairs( drawnGrid ) do
    drawnHex:addEventListener( "touch", dragHex )
end
