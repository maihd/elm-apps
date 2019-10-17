import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Types exposing (..)

main = 
    Browser.sandbox { init = init, update = update, view = view }

init : Model
init =
    0

update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment -> model + 1
        Decrement -> model - 1
        Reset -> 0

view : Model -> Html Msg
view model =
    div [ class "wrapper" ] 
        [ viewValue model
        , div 
            [ class "btn-container" ]
            [ viewButton "fa-minus"     (onClick Decrement)
            , viewButton "fa-sync-alt"  (onClick Reset)
            , viewButton "fa-plus"      (onClick Increment)
            ]
        ]

viewButton : String -> Attribute Msg -> Html Msg
viewButton icon onClick =
    button 
        [ onClick
        , class "btn"
        ]
        [ i [ class ("fa " ++ icon) ] [] ]

viewValue : Model -> Html Msg
viewValue model = 
    p [ class "counter" ] [ text (String.fromInt model) ]