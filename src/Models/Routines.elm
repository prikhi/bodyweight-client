module Models.Routines exposing (..)

import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode


type alias RoutineId =
    Int


type alias Routine =
    { id : RoutineId
    , name : String
    , copyright : String
    , isPublic : Bool
    }


{-| Initial Routines have an `id` of 0 and blank fields.
-}
initialRoutine : Routine
initialRoutine =
    { id = 0
    , name = ""
    , copyright = ""
    , isPublic = True
    }


{-| Decode a single `Routine` from the backend.
-}
routineDecoder : Decode.Decoder Routine
routineDecoder =
    Decode.object4 Routine
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("copyright" := Decode.string)
        ("isPublic" := Decode.bool)


{-| Encode a single `Routine` for the backend.
-}
routineEncoder : Routine -> Encode.Value
routineEncoder { name, copyright, isPublic } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "isPublic", Encode.bool isPublic )
        , ( "copyright", Encode.string copyright )
        ]
