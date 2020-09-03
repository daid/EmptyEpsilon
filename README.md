![EmptyEpsilon logo](https://raw.githubusercontent.com/daid/EmptyEpsilon/master/resources/logo_full.png)

Started as a cross-platform, open-source "clone" of [Artemis Spaceship Bridge Simulator](http://artemis.eochu.com/), **EmptyEpsilon** has already deviated from Artemis with new features and gameplay, including a Game Master mode and multiple AI factions. We strive to get EmptyEpsilon working on all major platforms (Windows, Linux, and OS X), but only Windows support is guaranteed.

The game is written in C++ with the [SeriousProton](https://github.com/daid/SeriousProton) engine and uses [SFML](http://www.sfml-dev.org/) for most of the heavy lifting.

Contributing
===========

If there is anyone willing to contribute, we're mostly looking for awesome models, sound effects, and music. The game is tested regulary by some of our trusty colleagues.

Some general contribution rules:

1.  This project is a dictatorship. Yes, it's open source, but we'd much rather spend time on building what we like than arguing with people.

2.  Be precise when filing issues. Explain why you posted the issue, what you expect, what is happening, why is your feature worth the time to develop it, what operating system is affected, etc. Unclear issues are subject to rule 1 with extreme prejudice.

3.  Despite the above two, we very much value input, feedback, and suggestions from people playing EmptyEpsilon. If you have ideas or want to donate beer, drop us a line.

### Donations

If you don't have the skills to help code or create models but want to give something back, you can always donate a bit. All donations go directly toward buying better assets for the game (in this case, more and better 3D models). You can find the instructions at <http://daid.github.io/EmptyEpsilon/>.

### Coding

If you are a coder and want to contribute, there are a few things to take into account.

1.  The code is a undocumented mess at this point. We're working on fixing that.

2.  We use the following conventions:

    -   Member values use underscores to separate words (`zoom_level`).
    -   Classes use HighCamelCase (`GuiSlider`).
    -   Functions use lowCamelCase (`getZoomLevel`).

3.  Use a single pull request to change a single thing. Want to change multiple things? File multiple requests.

### Art

There is no clear goal where this game is going. This means that there is no formal game, art, or asset design. If you have something that you would like to see in this game (or want to make something), drop us a line. We'd love to see what you can do and how you can help improve the game.


## Building

See https://github.com/daid/EmptyEpsilon/wiki/Build
