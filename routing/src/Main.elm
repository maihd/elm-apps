import Browser
import Browser.Navigation as Nav

import Url

import Html

main = 
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }

type Msg 
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest


type alias Model =
    {}

init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key = 
    ({}, Cmd.none)

view : Model -> Browser.Document Msg
view model =
    { title = "Elm Routing"
    , body = 
        [ Html.text "Elm Routing"
        ]
    }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none