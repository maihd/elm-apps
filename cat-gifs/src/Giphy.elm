module Giphy exposing (getRandomCatGif)

import Types exposing (..)

import Http
import Json.Decode exposing (Decoder, field, string)

getRandomCatGif : Cmd Msg
getRandomCatGif =
    Http.get 
        { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=cat"
        , expect = Http.expectJson GotGif gifDecoder 
        }

gifDecoder : Decoder Url
gifDecoder =
    field "data" (field "image_url" string)