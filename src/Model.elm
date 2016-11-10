module Model exposing (..)

import Array exposing (Array)
import Models.Exercises exposing (Exercise, initialExercise)
import Models.Routines exposing (Routine, initialRoutine)
import Models.Sections exposing (Section, SectionForm, SectionExercise, initialSectionForm)
import Routing exposing (Route)
import SavingStatus


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
    , savingStatus : SavingStatus.Model
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
    , sections = []
    , sectionForms = Array.fromList [ initialSectionForm 0 ]
    , sectionExercises = []
    , savingStatus = SavingStatus.NotSaving
    , route = route
    }
