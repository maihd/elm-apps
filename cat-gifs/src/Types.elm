module Types exposing (..)

import Http

type alias Url = String

type Model 
    = Failure
    | Loading
    | Success Url

type Msg
    = MorePlease
    | GotGif (Result Http.Error Url)