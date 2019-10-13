module View exposing (view)

import Types exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Random Cats"]
        , viewGif model 
        ]

viewGif : Model -> Html Msg
viewGif model =
    case model of
        Failure ->
            div [] 
                [ p [] [ text "We are failed to get the gif for some reason. " ]
                , button [ onClick MorePlease, style "display" "block"] [ text "Try Again!!!" ]
                ]

        Loading ->
            div [] 
                [ p [] [ text "Your gifs are comming, please wait..." ]
                ]

        Success url ->
            div [] 
                [ button [ onClick MorePlease, style "display" "block" ] [ text "More please!"] 
                , img [ src url ] [] 
                ]
