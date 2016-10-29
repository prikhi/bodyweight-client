module Model exposing (..)

import Models.Exercises exposing (Exercise)
import Routing exposing (Route)


type alias Model =
    { exercises : List Exercise
    , route : Route
    }


initialModel : Route -> Model
initialModel route =
    { exercises = [], route = route }
