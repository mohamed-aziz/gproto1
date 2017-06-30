-- Author: Mohamed Aziz Knani
-- Date: Started in 27 Jun 2017


local class = require 'middleclass'

s = {
   ['width'] = love.graphics.getWidth(),
   ['height'] = love.graphics.getHeight()
}

dy = 0.5
sh = s['height'] - 100

local objects = {}

-- SQUARE

local square = class('square')

function square:initialize(x, y, world)
   self.body = love.physics.newBody(world, x, y, "dynamic")
   self.shape = love.physics.newRectangleShape(25, 25)
   self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function square:update(dt)
   if self.body:getY() < sh + dy or self.body:getY() > sh + dy then
      self.body:setY(self.body:getY() + (sh - self.body:getY()) * dt )
   end
end

function square:draw()
   love.graphics.setColor(140, 23, 11, 255)
   love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
   love.graphics.setColor(255, 255, 255, 255)
end


-- GROUND

local ground = class('ground')

function ground:initialize(x, y, world)
   self.body = love.physics.newBody(world, x, y, "static")
   self.shape = love.physics.newRectangleShape(10, s['width'])
   self.fixture = love.physics.newFixture(self.body, self.shape)
end

function ground:update(dt)

end

function ground:draw()
   love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

-- Obstacle

obstacles = {}

obstL = {}
obstR = {}

local obstacle = class('obstacle')

function obstacle:initialize(dir, w, h)
   self.dir = dir
   self.width = w
   self.height = h
   self.shape = love.physics.newRectangleShape(w, h)
   self._invalidate = false
   if self.dir == 0 then
      if #obstL ~= 0 and obstL[#obstL].body:getY() < 100 then
         self._invalidate = true
         return
      end
      self.body = love.physics.newBody(world, s['width'] / 2 - w, 0, "dynamic")
      self.body:setGravityScale(1)
      table.insert(obstL, self)
   else
      if #obstR ~= 0 and obstR[#obstR].body:getY() < 100 then
         self._invalidate = true
         return
      end
      self.body = love.physics.newBody(world, s['width'] / 2 + w, 0, "dynamic")
      self.body:setGravityScale(-1)
      table.insert(obstR, self)
   end
   self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function obstacle:draw()
   love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

function obstacle:update(dt)
   self.body:setY(dt * 100 + self.body:getY())
end


--MENU SYStem

local Menu = class('Menu')

function Menu:initialize(options)

end

-- MAIN

function love.load()
   love.window.setMode(800, 600, {vsync=true, minwidth=400, minheight=300})
   love.physics.setMeter(64)
   world = love.physics.newWorld(9.81 * 64, - 0.1 * 64, true)
   square1 = square:new(s['width'] / 2 - 35, sh, world)
   square2 = square:new(s['width'] / 2 , sh, world)

   zground = ground:new(s['width'] / 2 - 10, s['height'] / 2, world)

   square2.body:setGravityScale(-1) -- goes to left
   square1.body:setGravityScale(1) -- goes to right

   square1.body:setMass(0.1)

   -- set two walls so that square can bounce
   objects.obs1 = {}
   objects.obs1.body = love.physics.newBody(world, 0, s['height'] / 2, "static")
   objects.obs1.shape = love.physics.newRectangleShape(10, s['width'])
   objects.obs1.fixture = love.physics.newFixture(objects.obs1.body, objects.obs1.shape)
   objects.obs2 = {}
   objects.obs2.body = love.physics.newBody(world, s['width'], s['height'] / 2, "static")
   objects.obs2.shape = love.physics.newRectangleShape(10, s['width'])
   objects.obs2.fixture = love.physics.newFixture(objects.obs2.body, objects.obs2.shape)
end


function love.draw()
   -- love.graphics.rectangle("fill", s['width'] / 2 - 10, 0, 10, s['height'])
   square1:draw()
   square2:draw()
   zground:draw()
   for k, v in pairs(obstacles) do
      v:draw()
   end
end

function love.update(dt)
   world:update(dt)

   if love.keyboard.isDown("left") then
      square1.body:applyForce(-400, -30)
      square1.body:setAngularVelocity(math.pi * 2 * dt * 100)
   end
   if love.keyboard.isDown("right") then

      square2.body:applyForce(400, -30)
      square2.body:setAngularVelocity(math.pi * 2 * dt * 100)
   end

   if #obstacles < 10 then
      o = obstacle:new(love.math.random(0, 1), love.math.random(10, 100), love.math.random(10, 100))
      if o._invalidate == false then
         table.insert(obstacles, o)
      else
         o = nil
      end
   end

   for k, v in pairs(obstacles) do
      v:update(dt)
   end


   for k, v in pairs(obstacles) do
      if v.body:getY( ) > s['height'] + v.height then
         table.remove(obstacles, k)
      end
   end

   square1:update(dt)
   square2:update(dt)
   zground:update(dt)
end
