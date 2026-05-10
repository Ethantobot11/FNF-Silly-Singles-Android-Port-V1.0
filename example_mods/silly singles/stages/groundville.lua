function onCreate()
	-- background shit
	makeLuaSprite('grounding_floors', 'grounding_floors', -1150, -950);
	scaleObject('grounding_floors',2.7,2.7);
	setScrollFactor('grounding_floors', 1, 1);	

	addLuaSprite('grounding_floors', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end