function onEvent(eventName, value1, value2)
    if eventName == 'Song Over' then
        if value1 == '1' then
            cameraFlash('game', '000000', 1/0, true)
        else
            cameraFlash('game', '000000', 0.1, true)
        end
    end
end