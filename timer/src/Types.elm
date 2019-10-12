module Types exposing (..)

import Time

type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }

type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone