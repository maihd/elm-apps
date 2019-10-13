import Browser
import Html exposing (..)
import Http

main = 
    Browser.element
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }

type Model
    = Failure
    | Loading
    | Success String

init : () -> (Model, Cmd Msg)
init _ =
    ( Loading
    , Http.get
        { url = "https://elm-lang.org/assets/public-opinion.txt"
        , expect = Http.expectString GotContent
        }
    )

type Msg
    = GotContent (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotContent result ->
            case result of
                Ok content ->
                    (Success content, Cmd.none)

                Err _ ->
                    (Failure, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> Html Msg
view model = 
    case model of
        Failure -> 
            text "I was unable to load your book."

        Loading ->
            text "Loading..."

        Success content ->
            pre [] [ text content ]