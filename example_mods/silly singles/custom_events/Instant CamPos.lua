function onEvent(name,value1,value2)
    if name == "Instant CamPos" then
		  triggerEvent('Camera Follow Pos', value1, value2)
      setProperty('camFollowPos.x', value0)
		  setProperty('camFollowPos.y', value1)
    end
end