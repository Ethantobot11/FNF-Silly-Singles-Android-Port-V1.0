function onUpdatePost()
	local angleOfs = math.random(-2, 2)
	local posXOfs = math.random(-4, 4)
	local posYOfs = math.random(-2, 2)
	if getProperty('healthBar.percent') > 80 then
		angleOfs = math.random(-18, 18)
		posXOfs = math.random(-12, 12)
		posYOfs = math.random(-17, 17)
	else
		setProperty('iconP2.flipX', false)
	end
	setProperty('iconP2.angle', angleOfs)
	setProperty('iconP2.x', getProperty('iconP1x') + posXOfs)
	setProperty('iconP2.y', defaultY + posYOfs)
end