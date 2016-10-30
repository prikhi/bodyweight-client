module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)
import Models.Routines exposing (RoutineId, Routine)
import Routing exposing (Route)


{-| A Message type used for wrapping backend HTTP responses.
-}
type alias HttpMsg a =
    Result (Error String) a


{-| A Message type used for changes to the Exercise form.
-}
type ExerciseFormMessage
    = NameChange String
    | DescriptionChange String
    | IsHoldChange Bool
    | YoutubeChange String
    | AmazonChange String


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
    | RoutineFormNameChange String
    | SubmitRoutineForm
    | CancelRoutineForm
    | FetchRoutines (HttpMsg (List Routine))
    | FetchRoutine (HttpMsg Routine)
    | CreateRoutine (HttpMsg Routine)
    | DeleteRoutine (HttpMsg RoutineId)
