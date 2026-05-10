--made with Super_Hugo's Stage Editor

function onCreate()
	makeLuaSprite('obj1', 'twitter_bg', -631, -399)
	scaleObject('obj1',3.3,3.3);
	setObjectOrder('obj1', 0)
	addLuaSprite('obj1', true)

	makeLuaSprite('obj2', 'twitter_flower', -812, -399)
	scaleObject('obj2',1.9,1.9);
	setObjectOrder('obj2', 1)
	addLuaSprite('obj2', true)

	makeLuaSprite('obj3', 'twitter_bubble', -812, -399)
	scaleObject('obj3',1.9,1.9);
	setObjectOrder('obj3', 4)
	addLuaSprite('obj3', true)

	makeLuaSprite('obj4', 'twitter_tweet', -812, -399)
	scaleObject('obj4',1.9,1.9);
	setObjectOrder('obj4', 5)
	addLuaSprite('obj4', true)
end