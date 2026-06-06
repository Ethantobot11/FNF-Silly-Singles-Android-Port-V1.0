package;

import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;
import flash.media.Sound;

using StringTools;

class Paths
{
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
    inline public static var VIDEO_EXT = "mp4";

    #if MODS_ALLOWED
    public static var ignoreModFolders:Array<String> = [
        'characters',
        'custom_events',
        'custom_notetypes',
        'data',
        'songs',
        'music',
        'sounds',
        'shaders',
        'videos',
        'images',
        'stages',
        'weeks',
        'fonts',
        'scripts',
        'achievements'
    ];
    #end

    public static function excludeAsset(key:String) {
        if (!dumpExclusions.contains(key))
            dumpExclusions.push(key);
    }

    public static var dumpExclusions:Array<String> =
    [
        'assets/music/freakyMenu.$SOUND_EXT',
        'assets/shared/music/breakfast.$SOUND_EXT',
        'assets/shared/music/tea-time.$SOUND_EXT',
    ];
    
    public static function clearUnusedMemory() {
        for (key in currentTrackedAssets.keys()) {
            if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
                var obj = currentTrackedAssets.get(key);
                @:privateAccess
                if (obj != null) {
                    openfl.Assets.cache.removeBitmapData(key);
                    FlxG.bitmap._cache.remove(key);
                    obj.destroy();
                    currentTrackedAssets.remove(key);
                }
            }
        }
        System.gc();
    }

    public static var localTrackedAssets:Array<String> = [];
    public static function clearStoredMemory(?cleanUnused:Bool = false) {
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
            var obj = FlxG.bitmap._cache.get(key);
            if (obj != null && !currentTrackedAssets.exists(key)) {
                openfl.Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                obj.destroy();
            }
        }

        for (key in currentTrackedSounds.keys()) {
            if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null) {
                Assets.cache.clear(key);
                currentTrackedSounds.remove(key);
            }
        }
        localTrackedAssets = [];
        openfl.Assets.cache.clear("songs");
    }

    static public var currentModDirectory:String = '';
    static public var currentLevel:String;
    static public function setCurrentLevel(name:String)
    {
        currentLevel = name.toLowerCase();
    }

    public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
    {
        if (library != null)
            return getLibraryPath(file, library);

        if (currentLevel != null)
        {
            var levelPath:String = '';
            if(currentLevel != 'shared') {
                levelPath = getLibraryPathForce(file, currentLevel);
                if (funk.FunkinFileSystem.exists(levelPath))
                    return levelPath;
            }

            levelPath = getLibraryPathForce(file, "shared");
            if (funk.FunkinFileSystem.exists(levelPath))
                return levelPath;
        }

        return getPreloadPath(file);
    }

    static public function getLibraryPath(file:String, library = "preload")
    {
        return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
    }

    inline static function getLibraryPathForce(file:String, library:String)
    {
        var returnPath = '$library:assets/$library/$file';
        return returnPath;
    }

    inline public static function getPreloadPath(file:String = '')
    {
        return 'assets/$file';
    }

    inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
    {
        return getPath(file, type, library);
    }

    inline static public function txt(key:String, ?library:String)
    {
        return getPath('data/$key.txt', TEXT, library);
    }

    inline static public function xml(key:String, ?library:String)
    {
        return getPath('data/$key.xml', TEXT, library);
    }

    inline static public function json(key:String, ?library:String)
    {
        return getPath('data/$key.json', TEXT, library);
    }

    inline static public function shaderFragment(key:String, ?library:String)
    {
        return getPath('shaders/$key.frag', TEXT, library);
    }
    inline static public function shaderVertex(key:String, ?library:String)
    {
        return getPath('shaders/$key.vert', TEXT, library);
    }
    inline static public function lua(key:String, ?library:String)
    {
        return getPath('$key.lua', TEXT, library);
    }

    static public function video(key:String)
    {
        #if MODS_ALLOWED
        var file:String = modsVideo(key);
        if(funk.FunkinFileSystem.exists(file)) {
            return file;
        }
        #end
        return 'assets/videos/$key.$VIDEO_EXT';
    }

    static public function sound(key:String, ?library:String):Sound
    {
        var sound:Sound = returnSound('sounds', key, library);
        return sound;
    }

    inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
    {
        return sound(key + FlxG.random.int(min, max), library);
    }

    inline static public function music(key:String, ?library:String):Sound
    {
        var file:Sound = returnSound('music', key, library);
        return file;
    }

    inline static public function voices(song:String):Any
    {
        var songKey:String = '${formatToSongPath(song)}/Voices';
        #if !NEW_PSYCH063
        var voices = returnSound('songs', songKey);
        #else
        var voices = returnSound(null, songKey, 'songs');
        #end
        return voices;
    }

    inline static public function inst(song:String):Any
    {
        var songKey:String = '${formatToSongPath(song)}/Inst';
        #if !NEW_PSYCH063
        var inst = returnSound('songs', songKey);
        #else
        var inst = returnSound(null, songKey, 'songs');
        #end
        return inst;
    }

    inline static public function image(key:String, ?library:String):FlxGraphic
    {
        var returnAsset:FlxGraphic = returnGraphic(key, library);
        return returnAsset;
    }

    static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
    {
        #if MODS_ALLOWED
        if (!ignoreMods && funk.FunkinFileSystem.exists(modFolders(key)))
            return funk.FunkinFileSystem.getText(modFolders(key));
        #end

        if (funk.FunkinFileSystem.exists(getPreloadPath(key)))
            return funk.FunkinFileSystem.getText(getPreloadPath(key));

        if (currentLevel != null)
        {
            var levelPath:String = '';
            if(currentLevel != 'shared') {
                levelPath = getLibraryPathForce(key, currentLevel);
                if (funk.FunkinFileSystem.exists(levelPath))
                    return funk.FunkinFileSystem.getText(levelPath);
            }

            levelPath = getLibraryPathForce(key, 'shared');
            if (funk.FunkinFileSystem.exists(levelPath))
                return funk.FunkinFileSystem.getText(levelPath);
        }
        return funk.FunkinFileSystem.getText(getPath(key, TEXT));
    }

    inline static public function font(key:String)
    {
        #if MODS_ALLOWED
        var file:String = modsFont(key);
        if(funk.FunkinFileSystem.exists(file)) {
            return file;
        }
        #end
        return 'assets/fonts/$key';
    }

    inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
    {
        #if MODS_ALLOWED
        if(funk.FunkinFileSystem.exists(mods(currentModDirectory + '/' + key)) || funk.FunkinFileSystem.exists(mods(key))) {
            return true;
        }
        #if (android || linux || ios)
        if (funk.FunkinFileSystem.exists(findFile(key)))
            return true;
        #end
        #end

        if(funk.FunkinFileSystem.exists(getPath(key, type))) {
            return true;
        }
        return false;
    }
    
    inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
    {
        #if MODS_ALLOWED
        var imageLoaded:FlxGraphic = returnGraphic(key);
        var xmlExists:Bool = false;

        var xml:String = modsXml(key);
        if(funk.FunkinFileSystem.exists(xml)) {
            xmlExists = true;
        }

        var getXml = file('images/$key.xml', library);
        if (xmlExists)
            getXml = funk.FunkinFileSystem.getText(xml)
        else if(!Paths.fileExists('images/$key.xml', TEXT, false, library))
            getXml = file('$key.xml', library);

        return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), getXml);
        #else
        return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
        #end
    }

    inline static public function getPackerAtlas(key:String, ?library:String)
    {
        #if MODS_ALLOWED
        var imageLoaded:FlxGraphic = returnGraphic(key);
        var txtExists:Bool = false;
        if(funk.FunkinFileSystem.exists(modsTxt(key))) {
            txtExists = true;
        }

        return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? funk.FunkinFileSystem.getText(modsTxt(key)) : file('images/$key.txt', library)));
        #else
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
        #end
    }

    inline static public function formatToSongPath(path:String) {
        var invalidChars = ~/[~&\\;:<>#]/;
        var hideChars = ~/[.,'"%?!]/;

        var path = invalidChars.split(path.replace(' ', '-')).join("-");
        return hideChars.split(path).join("").toLowerCase();
    }

    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static function returnGraphic(key:String, ?library:String) {
        #if MODS_ALLOWED
        var modKey:String = modsImages(key);
        if(funk.FunkinFileSystem.exists(modKey)) {
            if(!currentTrackedAssets.exists(modKey)) {
                var newBitmap:BitmapData = funk.FunkinFileSystem.getBitmapData(modKey);

                if (newBitmap != null) {
                    var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modKey);
                    newGraphic.persist = true;
                    currentTrackedAssets.set(modKey, newGraphic);
                }
            }
            localTrackedAssets.push(modKey);
            return currentTrackedAssets.get(modKey);
        }
        #end

        #if USING_GPU_TEXTURES
        var path = getPath('images/$key.astc', IMAGE, library);
        var normalPath = getPath('$key.astc', IMAGE, library);
        if (!funk.FunkinFileSystem.exists(path) && !funk.FunkinFileSystem.exists(normalPath)) {
            path = getPath('images/$key.png', IMAGE, library);
            normalPath = getPath('$key.png', IMAGE, library);
        }
        #else
        var path = getPath('images/$key.png', IMAGE, library);
        var normalPath = getPath('$key.png', IMAGE, library);
        #end

        if (funk.FunkinFileSystem.exists(path)) {
            if(!currentTrackedAssets.exists(path)) {
                var newGraphic:FlxGraphic = null;
                
                var newBitmap = funk.FunkinFileSystem.getBitmapData(path);
                if (newBitmap != null) {
                    newGraphic = FlxGraphic.fromBitmapData(newBitmap, false, path);
                }

                if (newGraphic != null) {
                    newGraphic.persist = true;
                    currentTrackedAssets.set(path, newGraphic);
                }
            }
            localTrackedAssets.push(path);
            return currentTrackedAssets.get(path);
        }
        else if (funk.FunkinFileSystem.exists(normalPath)) {
            if(!currentTrackedAssets.exists(normalPath)) {
                var newGraphic:FlxGraphic = null;

                var newBitmap = funk.FunkinFileSystem.getBitmapData(normalPath);
                if (newBitmap != null) {
                    newGraphic = FlxGraphic.fromBitmapData(newBitmap, false, normalPath);
                }

                if (newGraphic != null) {
                    newGraphic.persist = true;
                    currentTrackedAssets.set(normalPath, newGraphic);
                }
            }
            localTrackedAssets.push(normalPath);
            return currentTrackedAssets.get(normalPath);
        }
        trace('oh no its returning null NOOOO');
        return null;
    }

    public static var currentTrackedSounds:Map<String, Sound> = [];
    public static function returnSound(path:Null<String>, key:String, ?library:String) {
        #if NEW_PSYCH063
        #if MODS_ALLOWED
        var modLibPath:String = '';
        if (library != null) modLibPath = '$library/';
        if (path != null) modLibPath += '$path';

        var file:String = modsSounds(modLibPath, key);
        if(funk.FunkinFileSystem.exists(file)) {
            if(!currentTrackedSounds.exists(file))
                currentTrackedSounds.set(file, funk.FunkinFileSystem.getSound(file));
            localTrackedAssets.push(file);
            return currentTrackedSounds.get(file);
        }
        #end

        var gottenPath:String = '$key.$SOUND_EXT';
        if(path != null) gottenPath = '$path/$gottenPath';
        gottenPath = getPath(gottenPath, SOUND, library);
        gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
        if(!currentTrackedSounds.exists(gottenPath))
        {
            var retKey:String = (path != null) ? '$path/$key' : key;
            retKey = ((path == 'songs') ? 'songs:' : '') + getPath('$retKey.$SOUND_EXT', SOUND, library);
            if(funk.FunkinFileSystem.exists(retKey))
                currentTrackedSounds.set(gottenPath, funk.FunkinFileSystem.getSound(retKey));
        }
        localTrackedAssets.push(gottenPath);
        return currentTrackedSounds.get(gottenPath);
        #else
        #if MODS_ALLOWED
        var file:String = modsSounds(path, key);
        if(funk.FunkinFileSystem.exists(file)) {
            if(!currentTrackedSounds.exists(file)) {
                currentTrackedSounds.set(file, funk.FunkinFileSystem.getSound(file));
            }
            localTrackedAssets.push(key);
            return currentTrackedSounds.get(file);
        }
        #end
        var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
        gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
        if(!currentTrackedSounds.exists(gottenPath)) {
            if(funk.FunkinFileSystem.exists(gottenPath)) {
                currentTrackedSounds.set(gottenPath, funk.FunkinFileSystem.getSound(gottenPath));
            }
        }
        localTrackedAssets.push(gottenPath);
        return currentTrackedSounds.get(gottenPath);
        #end
    }

    #if MODS_ALLOWED
    inline static public function mods(key:String = '') {
        return if (ClientPrefs.Modpack) #if mobile Sys.getCwd() + #end 'modpack/' + key; else #if mobile Sys.getCwd() + #end 'mods/' + key;
    }

    inline static public function modsFont(key:String) {
        return modFolders('fonts/' + key);
    }

    inline static public function modsJson(key:String) {
        return modFolders('data/' + key + '.json');
    }

    inline static public function modsVideo(key:String) {
        return modFolders('videos/' + key + '.' + VIDEO_EXT);
    }

    inline static public function modsSounds(path:String, key:String) {
        return modFolders(path + '/' + key + '.' + SOUND_EXT);
    }

    inline static public function modsImages(key:String) {
        #if USING_GPU_TEXTURES
        return modFolders('images/' + key + '.astc');
        #else
        return modFolders('images/' + key + '.png');
        #end
    }

    inline static public function modsXml(key:String) {
        return modFolders('images/' + key + '.xml');
    }

    inline static public function modsTxt(key:String) {
        return modFolders('images/' + key + '.txt');
    }

    static public function modFolders(key:String) {
        if(currentModDirectory != null && currentModDirectory.length > 0) {
            var fileToCheck:String = mods(currentModDirectory + '/' + key);
            if(funk.FunkinFileSystem.exists(fileToCheck)) {
                return fileToCheck;
            }
            #if (linux || android || ios)
            else
            {
                var newPath:String = findFile(key);
                if (newPath != null)
                    return newPath;
            }
            #end
        }

        for(mod in getGlobalMods()){
            var fileToCheck:String = mods(mod + '/' + key);
            if(funk.FunkinFileSystem.exists(fileToCheck))
                return fileToCheck;
            #if (linux || android || ios)
            else
            {
                var newPath:String = findFile(key);
                if (newPath != null)
                    return newPath;
            }
            #end
        }
        return if (ClientPrefs.Modpack) #if mobile Sys.getCwd() + #end 'modpack/' + key; else #if mobile Sys.getCwd() + #end 'mods/' + key;
    }

    #if (android || linux || ios)
    static function findFile(key:String):String {
        var targetParts:Array<String> = key.replace('\\', '/').split('/');
        if (targetParts.length == 0) return null;

        var baseDir:String = targetParts.shift();
        var searchDirs:Array<String> = [
            mods(Paths.currentModDirectory + '/' + baseDir),
            mods(baseDir)
        ];

        for (part in targetParts) {
            if (part == '') continue;

            var nextDir:String = findNodeInDirs(searchDirs, part);
            if (nextDir == null) {
                return null;
            }

            searchDirs = [nextDir];
        }

        return searchDirs[0];
    }

    static function findNodeInDirs(dirs:Array<String>, key:String):String {
        for (dir in dirs) {
            var node:String = findNode(dir, key);
            if (node != null) {
                return dir + '/' + node;
            }
        }
        return null;
    }

    static function findNode(dir:String, key:String):String {
        try {
            var allFiles:Array<String> = Paths.readDirectory(dir);
            var fileMap:Map<String, String> = new Map();

            for (file in allFiles) {
                fileMap.set(file.toLowerCase(), file);
            }

            return fileMap.get(key.toLowerCase());
        } catch (e:Dynamic) {
            return null;
        }
    }
    #end

    public static var globalMods:Array<String> = [];
    static public function getGlobalMods()
        return globalMods;

    static public function pushGlobalMods() 
    {
        globalMods = [];
        var path:String = 'modsList.txt';
        if(funk.FunkinFileSystem.exists(path))
        {
            var list:Array<String> = CoolUtil.coolTextFile(path);
            for (i in list)
            {
                var dat = i.split("|");
                if (dat[1] == "1")
                {
                    var folder = dat[0];
                    var path = Paths.mods(folder + '/pack.json');
                    if(funk.FunkinFileSystem.exists(path)) {
                        try{
                            var rawJson:String = funk.FunkinFileSystem.getText(path);
                            if(rawJson != null && rawJson.length > 0) {
                                var stuff:Dynamic = Json.parse(rawJson);
                                var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
                                if(global)globalMods.push(dat[0]);
                            }
                        } catch(e:Dynamic){
                            trace(e);
                        }
                    }
                }
            }
        }
        return globalMods;
    }

    static public function getModDirectories():Array<String> {
        var list:Array<String> = [];
        var modsFolder:String = mods();
        if(funk.FunkinFileSystem.exists(modsFolder)) {
            for (folder in funk.FunkinFileSystem.readDirectory(modsFolder)) {
                var path = haxe.io.Path.join([modsFolder, folder]);
                if (funk.FunkinFileSystem.fromLime(path, true) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
                    list.push(folder);
                }
            }
        }
        return list;
    }
    #end
    
    public static function readDirectory(directory:String):Array<String>
    {
        return funk.FunkinFileSystem.readDirectory(directory);
    }
}