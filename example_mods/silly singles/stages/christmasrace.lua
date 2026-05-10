--made with Super_Hugo's Stage Editor

function onCreate()
	makeLuaSprite('obj1', 'christmas_race_bg', -300, -300)
	setObjectOrder('obj1', 0)
	addLuaSprite('obj1', true)
	setProperty('obj1.antialiasing', false);

	makeLuaSprite('obj2', 'christmas_race_trees', -300, -300)
	setObjectOrder('obj2', 1)
	addLuaSprite('obj2', true)
	setProperty('obj2.antialiasing', false);
end