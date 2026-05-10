--made with Super_Hugo's Stage Editor

function onCreate()

	makeLuaSprite('obj1', 'combo', 601, 768)

	setObjectOrder('obj1', 10)
	setProperty('obj1.antialiasing', false)

	addLuaSprite('obj1', true)


	makeLuaSprite('obj2', 'combo', 601, 768)

	setObjectOrder('obj2', 10)
	setProperty('obj2.antialiasing', false)

	addLuaSprite('obj2', true)

end