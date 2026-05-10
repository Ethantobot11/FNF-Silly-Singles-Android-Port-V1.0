function onCreate()
	-- background shit
	makeLuaSprite('BC', 'BC', -350, -125);
	scaleObject('BC',1.7,1.7);
	setScrollFactor('BC', 1, 1);

	makeAnimatedLuaSprite('patar', 'patar', 1400, 2200)
	scaleObject('patar',2.3,2.3);
	addAnimationByPrefix('patar', 'left', 'patar danceLeft', 24, true);
	addAnimationByPrefix('patar', 'right', 'patar danceRight', 24, true);
	addLuaSprite('BC', false);

	makeAnimatedLuaSprite('spongegar', 'spongegar', 2800, 2330)
	scaleObject('spongegar',1.7,1.7);
	addAnimationByPrefix('spongegar', 'left', 'spongegar danceLeft', 24, true);
	addAnimationByPrefix('spongegar', 'right', 'spongegar danceRight', 24, true);


end

function onBeatHit()
		if curBeat % 2 == 0 then
		objectPlayAnimation('patar','left', false)
		objectPlayAnimation('spongegar','left', false)
		else
		objectPlayAnimation('patar','right', false)
		objectPlayAnimation('spongegar','right', false)
end
end