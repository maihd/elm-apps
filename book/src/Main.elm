import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http

main = 
    Browser.element
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }

type SearchBook
    = Failure
    | Loading
    | Success String

type alias Model =
    { query : String
    , searchBook : SearchBook
    }

init : () -> (Model, Cmd Msg)
init _ =
    ( { query = "", searchBook = Loading }
    , Http.get
        { url = "https://elm-lang.org/assets/public-opinion.txt"
        , expect = Http.expectString GotContent
        }
    )

type Msg
    = GotContent (Result Http.Error String)
    | QueryChange String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotContent result ->
            case result of
                Ok content ->
                    ({ model | searchBook = Success content }, Cmd.none)

                Err _ ->
                    ({ model | searchBook = Failure }, Cmd.none)

        QueryChange query ->
            ({ model | query = query }, Cmd.none) 

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> Html Msg
view model = 
    div []
        [ input [ placeholder "Type to search books...", value model.query, onInput QueryChange, style "display" "block" ] []
        , case model.searchBook of
            Failure -> 
                text "I was unable to load your book."

            Loading ->
                text "Loading..."

            Success content ->
                pre [] [ text content ]
        ]
    