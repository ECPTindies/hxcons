package samples.window.src;

import samples.window.shared.Helper;
import samples.window.src.SDL;
import samples.window.src.SDL.SDLFlags;

class Main
{
    static function main()
    {
        trace("Initializing SDL2...");

        if (SDL.init(SDLFlags.INIT_VIDEO) != 0)
        {
            trace("SDL_Init failed: " + SDL.getError());
            Sys.exit(1);
        }

        trace("Creating window...");

        var window = SDL.createWindow(
            "hxcons SDL2 Test",
            SDLFlags.WINDOWPOS_CENTERED,
            SDLFlags.WINDOWPOS_CENTERED,
            1280, 720,
            SDLFlags.WINDOW_SHOWN
        );

        if (window == null)
        {
            trace("SDL_CreateWindow failed: " + SDL.getError());
            SDL.quit();
            Sys.exit(1);
        }

        trace("Window created. Staying open for 3 seconds...");
        SDL.delay(3000);

        trace("Destroying window...");
        SDL.destroyWindow(window);
        SDL.quit();

        trace("Done.");
    }
}