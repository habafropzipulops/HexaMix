
math.randomseed( os.time() )

require( "utils" )
require( "ryb_color" )
require( "cubic_coordinates" )
require( "hexagon" )
require( "hex_grid" )
require( "hex_interaction" )

newGrid = HexGrid:new()

--newGrid:standardGridGeneration( 2 )
newGrid:randomGridGeneration( 20 )
drawnGrid = newGrid:drawGrid()

for _, drawnHex in pairs( drawnGrid ) do
    drawnHex:addEventListener( "touch", dragHex )
end
