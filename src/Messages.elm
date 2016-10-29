module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)
import Routing exposing (Route)


type alias HttpMsg a =
    Result (Error String) a


type Msg
    = NavigateTo Route
    | FetchExercises (HttpMsg (List Exercise))
    | FetchExercise (HttpMsg Exercise)
