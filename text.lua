function love.load()
   
end


function love.draw()
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("This is a pretty lame example.", 10, 200)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print("This lame example is twice as big.", 10, 250, 0, 2, 2)
    love.graphics.setColor(0, 0, 255, 255)
    love.graphics.print("This example is lamely vertical.", 300, 30, math.pi/2)
end
