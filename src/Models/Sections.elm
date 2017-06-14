module Models.Sections exposing (..)

import Array exposing (Array)
import Json.Decode as Decode
import Json.Encode as Encode
import Models.Exercises exposing (ExerciseId)
import Models.Routines exposing (RoutineId)


type alias SectionId =
    Int


type alias Section =
    { id : SectionId
    , name : String
    , routine : RoutineId
    , order : Int
    }


initialSection : RoutineId -> Section
initialSection routineId =
    { id = 0, name = "", routine = routineId, order = 0 }


sectionDecoder : Decode.Decoder Section
sectionDecoder =
    Decode.map4 Section
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "routine" Decode.int)
        (Decode.field "order" Decode.int)


sectionEncoder : Section -> Encode.Value
sectionEncoder { name, routine, order } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "routine", Encode.int routine )
        , ( "order", Encode.int order )
        ]


type alias SectionExerciseId =
    Int


type alias SectionExercise =
    { id : SectionExerciseId
    , order : Int
    , section : SectionId
    , exercises : Array ExerciseId
    , setCount : Int
    , repCount : Int
    , holdTime : Int
    , repsToProgress : Int
    , timeToProgress : Int
    , restAfter : Bool
    }


initialSectionExercise : SectionId -> SectionExercise
initialSectionExercise sectionId =
    { id = 0
    , order = 0
    , section = sectionId
    , exercises = Array.empty
    , setCount = 0
    , repCount = 0
    , holdTime = 0
    , repsToProgress = 0
    , timeToProgress = 0
    , restAfter = False
    }


sectionExerciseDecoder : Decode.Decoder SectionExercise
sectionExerciseDecoder =
    Decode.map8 SectionExercise
        (Decode.field "id" Decode.int)
        (Decode.field "order" Decode.int)
        (Decode.field "section" Decode.int)
        (Decode.field "exercises" (Decode.array Decode.int))
        (Decode.field "setCount" Decode.int)
        (Decode.field "repCount" Decode.int)
        (Decode.field "holdTime" Decode.int)
        (Decode.field "repsToProgress" Decode.int)
        |> Decode.andThen
            (\f ->
                Decode.map2 f
                    (Decode.field "timeToProgress" Decode.int)
                    (Decode.field "restAfter" Decode.bool)
            )


sectionExerciseEncoder : SectionExercise -> Encode.Value
sectionExerciseEncoder sectionExercise =
    Encode.object
        [ ( "order", Encode.int sectionExercise.order )
        , ( "section", Encode.int sectionExercise.section )
        , ( "exercises", Encode.array <| Array.map Encode.int sectionExercise.exercises )
        , ( "setCount", Encode.int sectionExercise.setCount )
        , ( "repCount", Encode.int sectionExercise.repCount )
        , ( "holdTime", Encode.int sectionExercise.holdTime )
        , ( "repsToProgress", Encode.int sectionExercise.repsToProgress )
        , ( "timeToProgress", Encode.int sectionExercise.timeToProgress )
        , ( "restAfter", Encode.bool sectionExercise.restAfter )
        ]


type alias SectionForm =
    { section : Section
    , exercises : Array SectionExercise
    , isCollapsed : Bool
    }


initialSectionForm : RoutineId -> SectionForm
initialSectionForm routineId =
    { section = initialSection routineId
    , exercises = Array.fromList [ initialSectionExercise 0 ]
    , isCollapsed = False
    }
