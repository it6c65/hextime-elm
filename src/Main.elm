module Main exposing (..)

--
-- Show the current time in Hexadecimals
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
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


toHex : String -> String
toHex time =
    if (String.toInt (time) |> Maybe.withDefault 0) < 10 then
        "0" ++ time
    else
        time

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
                "#" ++ (toHex hour) ++ (toHex minute) ++ (toHex second)
    in
    [ div
        [ style "background-color" hexcolor
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "max-height" "fit-content"
        ]
        [ h1 [] [ text ( ( toHex hour ) ++ ":" ++ ( toHex minute ) ++ ":" ++ ( toHex second )) ]
        , h2 [] [ text hexcolor ]
        ]
    ]
