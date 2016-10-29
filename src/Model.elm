module Model exposing (..)

import Models.Exercises exposing (Exercise)
import Routing exposing (Route)


{-| The global Model contains the list of exercises & a route.
-}
type alias Model =
    { exercises : List Exercise
    , route : Route
    }


{-| The list of exercises starts empty.
-}
initialModel : Route -> Model
initialModel route =
    { exercises = [], route = route }
