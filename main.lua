
require( "ryb_color" )
require( "cubic_coordinates" )
require( "hexagon" )
require( "hex_grid" )
require( "hex_interaction" )

newGrid = HexGrid:new( 3 )

newGrid:coordsGeneration()
drawnGrid = newGrid:drawGrid()

for _, drawnHex in pairs( drawnGrid ) do
    drawnHex:addEventListener( "touch", dragHex )
end
