package samples.src;

import samples.shared.Helper;

class Main
{
    static function main()
    {
        trace("[SCons] TEST CODE - src");
        trace("Hello from compiled exe!");

        trace("[SCons] TEST CODE - shared");
        trace(Helper.greet());

        var data = haxe.Resource.getBytes("assets/icon.png");
    }
}