Cam = {}

function Cam:new(o)
  o = o or {}
  o.x = o.x  or 0
  o.y = o.y  or 0
  o.mode = o.mode or "static" -- static, follow_player, pan_to
  o.move_x = 2
  o.move_y = 2
  setmetatable(o, {__index = self})
  return o
end

function Cam:update()
    if self.mode == "static" then
        if btn(1) then
            self.x += self.move_x
        end
        if btn(0) then
            self.x -= self.move_x
        end
    end
end

function Cam:draw()
    if self.mode == "static" then
        -- Draw camera rectangle
        camera(self.x,self.y)
        local right_arrow = spr(104, self.x + SCREEN_WIDTH -7, self.y + SCREEN_HEIGHT / 2,1,1,false,false)
        local left_arrow = spr(104, self.x, self.y + SCREEN_HEIGHT / 2,1,1,true,false)
    end
end