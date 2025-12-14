-- UI components library

Window = {}
Button = {}
Toolbar = {}
Icon = {}

function Window:generate_button(name, initx, inity,endx, endy)
  return Button:new({name=name,posx=initx,posy=inity,w=endx,h=endy})
end

function Window:new(o)
  o = o or {}
  o.buttons = {}
  o.x = o.x  or 10
  o.w = o.w or 30
  o.y = o.y  or 20
  o.h = o.h or 20
  o.options = o.options or {}
  for k,v in pairs(o.options) do
    button = self:generate_button(v.name,o.x + 4,o.y + 10, o.w - 8 ,o.h * 0.35)
    add(o.buttons, button)
  end
  o.round = o.round or 1
  setmetatable(o, {__index = self})
  return o
end

function Window:draw()
  -- Outside Window
  rrectfill(self.x, self.y, self.w, self.h, self.round, 14)
  -- Inner window
  rrectfill(self.x + 2, self.y + 8, self.w - 4, self.h - 10, self.round, 2)
    -- Generate icons
  spr(1, (self.x + self.w) *0.85, self.y, 1, 1, false, false)
  spr(2, (self.x + self.w) *0.92, self.y, 1, 1, false, false)
  for k,v in pairs(self.buttons) do
    v:draw()
  end
end

function Button:new(o)
  o = o or {}
  o.name = o.name or "GAMEDEVPILLS.COM"
  o.posx = o.posx  or 10
  o.posy = o.posy  or 20
  o.w = o.w or 0
  o.h = o.h or 0
  o.round = o.round or 1
  setmetatable(o, {__index = self})
  return o
end

function Button:draw()
  rrectfill(self.posx, self.posy, self.w, self.h, self.round, 7)
  print(self.name, self.posx + 2, self.posy + 2, 0)
end

function Toolbar:new(o)
  o = o or {}
  o.posx = o.posx  or 0
  o.sizex = o.sizex or 16
  o.posy = o.posy  or 16
  o.sizey = o.sizey or 96
  o.size = o.size or 3
  o.round = o.round or 0
  o.icons = o.icons or {}
  setmetatable(o, {__index = self})
  return o
end

function Toolbar:cls()
for _, icon in pairs(toolbar.icons) do
  icon.active = false
  icon.sprite = icon.ORIGINAL_SPRITE
end
end

function Toolbar:hover()
  if mouse.posx >= toolbar.posx and mouse.posx < (toolbar.posx + toolbar.sizex) and mouse.posy >= toolbar.posy and mouse.posy <= toolbar.posy + (toolbar.sizey) then
    return true
  else
    return false
  end
end

function Toolbar:update()
  if cam then
    if cam.mode == "static" then
      if btn(1) then
          toolbar.posx +=  cam.move_x
      end
      if btn(0) then
          toolbar.posx -= cam.move_x
      end
    end
  end

  -- If we are outside the Toolbar area, switch to selected mode, otherwise switch to pointer
if mouse then
  if mouse.current_mode != mouse.modes.pointer and self:hover() then
    mouse:switch_to_pointer()
  elseif mouse.previous_mode != mouse.current_mode and not self:hover() then
    mouse:switch_previous_mode()
  end

  for k,icon in pairs(self.icons) do
    icon:update()
  end
end
end

function Toolbar:draw()
  -- Inner window
  rrectfill(self.posx + 1, self.posy + 1, self.sizex - 2, self.sizey, self.round, 14)
  -- Shade bottom
  line(self.posx + 2, self.posy + self.sizey, self.posx + self.sizex -3, self.posy + self.sizey, 2)
  -- Draw icons in a horizontal grid, responsive to component position
  local icon_size = 8
  local padding = 4
  
  local cols = flr((self.sizex - padding) / (icon_size + padding))
  for i, icon in ipairs(self.icons) do
    local col = (i - 1) % cols
    local row = flr((i - 1) / cols)
    local x = self.posx + padding + col * (icon_size + padding)
    local y = self.posy + padding + row * (icon_size + padding)
    icon.posx = x
    icon.posy = y
    icon:draw()
  end
end

function Icon:new(o)
  o = o or {}
  o.name = o.name or "Icon"
  o.posx = o.posx  or 0
  o.posy = o.posy  or 0
  o.sprite_pressed = o.sprite_pressed or 0
  o.sprite = o.sprite or 0
  o.active_sprite = o.active_sprite or 0 
  o.type = o.type or "Brush"
  o.ORIGINAL_SPRITE = o.sprite
  o.active = false
  setmetatable(o, {__index = self})
  return o
end

function Icon:draw()
  spr(self.sprite, self.posx, self.posy, 1, 1, false, false)
end

-- Detect click on the icon
function Icon:update()
local play_sound = true
  if mouse.btnpressed == 1 and mouse.posx >= self.posx and mouse.posx <= self.posx + 8 and mouse.posy >= self.posy and mouse.posy <= self.posy + 8 then
    -- If icon is inside a Toolbar.
    if Toolbar:hover() then
      Toolbar:cls()  -- Deactivate all other icons in the Toolbar
    end
    if play_sound then sfx(1) end
      if self.type == "Pointer" then
        mouse:switch_to_pointer()
        mouse:save_previous_mode()
        self.active = true
        self.sprite = self.sprite_pressed
      elseif self.type == "Ground" then
        mouse:switch_to_ground()
        mouse:save_previous_mode()
        self.active = true
        self.sprite = self.sprite_pressed
      elseif self.type == "Rubber" then
        mouse:switch_to_rubber()
        mouse:save_previous_mode() 
        self.active = true
        self.sprite = self.sprite_pressed
      end
    else
      if self.active then
        self.sprite = self.active_sprite
      else
        self.sprite = self.ORIGINAL_SPRITE
      end
    play_sound = false
  end
end