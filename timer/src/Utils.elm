module Utils exposing (..)

import Time
import Types exposing (..)

modelToString : Model -> String
modelToString model =
    let
        hour   = String.fromInt (Time.toHour   model.zone model.time)
        minute = String.fromInt (Time.toMinute model.zone model.time)
        second = String.fromInt (Time.toSecond model.zone model.time) 
    in
        (hour ++ ":" ++ minute ++ ":" ++ second)

initialModel : Model
initialModel = 
    Model Time.utc (Time.millisToPosix 0)