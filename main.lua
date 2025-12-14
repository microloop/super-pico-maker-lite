function _init()
-- Debug initialization of the game
printh("Game started","debug.txt")
-- Enable mouse support
poke(0x5f2d,1)
-- GLOBAL VARIABLES
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
MAP_WIDTH = 1024
MAP_HEIGHT = 256
TILE_STANDARD_SIZE = 8
-- Creating the list of icons
icons = {}
-- Initialice our icons that will be part of the toolbar
pointer = Icon:new({name="Pointer",posx=106,posy=0,sprite=84,
sprite_pressed=100,active_sprite=116,type="Pointer"})
ground = Icon:new({name="Ground",posx=116,posy=0,sprite=85,
sprite_pressed=101,active_sprite=117,type="Ground"})
rubber = Icon:new({name="Rubber",posx=106,posy=0,sprite=83,
sprite_pressed=99,active_sprite=115,type="Rubber"})
-- Adding icons to the global icons list
add(icons,pointer)
add(icons,ground)
add(icons,rubber)

toolbar = Toolbar:new({posx=SCREEN_WIDTH/2-16,posy=12,sizex=40,sizey=15,round=1,icons=icons})
mouse = Mouse:new()
mouse:init()
cam = Cam:new()
end

function _update60()
-- Future functionality
toolbar:update()
mouse:update()
cam:update()
end

function _draw()
cls()
-- Draw map
map(0, 0, 0, 0, 128, 32)
cam:draw()
toolbar:draw()
mouse:draw()
end