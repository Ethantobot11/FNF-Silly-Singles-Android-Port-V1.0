function onCreate()
	-- background shit
	makeLuaSprite('spoingus', 'spoingus', -300, -300);
	setScrollFactor('spoingus', 1, 1);

	addLuaSprite('spoingus', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end