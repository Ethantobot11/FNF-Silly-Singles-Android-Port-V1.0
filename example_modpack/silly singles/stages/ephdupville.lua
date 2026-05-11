function onCreate()
	-- background shit
	makeLuaSprite('ephdupville', 'ephdupville', -720, -300);
	scaleObject('ephdupville',2,2);
	setScrollFactor('ephdupville', 0.9, 0.9);	
	
	makeAnimatedLuaSprite('mar', 'mar', 350, 480)
	scaleObject('mar',2,2);
    addAnimationByPrefix('mar', 'mar', 'mar idle', 24, true);

	addLuaSprite('ephdupville', false);
    addLuaSprite('mar', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end