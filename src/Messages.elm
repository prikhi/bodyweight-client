module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)
import Models.Routines exposing (RoutineId, Routine)
import Models.Sections exposing (SectionId, SectionExerciseId, Section, SectionExercise)
import Routing exposing (Route)


{-| A Message type used for wrapping backend HTTP responses.
-}
type alias HttpMsg a =
    Result (Error String) a


{-| A Message type used for changes to the Exercise form.
-}
type ExerciseFormMessage
    = ExerciseNameChange String
    | DescriptionChange String
    | IsHoldChange Bool
    | YoutubeChange String
    | AmazonChange String


{-| A Message type used for changes to the Edit Routine form.
-}
type RoutineFormMessage
    = RoutineNameChange String
    | RoutineCopyrightChange String
    | RoutinePublicChange Bool
    | MoveSectionUp Int
    | MoveSectionDown Int
    | AddSection
    | CancelSection Int
    | SectionFormMsg Int SectionFormMessage


{-| A Message type used for changes to the Section forms.
-}
type SectionFormMessage
    = SectionNameChange String
    | MoveExerciseUp Int
    | MoveExerciseDown Int
    | AddSectionExercise
    | CancelSectionExercise Int
    | SectionExerciseFormMsg Int SectionExerciseFormMessage


{-| A Message type used for changes to the SectionExercise forms.
-}
type SectionExerciseFormMessage
    = AddExercise ExerciseId
    | ChangeExercise Int ExerciseId
    | RemoveExercise Int
    | ChangeSetCount Int
    | ChangeRepCount Int
    | ChangeRepProgress Int
    | ChangeHoldTime Int
    | ChangeHoldProgress Int


{-| All Messages used in the application.
-}
type Msg
    = NavigateTo Route
    | DeleteExerciseClicked ExerciseId
    | ExerciseFormChange ExerciseFormMessage
    | SubmitExerciseForm
    | CancelExerciseForm
    | FetchExercises (HttpMsg (List Exercise))
    | FetchExercise (HttpMsg Exercise)
    | CreateExercise (HttpMsg Exercise)
    | DeleteExercise (HttpMsg ExerciseId)
    | DeleteRoutineClicked RoutineId
    | RoutineFormChange RoutineFormMessage
    | SubmitAddRoutineForm
    | CancelAddRoutineForm
    | SaveSectionClicked Int
    | DeleteSectionClicked Int SectionId
    | SaveSectionExerciseClicked Int Int
    | DeleteSectionExerciseClicked Int Int SectionExerciseId
    | SubmitEditRoutineForm
    | CancelEditRoutineForm
    | FetchRoutines (HttpMsg (List Routine))
    | FetchRoutine (HttpMsg Routine)
    | CreateRoutine (HttpMsg Routine)
    | UpdateRoutine (HttpMsg Routine)
    | DeleteRoutine (HttpMsg RoutineId)
    | FetchSections (HttpMsg (List Section))
    | CreateSection Int (HttpMsg Section)
    | UpdateSection Int (HttpMsg Section)
    | DeleteSection Int (HttpMsg SectionId)
    | FetchSectionExercises (HttpMsg (List SectionExercise))
    | CreateSectionExercise Int Int (HttpMsg SectionExercise)
    | UpdateSectionExercise Int Int (HttpMsg SectionExercise)
    | DeleteSectionExercise Int Int (HttpMsg SectionExerciseId)
