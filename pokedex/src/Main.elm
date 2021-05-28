module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http
import Random
import Json.Decode

main = 
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

type Model
    = Init
    | Loading
    | Success Pokemon
    | Failure String

type Msg
    = RandomButtonClicked
    | ReceiveRandomId Int
    | RandomPokemonResponse (Result Http.Error Pokemon)

type alias Pokemon =
    { name : String
    , abilities : List Data
    , moves : List Data
    }

type alias Data =
    { name : String
    , url : String
    }

init : () -> (Model, Cmd Msg)
init flags =
    ( Init, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomButtonClicked -> 
            ( Loading
            , Random.generate ReceiveRandomId generateRandomNumber
            )

        ReceiveRandomId id ->
            buildRandomPokemonResponse id

        RandomPokemonResponse result -> 
            case result of
                Ok pokemon ->
                    ( Success pokemon, Cmd.none )

                Err error ->
                    ( Failure (httpErrorToString error), Cmd.none )

httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "The URL " ++ url ++ " was invalid"
        Http.Timeout ->
            "Unable to reach the server, try again"
        Http.NetworkError ->
            "Unable to reach the server, check your network connection"
        Http.BadStatus 500 ->
            "The server had a problem, try again later"
        Http.BadStatus 400 ->
            "Verify your information and try again"
        Http.BadStatus _ ->
            "Unknown error"
        Http.BadBody errorMessage ->
            errorMessage

buildRandomPokemonResponse : Int -> ( Model, Cmd Msg )
buildRandomPokemonResponse id =
    ( Loading
    , Http.get
        { url = "https://pokeapi.co/api/v2/pokemon/" ++ (String.fromInt id)
        , expect = Http.expectJson RandomPokemonResponse pokeDecoder
        }
    )

generateRandomNumber : Random.Generator Int
generateRandomNumber =
    Random.int 1 150

pokeDecoder : Json.Decode.Decoder Pokemon
pokeDecoder =
    Json.Decode.map3 Pokemon
        (Json.Decode.field "name" Json.Decode.string) 
        (Json.Decode.field "abilities" (Json.Decode.list (Json.Decode.field "ability" dataDecoder)))
        (Json.Decode.field "moves" (Json.Decode.list (Json.Decode.field "move" dataDecoder)))

dataDecoder : Json.Decode.Decoder Data
dataDecoder =
    Json.Decode.map2 Data
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "url" Json.Decode.string)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> Html Msg
view model =
    div []
        [ text "Search for a pokemon"
        , button [ onClick RandomButtonClicked ] [ text "Random Pokemon" ]
        , case model of
            Init -> viewInit
            Loading -> viewLoading
            Success pokemon -> viewSuccess pokemon
            Failure message -> viewFailure message
        ]

viewInit : Html Msg
viewInit =
    div []
        [ text "" ]

viewLoading : Html Msg
viewLoading =
    div []
        [ text "Loading pokemon..." ]

viewSuccess : Pokemon -> Html Msg
viewSuccess pokemon =
    div []
        [ text ("Pokemon name: " ++ pokemon.name) ]
viewFailure : String -> Html Msg
viewFailure message =
    div []
        [ text ("Failed to get pokemon: " ++ message) ]