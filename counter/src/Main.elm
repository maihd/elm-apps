import Browser
import Html exposing (..)
import Html.Events exposing (..)

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
    div [] 
        [ text (String.fromInt model)
        , button [ onClick Increment ] [ text "Increment" ]
        , button [ onClick Decrement ] [ text "Decrement" ]
        , button [ onClick Reset ] [ text "Reset" ]
        ]