module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)
import Routing exposing (Route)


type Msg
    = NavigateTo Route
    | FetchExercisesSucceed (List Exercise)
    | FetchExercisesFail (Error String)
    | FetchExerciseSucceed Exercise
    | FetchExerciseFail (Error String)
