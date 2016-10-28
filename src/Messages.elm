module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)


type Msg
    = VisitHome
    | VisitExercises
    | VisitExercise ExerciseId
    | FetchExercisesSucceed (List Exercise)
    | FetchExercisesFail (Error String)
