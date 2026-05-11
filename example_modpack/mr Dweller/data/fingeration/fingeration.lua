local allowCountdown = false
local warningimage = 'warningimage'
local confirmed = 0
local isMobile = false

function onCreate()
    if buildTarget == 'android' or buildTarget == 'ios' then
        isMobile = true
    end

    makeLuaSprite('warningimage', warningimage, 0, 0)
    setObjectCamera('warningimage', 'other')
    addLuaSprite('warningimage', true)

    if isMobile then
        addMobilePad('NONE', 'A_B') 
        addMobilePadCamera()
    end
end

function onStartCountdown()
    if not allowCountdown then
        return Function_Stop
    end
    return Function_Continue
end

function onUpdate(elapsed)
    if confirmed == 0 then
        local pressedAccept = false
        local pressedDecline = false

        if isMobile then
            if mobilePadJustPressed('A') then
                pressedAccept = true
            elseif mobilePadJustPressed('B') then
                pressedDecline = true
            end
        else
            if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SHIFT') then
                pressedAccept = true
            elseif getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ESCAPE') then
                pressedDecline = true
            end
        end

        if pressedAccept then
            confirmed = 1
            allowCountdown = true
            playSound('confirmMenu')
            
            if isMobile then removeMobilePad() end
            
            doTweenAlpha('nomorewarningimage', 'warningimage', 0, 0.5, 'sineOut')
            startCountdown()
        
        elseif pressedDecline then
            confirmed = 1
            playSound('cancelMenu')
            endSong()
        end
    end
end