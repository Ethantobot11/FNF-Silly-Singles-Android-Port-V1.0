function onCreate()
	-- background shit
	makeLuaSprite('maxresdefault', 'maxresdefault', -300, -300);
	setScrollFactor('maxresdefault', 0.9, 0.9);

	addLuaSprite('maxresdefault', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end