import Browser
import Html exposing (..)
import Time
import Task
import Types exposing (..)
import Utils exposing (..)

main = 
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

init : () -> (Model, Cmd Msg)
init _ =
    ( initialModel 
    , Task.perform AdjustTimeZone Time.here
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none )
        
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick
            
view : Model -> Html Msg
view model =
    h1 [] [ text (modelToString model) ]