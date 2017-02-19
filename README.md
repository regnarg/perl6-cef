This is a simple experiment on using the [Chromium Embedded Framework
(CEF)][cef] from [Perl 6][p6] using [NativeCall][nc]. Currently it just
initializes the browser and displays an empty page.

The end goal is a [Chromium][]-based keyboard-oriented browser (like
[Vimperator][vimp], [Luakit][] or [uzbl][]) scriptable with Perl 6.  This could
combine the security of Chromium (sandboxing, process separation etc.) with the
configurability of Vimperator-like browsers.

[cef]: https://bitbucket.org/chromiumembedded/cef
[nc]: https://docs.perl6.org/language/nativecall
[vimp]: http://www.vimperator.org/
[luakit]: https://luakit.github.io/luakit/
[uzbl]: https://www.uzbl.org/
[chromium]: https://www.chromium.org/
[p6]: https://perl6.org/

## Usage

  * Download CEF binary build from
    http://opensource.spotify.com/cefbuilds/index.html (tested with version
    3.2924.1570.g558741c). Currently only Linux 64-bit builds are supported.
    You could probably get it to work on 32b by replacing `[u]int64` with
    `[u]int32` at the right places according to the C structure definitions
    but I have not tested that.
  * Copy (or symlink) everything from `Release` (or `Debug`) and `Resources`
    directories to the directory of this script.
  * Build `libfakexe.so` using `make`. This is a `LD_PRELOAD` library
    that fakes the `/proc/self/exe` symlink to point to the Perl script
    instead of the interpreter executable. This is done because Chromium
    looks for data files in the executable directory and we do not want
    to copy everything to `/usr/bin` or wherever you Perl binaries are.
  * Run

        env LD_LIBRARY_PATH=. LD_PRELOAD=$PWD/libfakexe.so FAKEXE_ORIG=/usr/bin/moar FAKEXE_REPL=$PWD/cef-test.p6 $PWD/cef-test.p6

    (you might have to adjust the path to your MoarVM executable in `FAKEXE_ORIG`, e.g. `/usr/local/bin/moar`
    for a self-compiled Rakudo).
  * This currently open a white window that doesn't do anything. But it's
    a workable basis for future experiments.
