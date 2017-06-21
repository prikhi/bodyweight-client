module Model exposing (..)

import Array exposing (Array)
import Auth
import Models.Exercises exposing (Exercise, initialExercise)
import Models.Routines exposing (Routine, initialRoutine)
import Models.Sections exposing (Section, SectionForm, SectionExercise, initialSectionForm)
import RemoteStatus
import Routing exposing (Route)


{-| The global Model contains the list of exercises & a route.
-}
type alias Model =
    { exercises : List Exercise
    , routines : List Routine
    , sections : List Section
    , sectionExercises : List SectionExercise
    , exerciseForm : Exercise
    , routineForm : Routine
    , sectionForms : Array SectionForm
    , savingStatus : RemoteStatus.Status
    , route : Route
    , authStatus : Auth.Status
    , authForm : Auth.Form
    }


{-| The list of exercises starts empty.
-}
initialModel : Route -> Model
initialModel route =
    { exercises = []
    , exerciseForm = initialExercise
    , routines = []
    , routineForm = initialRoutine
    , sections = []
    , sectionForms = Array.fromList [ initialSectionForm 0 ]
    , sectionExercises = []
    , savingStatus = RemoteStatus.initial
    , route = route
    , authStatus = Auth.initial route
    , authForm = Auth.initialForm
    }
