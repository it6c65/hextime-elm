module Main exposing (main)

--
-- Show the current time in Hexadecimals
--

import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, br, div, footer, h1, text)
import Html.Attributes exposing (class, href, style)
import Http
import Json.Decode as JD
import Task
import Time
import Url.Builder as UB



-- MAIN


main : Program () Model Msg
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
    , backgroundImage : Maybe UrlAddress
    , color : Maybe Color
    }


type alias Color =
    { red : String
    , green : String
    , blue : String
    , hex : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) Nothing Nothing
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | GetBackground (Result Http.Error UrlAddress)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            let
                currentColor =
                    defineColor model.color

                newColor =
                    changeRed model currentColor
                        |> changeGreen model
                        |> changeBlue model
                        |> toHex

                newColorUrl =
                    defineColor newColor

                finalUrl =
                    UB.crossOrigin "https://php-noise.com" [ "noise.php" ] [ UB.string "hex" (String.dropLeft 1 newColorUrl.hex), UB.string "json" "" ]
            in
            ( { model
                | time = newTime
                , color = newColor
              }
            , fetchBackground finalUrl
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        GetBackground bg ->
            ( { model | backgroundImage = Result.toMaybe bg }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- Helper Functions


addLeftZero : String -> String
addLeftZero time =
    if (String.toInt time |> Maybe.withDefault 0) < 10 then
        "0" ++ time

    else
        time


changeRed : Model -> Color -> Color
changeRed model currentColor =
    { currentColor | red = addLeftZero (String.fromInt (Time.toHour model.zone model.time)) }


changeGreen : Model -> Color -> Color
changeGreen model currentColor =
    { currentColor | green = addLeftZero (String.fromInt (Time.toMinute model.zone model.time)) }


changeBlue : Model -> Color -> Color
changeBlue model currentColor =
    { currentColor | blue = addLeftZero (String.fromInt (Time.toSecond model.zone model.time)) }


toHex : Color -> Maybe Color
toHex currentColor =
    Just { currentColor | hex = "#" ++ currentColor.red ++ currentColor.green ++ currentColor.blue }


emptyColor : Color
emptyColor =
    Color "" "" "" "#000000"


defineColor : Maybe Color -> Color
defineColor color =
    case color of
        Just colorDefined ->
            colorDefined

        Nothing ->
            emptyColor


viewBackgroundImage : Maybe UrlAddress -> Html.Attribute Msg
viewBackgroundImage bgUrl =
    case bgUrl of
        Just bg ->
            let
                address_image =
                    "url(" ++ bg.uri ++ ")"
            in
            style "background-image" address_image

        Nothing ->
            style "background-image" "none"



-- VIEW


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Hex Time"
        (display model)


display : Model -> List (Html Msg)
display model =
    let
        currentColor =
            defineColor model.color

        hexcolor =
            currentColor.hex
    in
    [ div
        [ class "page"
        , style "background-color" hexcolor
        , viewBackgroundImage model.backgroundImage
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
            , text "Now integrated with "
            , a [ href "https://php-noise.com" ] [ text "Noise" ]
            , br [] []
            , a [ href "https://github.com/it6c65/hextime-elm" ] [ text "CODE HERE" ]
            ]
        ]
    ]



-- Fetch backgrounds from Api


type alias UrlAddress =
    { uri : String
    }


bgUrlDecoder : JD.Decoder UrlAddress
bgUrlDecoder =
    JD.map UrlAddress (JD.field "uri" JD.string)


fetchBackground : String -> Cmd Msg
fetchBackground address =
    Http.get
        { url = address
        , expect = Http.expectJson GetBackground bgUrlDecoder
        }
