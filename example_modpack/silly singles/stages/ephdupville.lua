function onCreate()
	-- background shit
	makeLuaSprite('ephdupville', 'ephdupville', -300, -300);
	setScrollFactor('ephdupville', 0.9, 0.9);	
	
	makeAnimatedLuaSprite('mar', 'mar', 250, 460)
    addAnimationByPrefix('mar', 'mar', 'mar idle', 24, true);

	addLuaSprite('ephdupville', false);
    addLuaSprite('mar', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end