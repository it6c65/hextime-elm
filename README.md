# An elm version of the RGB's clock that takes advantage of hexadecimal colors
I saw this project implemented in JS by [Jamel](https://github.com/JamelHammoud/hextime), where the time is represented like colors in the background in live time, so I realized that is a good project for practice some code and I wanted to make an elm version of that code.

with this simple project is easier to compare JS with Elm, since I use the standard library in Elm.

It's notable that Elm is more verbose (132 LoC) vs JS version (6 LoC), but there is have in account that the JS version use the HTML DOM directly while Elm needs to create it, but yet taking that Elm keep to being larger, although for me the code is a lot of readable that JS version.

This a good didactic between both languages, besides, the logic that how works the time in Elm is something large and it's better explained in this [guide](https://guide.elm-lang.org/effects/time.html)
