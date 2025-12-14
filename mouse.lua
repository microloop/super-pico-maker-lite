-- mouse.lua
-- simple mouse component for pico-8

Mouse = {}

function Mouse:new(o)
  o = o or {}
  o.posx = o.posx  or 10
  o.posy = o.posy  or 20
  o.mapx = flr(o.posx / 8)
  o.mapy = flr(o.posy / 8)
  o.busy_hand = false
  o.sprite = 66
  o.sprite_pressed = 67
  o.btnpressed = 0
  o.mouseover = 0
  o.grabbed_item = 0
  o.reload = function () end 
  o.modes = {
        pointer = function(mouse) mouse:pointer() end,
        brush   = function(mouse) mouse:brush() end,
        ground  = function(mouse) mouse:ground() end,
        rubber  = function(mouse) mouse:rubber() end
    }
    o.drawing = {
        pointer = function(mouse) mouse:pointer_draw() end,
        brush   = function(mouse) mouse:brush_draw() end,
        ground  = function(mouse) mouse:ground_draw() end,
        rubber  = function(mouse) mouse:rubber_draw() end
    }
   o.current_draw = o.drawing.pointer
   o.previous_mode = o.modes.pointer
   o.current_mode = o.modes.pointer
   o.animation_player = nil
   o.last_click_x = 0
   o.last_click_y = 0
  setmetatable(o, {__index = self})
  return o
end

function Mouse:init()
    self.current_mode = self.modes.pointer
    if Animation != nil then
      self.animation_player = Animation:new({0,12,11,10,9,8,0},8,{loop=false,playing=false})
    end
end

function Mouse:switch_previous_mode()
    printh("Switch to previous mode","debug.txt")
    self.current_mode = self.previous_mode
end

function Mouse:switch_to_pointer()
    self.current_draw = self.drawing.pointer
    self.current_mode = self.modes.pointer
end

function Mouse:switch_to_ground()
    self.current_draw = self.drawing.brush
    self.current_mode = self.modes.ground
end

function Mouse:switch_to_rubber()
    self.current_mode = self.modes.rubber
end

function Mouse:save_previous_mode()
    self.previous_mode = self.current_mode
end

function Mouse:remove_from_map(x,y,item)
    if mget(x,y) == item then
        mset(x,y,0)
    end
end

function Mouse:grab_item(item)
    self.grabbed_item = item
    self.busy_hand = true
end

function Mouse:update_map_position()
    self.mapx = flr(self.posx / 8) * 8
    self.mapy = flr(self.posy / 8) * 8
end

function Mouse:ground()
    self.current_draw = self.drawing.brush
    self.posx = stat(32) + cam.x
    self.posy = stat(33) + cam.y
    self.btnpressed = stat(34)
    self.mouseover = mget(self.posx/8, self.posy/8)
    self.draggable = fget(self.mouseover,1)
    self.sprite = 70
    local x = flr(self.posx/8)
    local y = flr(self.posy/8)

    if self.btnpressed == 1 and not toolbar:hover() then
        if (mget(x, y) == 0) then
            mset(x, y, 2) -- hardcoded tile for now
        end
    end
end

function Mouse:rubber()
    self.current_draw = self.drawing.rubber
    self.posx = stat(32) + cam.x
    self.posy = stat(33) + cam.y
    self.btnpressed = stat(34)
    self.mouseover = mget(self.posx/8, self.posy/8)
    self.draggable = fget(self.mouseover,1)

    self.sprite = 70

    if fget(self.mouseover,2) then
        self.sprite = 71
    end

    if self.btnpressed == 1 and fget(self.mouseover,2) then
        self.last_click_x = self.mapx
        self.last_click_y = self.mapy
        mset(self.posx/8, self.posy/8, 0) -- hardcoded tile for now
    end
end

function Mouse:pointer()
    -- get mouse position (pico-8 devkit mode)
    self.posx = stat(32) + cam.x
    self.posy = stat(33) + cam.y
    self.btnpressed = stat(34)
    self.mouseover = mget(self.posx/8, self.posy/8)
    self.draggable = fget(self.mouseover,1)
    
    -- Action to grab sprite from map
    if self.busy_hand == false and (self.draggable or self.grabbed_item != 0) then
        self.sprite = 68
        self.sprite_pressed = 69
        if self.btnpressed == 1 then
            sfx(0)
            self.sprite = self.sprite_pressed
            self:grab_item(self.mouseover)
            self:remove_from_map(self.posx/8, self.posy/8, self.grabbed_item)
        end

    elseif self.busy_hand then
        self.sprite = 69
        if self.btnpressed == 1 then
            self.sprite = self.sprite_pressed
            self.busy_hand = true
        else
            -- drop item on map
            sfx(2)
            if mget(self.posx/8, self.posy/8) == 0 then
                mset(self.posx/8, self.posy/8, self.grabbed_item)
                self.grabbed_item = 0
                self.busy_hand = false
            end
        end    
    else
        self.sprite = 66
        self.sprite_pressed = 67
        if self.btnpressed == 1 or self.busy_hand then
            self.sprite = self.sprite_pressed
        end
    end
end

function Mouse:pointer_draw()
    if self.busy_hand then
        spr(self.grabbed_item, self.mapx, self.mapy)
    end
    -- Free cursor when no action is
    if self.current_mode == self.modes.pointer then
        spr(self.sprite, self.posx, self.posy)
    end
end

function Mouse:rubber_draw()
     if self.current_mode == self.modes.rubber then
        spr(self.sprite, self.mapx, self.mapy)
    end
end

function Mouse:brush_draw()
     if self.current_mode == self.modes.ground then
        -- Draw tile cursor
        spr(4, self.mapx, self.mapy)
    end
end

function Mouse:update()
    self:update_map_position()
    if self.current_mode then
        self.current_mode(self)
    end
end

function Mouse:draw()
    if self.current_draw then
        self.current_draw(self)
    end
end