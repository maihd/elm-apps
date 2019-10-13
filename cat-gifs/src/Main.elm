import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)

import Types exposing (..)
import Giphy exposing (..)
import View exposing (view)

main =
    Browser.element
        { init = init
        , view = view
        , update = update 
        , subscriptions = subscriptions
        }

init : () -> (Model, Cmd Msg)
init _ = 
    (Loading, getRandomCatGif)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MorePlease -> (Loading, getRandomCatGif)

        GotGif result ->
            case result of
                Ok url ->
                    (Success url, Cmd.none)

                Err _ -> 
                    (Failure, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none