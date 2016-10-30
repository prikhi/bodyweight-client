module Model exposing (..)

import Models.Exercises exposing (Exercise, initialExercise)
import Models.Routines exposing (Routine, initialRoutine)
import Routing exposing (Route)


{-| The global Model contains the list of exercises & a route.
-}
type alias Model =
    { exercises : List Exercise
    , exerciseForm : Exercise
    , routines : List Routine
    , routineForm : Routine
    , route : Route
    }


{-| The list of exercises starts empty.
-}
initialModel : Route -> Model
initialModel route =
    { exercises = []
    , exerciseForm = initialExercise
    , routines = []
    , routineForm = initialRoutine
    , route = route
    }
