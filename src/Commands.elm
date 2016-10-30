module Commands exposing (..)

import HttpBuilder exposing (send, stringReader, jsonReader, get, post, put, withHeader, withJsonBody)
import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode
import Messages exposing (Msg(..), HttpMsg)
import Models.Exercises exposing (Exercise, ExerciseId, exerciseDecoder, exerciseEncoder)
import Models.Routines exposing (Routine, RoutineId, routineDecoder, routineEncoder)
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

        ExerciseAddRoute ->
            Cmd.none

        ExerciseRoute id ->
            fetchExercise id

        ExerciseEditRoute id ->
            fetchExercise id

        RoutinesRoute ->
            fetchRoutines

        RoutineAddRoute ->
            Cmd.none

        RoutineRoute id ->
            fetchRoutine id

        NotFoundRoute ->
            Cmd.none


performApiRequest : (Result a b -> msg) -> Task.Task a (HttpBuilder.Response b) -> Cmd msg
performApiRequest msg =
    Task.perform (msg << Err) (msg << Ok << .data)


{-| Fetch data from the backend server.
-}
fetch : String -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
fetch url decoder msg =
    get ("/api/" ++ url)
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Create data on the backend server.
-}
create : String -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
create url jsonValue decoder msg =
    post ("/api/" ++ url)
        |> withHeader "Content-Type" "application/json"
        |> withJsonBody jsonValue
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Delete a resource from the backend server.
-}
delete : String -> Int -> (HttpMsg Int -> msg) -> Cmd msg
delete url id msg =
    HttpBuilder.delete ("/api/" ++ url ++ "/" ++ toString id)
        |> send (jsonReader (Decode.succeed id)) stringReader
        |> performApiRequest msg


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


{-| Create an Exercise.
-}
createExercise : Exercise -> Cmd Msg
createExercise exercise =
    create "exercises"
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        ("exercise" := exerciseDecoder)
        CreateExercise


{-| Update an Exercise.
-}
updateExercise : Exercise -> Cmd Msg
updateExercise exercise =
    put ("/api/exercises/" ++ toString exercise.id)
        |> withHeader "Content-Type" "application/json"
        |> withJsonBody (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        |> send (jsonReader ("exercise" := exerciseDecoder)) stringReader
        |> performApiRequest CreateExercise


{-| Delete an Exercise.
-}
deleteExercise : ExerciseId -> Cmd Msg
deleteExercise exerciseId =
    delete "exercises" exerciseId DeleteExercise


{-| Fetch all the Routines.
-}
fetchRoutines : Cmd Msg
fetchRoutines =
    fetch "routines" ("routine" := Decode.list routineDecoder) FetchRoutines


{-| Fetch a single Routine.
-}
fetchRoutine : RoutineId -> Cmd Msg
fetchRoutine routineId =
    fetch ("routines/" ++ toString routineId) ("routine" := routineDecoder) FetchRoutine


{-| Create a Routine.
-}
createRoutine : Routine -> Cmd Msg
createRoutine routine =
    create "routines"
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        ("routine" := routineDecoder)
        CreateRoutine


{-| Delete a Routine.
-}
deleteRoutine : RoutineId -> Cmd Msg
deleteRoutine routineId =
    delete "routines" routineId DeleteRoutine
