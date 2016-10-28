module Models.Exercises exposing (..)


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


exerciseType : Exercise -> String
exerciseType { isHold } =
    if isHold then
        "Hold"
    else
        "Reps"
