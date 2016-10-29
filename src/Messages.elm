module Messages exposing (..)

import HttpBuilder exposing (Error)
import Models.Exercises exposing (ExerciseId, Exercise)
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
    | ExerciseFormChange ExerciseFormMessage
    | SubmitExerciseForm
    | CancelExerciseForm
    | FetchExercises (HttpMsg (List Exercise))
    | FetchExercise (HttpMsg Exercise)
    | CreateExercise (HttpMsg Exercise)
