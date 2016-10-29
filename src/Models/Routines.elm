module Models.Routines exposing (..)

import Json.Decode as Decode exposing ((:=))


type alias RoutineId =
    Int


type alias Routine =
    { id : RoutineId
    , name : String
    }


{-| Decode a single `Routine` from the backend.
-}
routineDecoder : Decode.Decoder Routine
routineDecoder =
    Decode.object2 Routine
        ("id" := Decode.int)
        ("name" := Decode.string)
