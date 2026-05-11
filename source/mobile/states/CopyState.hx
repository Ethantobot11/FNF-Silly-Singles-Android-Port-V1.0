package mobile.states;

import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;
import flixel.addons.util.FlxAsyncLoop;
import openfl.utils.ByteArray;
import haxe.io.Path;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import sys.FileSystem;
import sys.io.File;
import haxe.crypto.Md5;
import openfl.system.System;

/**
 * Modified CopyState with Content Validation and RAM Throttling
 * @author: Karim Akra (Modified for Auto-Update & RAM Safety)
 */
class CopyState extends MusicBeatState
{
    private static final textFilesExtensions:Array<String> = ['ini', 'txt', 'xml', 'hxs', 'hx', 'lua', 'json', 'frag', 'vert'];
    public static final IGNORE_FOLDER_FILE_NAME:String = "ignore.txt";
    private static var directoriesToIgnore:Array<String> = [];
    public static var locatedFiles:Array<String> = [];
    public static var maxLoopTimes:Int = 0;
    public var loadingImage:FlxSprite;
    public var loadingBar:FlxBar;
    public var loadedText:FlxText;
    public var copyLoop:FlxAsyncLoop;
	private var _isPaused:Bool = false;
    var failedFilesStack:Array<String> = [];
    var failedFiles:Array<String> = [];
    var shouldCopy:Bool = false;
    var canUpdate:Bool = true;
    var loopTimes:Int = 0; 
    var ramLimit:Float = 1024 * 1024 * 700;
	var isLoopPaused:Bool = false;

    override function create()
    {    
        locatedFiles = [];
        maxLoopTimes = 0;
        checkExistingFiles();
        
        if (maxLoopTimes <= 0)
        {
            MusicBeatState.switchState(new TitleState());
            return;
        }

        CoolUtil.showPopUp("Updating assets and verifying files.\nThis may take a moment depending on your device.", "Update Sync");

        shouldCopy = true;

        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

        loadingImage = new FlxSprite(0, 0, Paths.image('funkay'));
        loadingImage.setGraphicSize(0, FlxG.height);
        loadingImage.updateHitbox();
        loadingImage.screenCenter();
        add(loadingImage);

        loadingBar = new FlxBar(0, FlxG.height - 26, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 26);
        loadingBar.setRange(0, maxLoopTimes);
        add(loadingBar);

        loadedText = new FlxText(loadingBar.x, loadingBar.y + 4, FlxG.width, '', 16);
        loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        add(loadedText);

        copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, 3);
        add(copyLoop);
        copyLoop.start();

        super.create();
    }

	public function pauseCopying():Void {
        _isPaused = true;
        openfl.system.System.gc();
        trace("Copy process manually paused.");
    }

    public function resumeCopying():Void {
        _isPaused = false;
        trace("Copy process manually resumed.");
    }

    override function update(elapsed:Float)
    {
        if (shouldCopy && copyLoop != null)
        {
            var currentMemory:Float = System.totalMemory;
            if (currentMemory > ramLimit || FlxG.drawFramerate < 20) {
                if (!_isPaused) {
                    pauseCopying();
                    _isPaused = true;
                    System.gc(); 
                }
            } else if (_isPaused) {
                resumeCopying();
                _isPaused = false;
            }

            loadingBar.value = loopTimes;
            
            if (copyLoop.finished && canUpdate)
            {
                if (failedFiles.length > 0)
                {
                    CoolUtil.showPopUp(failedFiles.join('\n'), 'Failed To Sync ${failedFiles.length} Files');
                }
                canUpdate = false;
                FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = () -> {
                    MusicBeatState.switchState(new TitleState());
                };
            }

            loadedText.text = (_isPaused ? "Cleaning RAM... " : "Syncing: ") + '$loopTimes/$maxLoopTimes';
        }
        super.update(elapsed);
    }

    public function copyAsset()
    {
        var file = locatedFiles[loopTimes];
        loopTimes++;
        
        var internalPath = getFile(file);
        var shouldUpdate = false;

        if (!FileSystem.exists(file)) {
            shouldUpdate = true;
        } else {
            try {
                var internalBytes = OpenFLAssets.getBytes(internalPath);
                var externalBytes = File.getBytes(file);
                
                if (Md5.encode(internalBytes.toString()) != Md5.encode(externalBytes.toString())) {
                    shouldUpdate = true;
                }
            } catch(e) {
                shouldUpdate = true;
            }
        }

        if (shouldUpdate)
        {
            var directory = Path.directory(file);
            if (!FileSystem.exists(directory))
                StorageUtil.createDirectories(directory);
            
            try
            {
                if (OpenFLAssets.exists(internalPath))
                {
                    if (textFilesExtensions.contains(Path.extension(file)))
                        createContentFromInternal(file);
                    else
                        File.saveBytes(file, getFileBytes(internalPath));
                }
            }
            catch (e:haxe.Exception)
            {
                failedFiles.push('${file} (Error: ${e.message})');
            }
        }
    }

    public function createContentFromInternal(file:String)
    {
        var fileName = Path.withoutDirectory(file);
        var directory = Path.directory(file);
        try
        {
            var fileData:String = OpenFLAssets.getText(getFile(file));
            if (fileData == null) fileData = '';
            File.saveContent(Path.join([directory, fileName]), fileData);
        }
        catch (e:haxe.Exception) {}
    }

    public function getFileBytes(file:String):ByteArray
    {
        switch (Path.extension(file).toLowerCase())
        {
            case 'otf' | 'ttf': return ByteArray.fromFile(file);
            default: return OpenFLAssets.getBytes(file);
        }
    }

    public static function getFile(file:String):String
    {
        if (OpenFLAssets.exists(file)) return file;
        @:privateAccess
        for (library in LimeAssets.libraries.keys())
        {
            if (OpenFLAssets.exists('$library:$file') && library != 'default')
                return '$library:$file';
        }
        return file;
    }

    public static function checkExistingFiles():Bool
    {
        var fullList:Array<String> = OpenFLAssets.list();
        
        locatedFiles = fullList.filter(f -> f.startsWith('assets/') || f.startsWith('mods/') || f.startsWith('modpack/'));

        var filesToRemove:Array<String> = [];
        for (file in locatedFiles)
        {
            if (file.endsWith(IGNORE_FOLDER_FILE_NAME))
                directoriesToIgnore.push(Path.directory(file));

            for (directory in directoriesToIgnore)
            {
                if (file.startsWith(directory))
                    filesToRemove.push(file);
            }
        }

        locatedFiles = locatedFiles.filter(file -> !filesToRemove.contains(file));
        maxLoopTimes = locatedFiles.length;

        return (maxLoopTimes <= 0);
    }
}