module Models.Exercises exposing (..)

import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode


type alias ExerciseId =
    Int


type alias Exercise =
    { id : ExerciseId
    , name : String
    , description : String
    , isHold : Bool
    , amazonIds : String
    , youtubeIds : String
    }


{-| Initial Exercises have an `id` of 0 and blank fields.
-}
initialExercise : Exercise
initialExercise =
    { id = 0
    , name = ""
    , description = ""
    , isHold = False
    , amazonIds = ""
    , youtubeIds = ""
    }


{-| Decode a single `Exercise` from the backend.
-}
exerciseDecoder : Decode.Decoder Exercise
exerciseDecoder =
    Decode.object6 Exercise
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)
        ("isHold" := Decode.bool)
        ("amazonIds" := Decode.string)
        ("youtubeIds" := Decode.string)


{-| Encode a single `Exercise` for the backend.
-}
exerciseEncoder : Exercise -> Encode.Value
exerciseEncoder exercise =
    Encode.object
        [ ( "name", Encode.string exercise.name )
        , ( "description", Encode.string exercise.description )
        , ( "isHold", Encode.bool exercise.isHold )
        , ( "amazonIds", Encode.string exercise.amazonIds )
        , ( "youtubeIds", Encode.string exercise.youtubeIds )
        , ( "copyright", Encode.string "" )
        ]


{-| Return a string representation of the type of Exercise(Reps or Hold).
-}
exerciseType : Exercise -> String
exerciseType { isHold } =
    if isHold then
        "Hold"
    else
        "Reps"
