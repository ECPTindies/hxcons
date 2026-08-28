package samples.window.src;


@:include("SDL.h")
@:native("SDL_Window")
extern class SDLWindow {}

@:include("SDL.h")
extern class SDL
{
    @:native("SDL_Init")
    public static function init(flags:Int):Int;

    @:native("SDL_Quit")
    public static function quit():Void;

    @:native("SDL_GetError")
    public static function getError():cpp.ConstCharStar;

    @:native("SDL_CreateWindow")
    public static function createWindow(title:cpp.ConstCharStar, x:Int, y:Int, w:Int, h:Int, flags:Int):cpp.RawPointer<SDLWindow>;

    @:native("SDL_DestroyWindow")
    public static function destroyWindow(window:cpp.RawPointer<SDLWindow>):Void;

    @:native("SDL_Delay")
    public static function delay(ms:Int):Void;
}

class SDLFlags
{
    public static inline var INIT_VIDEO:Int = 0x00000020;
    public static inline var WINDOW_SHOWN:Int = 0x00000004;
    public static inline var WINDOWPOS_CENTERED:Int = 0x2FFF0000;
}