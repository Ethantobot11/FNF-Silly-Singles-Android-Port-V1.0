function onCreate()
	-- background shit
	makeLuaSprite('the_void', 'the_void', 0, 0);
	setScrollFactor('the_void', 0.9, 0.9);

	addLuaSprite('the_void', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end