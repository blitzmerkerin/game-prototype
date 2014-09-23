local STI = require("lib/sti")

Map = {}
Map.__index = Map
function Map.create(path, world)
    local self = setmetatable({}, Map)
    self.dynamics = {
      objects = {}
    }
    self.world = world
    self.player = {x = 0, y = 0}
    self.mapSTI = STI.new(path)

		self:initDynamicLayer()
    self:initKillAreas()
    self.mapSTI:initWorldCollision(world)    
    return self
end


function Map:initDynamicLayer()
  if self.mapSTI.layers["dynamic"] then
    self.dynamics = self.mapSTI.layers["dynamic"]
    for _,object in pairs(self.dynamics.objects) do
      if object.properties.isPlayer then
          -- use the center of the object as starting position
          self.player.x = object.x + object.width / 2
          self.player.y = object.y + object.height / 2
          self.dynamics.objects[_] = nil
      elseif object.shape == "rectangle" then
        object.body = love.physics.newBody(self.world, object.x + (object.width / 2), object.y + (object.height / 2), "dynamic")
        object.shape = love.physics.newRectangleShape(0, 0, object.width, object.height)
        object.fixture = love.physics.newFixture(object.body, object.shape, 5)
        
        -- body object should be used
        object.x = nil
        object.y = nil
        object.width = nil
        object.height = nil
      end
    end
    self.mapSTI:removeLayer("dynamic")
  end
end

function Map:initKillAreas()
  if self.mapSTI.layers["killAreas"] then

    self.killAreas = self.mapSTI.layers["killAreas"].objects
    for _,area in pairs(self.killAreas) do
        area.body = love.physics.newBody(self.world, area.x + (area.width / 2), area.y + (area.height / 2))
        area.shape = love.physics.newRectangleShape(0, 0, area.width, area.height)
        area.fixture = love.physics.newFixture(area.body, area.shape, 5)
        -- area.body:setActive(false) 
               
        -- body object should be used
        area.x = nil
        area.y = nil
        area.width = nil
        area.height = nil
    end
    self.mapSTI:removeLayer("killAreas")
  end
end

function Map:update(dt)
    self.mapSTI:update(dt)
    
  
end

function Map:draw()
    self.mapSTI:draw()
    love.graphics.setColor(50, 50, 50)
    for _,object in pairs(self.dynamics.objects) do
          love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
    end
end

function Map:resize()
    self.mapSTI:resize()
end

function Map:getWorldSize()
  return self.mapSTI.width * self.mapSTI.tilewidth, self.mapSTI.height * self.mapSTI.tileheight
end

function Map:getPlayerStartingPosition()
  return self.player.x, self.player.y
end
  
  
