module Models.Routines exposing (..)

import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode


type alias RoutineId =
    Int


type alias Routine =
    { id : RoutineId
    , name : String
    }


{-| Initial Routines have an `id` of 0 and blank fields.
-}
initialRoutine : Routine
initialRoutine =
    { id = 0
    , name = ""
    }


{-| Decode a single `Routine` from the backend.
-}
routineDecoder : Decode.Decoder Routine
routineDecoder =
    Decode.object2 Routine
        ("id" := Decode.int)
        ("name" := Decode.string)


{-| Encode a single `Routine` for the backend.
-}
routineEncoder : Routine -> Encode.Value
routineEncoder { name } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "isPublic", Encode.bool True )
        , ( "copyright", Encode.string "" )
        ]
