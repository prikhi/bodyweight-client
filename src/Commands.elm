module Commands exposing (..)

import HttpBuilder exposing (send, stringReader, jsonReader, get)
import Json.Decode as Decode exposing ((:=))
import Messages exposing (Msg(..), HttpMsg)
import Models.Exercises exposing (ExerciseId, exerciseDecoder)
import Routing exposing (Route(..))
import Task


{-| Return a command that fetches any relevant data for the Route.
-}
fetchForRoute : Route -> Cmd Msg
fetchForRoute route =
    case route of
        HomeRoute ->
            Cmd.none

        ExercisesRoute ->
            fetchExercises

        ExerciseRoute id ->
            fetchExercise id

        NotFoundRoute ->
            Cmd.none


{-| Fetch data from the backend server.
-}
fetch : String -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
fetch url decoder msg =
    get ("http://localhost:8080/" ++ url)
        |> send (jsonReader decoder) stringReader
        |> Task.perform (msg << Err) (msg << Ok << .data)


{-| Fetch all the Exercises.
-}
fetchExercises : Cmd Msg
fetchExercises =
    fetch "exercises" ("exercise" := Decode.list exerciseDecoder) FetchExercises


{-| Fetch a single Exercise.
-}
fetchExercise : ExerciseId -> Cmd Msg
fetchExercise id =
    fetch ("exercises/" ++ toString id) ("exercise" := exerciseDecoder) FetchExercise
