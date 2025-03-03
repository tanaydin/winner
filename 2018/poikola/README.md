## To build:

``` <!---sh-->
    make
```


## To use:

``` <!---sh-->
    ./prog
```


## Try:

On a terminal that supports 24 bit color, has black background, and size at
least 125x38, try:

``` <!---sh-->
    ./try.sh
```


## Judges' remarks:

It is said by some students of Astronomy:

> Oh, Be A Fine Gal, Kiss Me!<br>
> Oh, Be A Fine Gentleman, Kiss Me!

Many [Mnemonic variations](http://www.star.ucl.ac.uk/%7Epac/obafgkmrns.html) exist.
You might wish, on a star, to better understand the colors being displayed.
And those in the deep south might wish to go north for a better view.


## Author's remarks:

### How to build:

``` <!---sh-->
    cc -o prog -std=gnu11 -O3 prog.c
```

or

``` <!---sh-->
    make
```

### Poster:

You can generate an A3 sized poster by _make docs_. This command creates a pdf
file _poikola.pdf_.


### Introduction:

It was a starry night when my wife pointed her finger up and asked: "What is
this star and may I have some Easter eggs?"

So I had to sit down and solve those tricky questions with Nano and a C
compiler.


### NOTICE to those who wish for a greater challenge:

**If you want a greater challenge, don't read any further**:
just try to understand the program via the source.

If you get stuck, come back and read below for additional hints and information.


### Little hints:

Basically, the program draws animated ASCII art of the Big Dipper using Annie
Jump Cannon's spectral classification system of stars and I think the colors of
the output are as accurate as possible.

This program also tells once in a year if it is correct time to find and eat
some Easter eggs.

The program has also at least three other functions, obvious and not so obvious.


### Technical jargon

This program has been tested on xterm and Konsole and also Linux virtual
terminal. Color support in the terminal is not necessary, but the effect is
better with it.

This entry has partial support for terminals with a white background but the
best viewing experience is achieved when the terminal in use supports 24-bit
colors, has a black background and the size is at least 125x38.

Special note for Mac users: `Terminal.app` does not work as expected; you might
need xterm from XQuartz, see the
FAQ on "[X11 on macOS](../../faq.html#X11macos)",
or some other working
terminal. Thanks to [Dave Burton](../../authors.html#Dave_Burton) for spotting this
problem.

The main reason for the header `unistd.h` is `getdelim(3)` but once I included it
I also abused other functions and `#define`s. This header is mutually exclusive
with `-std=c11`.

The program was developed with little-endian machines; I tried to support
big-endian too, but this support is somewhat limited.

This program has been compiled with:

1. i386 (Debian Stretch) with gcc and clang
2. amd64 (Debian Buster) with gcc and clang
3. Raspberry Pi 3 (Debian stretch) with gcc and clang
4. Lego Mindstorms EV3 Intelligent Brick (Debian Jessie) with gcc and clang (in
this case, compiling time with clang-3.5 12 seconds and with gcc 27 seconds)


### Extra notes from the judges on the macOS Terminal.app problems:

Depending on the settings of the terminal in Terminal.app the program might not
show anything at all. In other cases it won't show all the colours right but
mostly is okay. YMMV, as they say.


### Warnings and restrictions required by law:

Please do not feed little babies chocolate.


### Major hints:

I incorporated the [Fletcher 16 checksum
algorithm](https://en.wikipedia.org/wiki/Fletcher%27s_checksum) into the source
for security reasons; it might be challenging to make changes without breaking
the main functionality of the code.

The space after `#define p return` is necessary.

The computus (method to determine the date of Easter) uses an algorithm
described in the journal Nature in 1876. It should be valid for Gregorian
calendars.


### Some obfuscation techniques used:

1. I tried to use meaningless or misleading variable names. For example, this
program draws the Big Dipper with the correct colors, but variables like `o`,
`b`, and `a` are used in totally unrelated tasks.
2. I reused and recycled variables almost every time when possible.
3. Unnecessary use of predefined stuff like `__ATOMIC_SEQ_CST`.
4. When I was a kid, my favorite programming language was Pascal. In Pascal,
there are things like `begin;` and `end;` instead of curly brackets. They are
used also in my code, but I had to shorten them to meet size requirements.
5. I also have strong Perl background, and therefore I added some dollar signs
to the code. One of the first ideas was to write all variables with prefixed
`$`, but then I rejected it.

If you think you understand how this program works, can you answer these
questions:

1. What is the value of `aI_` after line 21?
2. Why are there some big numbers on line 47?
3. How is the scaling effect created?
4. How do you change a single bit, without changing the functionality?


### Rot18 part

Because the rot13 is too easy to decode with the plain eyes, I decided to use
the [Caesar cipher](https://en.wikipedia.org/wiki/Caesar_cipher) with the key
18:

> Lzw xajkl tsffwj ak wfugvwv mkafy AWWW 754 xdgslk gf dafw 47. Al ak hjaflwv
gfdq gf dalldw-wfvasf esuzafwk.

If you want to or must know and don't know how to decipher this, you might look
at the [Caesar cipher decoder](https://www.dcode.fr/caesar-cipher). Find the
text that says:

> Manual decryption and parameters Shift/Key (number)

.. and enter 18 and then click the button that says: `DECRYPT (BRUTEFORCE)`.

<!--

    Copyright © 1984-2024 by Landon Curt Noll. All Rights Reserved.

    You are free to share and adapt this file under the terms of this license:

        Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

    For more information, see:

        https://creativecommons.org/licenses/by-sa/4.0/

-->
