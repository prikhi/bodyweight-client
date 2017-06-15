module Models.Routines exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type alias RoutineId =
    Int


type alias Routine =
    { id : RoutineId
    , name : String
    , description : String
    , copyright : String
    , isPublic : Bool
    }


{-| Initial Routines have an `id` of 0 and blank fields.
-}
initialRoutine : Routine
initialRoutine =
    { id = 0
    , name = ""
    , description = ""
    , copyright = ""
    , isPublic = True
    }


{-| Decode a single `Routine` from the backend.
-}
routineDecoder : Decode.Decoder Routine
routineDecoder =
    Decode.map5 Routine
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "copyright" Decode.string)
        (Decode.field "isPublic" Decode.bool)


{-| Encode a single `Routine` for the backend.
-}
routineEncoder : Routine -> Encode.Value
routineEncoder { name, description, copyright, isPublic } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "description", Encode.string description )
        , ( "isPublic", Encode.bool isPublic )
        , ( "copyright", Encode.string copyright )
        ]
