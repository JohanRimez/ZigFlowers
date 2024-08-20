ZigFlowers
Johan Rimez - 2024

This is an open source project featuring:
* ZIG programming language (www.ziglang.org)
* SDL2 - Simple DirectMedia Layer (www.libsdl.org)

This program is intended to demonstrate graphics programming for a simple but fully working coding example using ZIG & SDL.

The original idea for the program came from this coding tutorial:

Patt Vira - "Hypnotic Flowers"
https://www.pattvira.com/coding-tutorials/v/hypnotic-flowers

USAGE:

<SPACE> changes the way the flowers turn (cycle of 4 modes)
<any other key> quits the application

COMPILING:

The interested coders would immediate find out that the native system wherefor this application is developed is WindowsOS.
They are invited to adapt the necessary include links (headers & libraries) to their specific installation.
For WindowOS: running the executable works best with the SDL2.dll library in the same directory as the executable.
For Linux: package "libsdl2-dev" should already be installed as a prerequisite.

REMARK:

I used the "Software Renderer" to interact with the Surfaces to easily implement the XOR - blending. I know it's a strech on CPU usage,
but I simply can't find any decent equivalent with the hardware accelerated renderer (acting on Textures). If anybody has a found a better alternative,
please notify!

Kind regards
Johan*

