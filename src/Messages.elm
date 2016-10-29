module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)
import Routing exposing (Route)


{-| A Message type used for wrapping backend HTTP responses.
-}
type alias HttpMsg a =
    Result (Error String) a


{-| All Messages used in the application.
-}
type Msg
    = NavigateTo Route
    | FetchExercises (HttpMsg (List Exercise))
    | FetchExercise (HttpMsg Exercise)
