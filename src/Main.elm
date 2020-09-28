module Main exposing (main)

--
-- Show the current time in Hexadecimals
--

import Browser
import Html exposing (Html, a, br, div, footer, h1, text)
import Html.Attributes exposing (class, href, style)
import Task
import Time



-- MAIN


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0)
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick


addLeftZero : String -> String
addLeftZero time =
    if (String.toInt time |> Maybe.withDefault 0) < 10 then
        "0" ++ time

    else
        time


toHex : String -> String -> String -> String
toHex hour minute second =
    "#" ++ addLeftZero hour ++ addLeftZero minute ++ addLeftZero second



-- VIEW


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Hex Time"
        (display model)


display : Model -> List (Html Msg)
display model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)

        minute =
            String.fromInt (Time.toMinute model.zone model.time)

        second =
            String.fromInt (Time.toSecond model.zone model.time)

        hexcolor =
            toHex hour minute second
    in
    [ div
        [ class "page"
        , style "background-color" hexcolor
        ]
        [ h1 [] [ text hexcolor ]
        , footer [ class "description" ]
            [ text "Made by "
            , a [ href "https://github.com/it6c65" ] [ text "Luis Ilarraza" ]
            , br [] []
            , text "This is the "
            , a [ href "https://elm-lang.org" ] [ text "Elm version" ]
            , text " of the "
            , a [ href "https://github.com/JamelHammoud/hextime" ] [ text "HexTime" ]
            , br [] []
            , a [ href "https://github.com/it6c65/hextime-elm" ] [ text "CODE HERE" ]
            ]
        ]
    ]
