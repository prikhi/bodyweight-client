module Api.Endpoints exposing (Endpoint(..), endpointToURL)

import Models.Exercises exposing (ExerciseId)
import Models.Routines exposing (RoutineId)
import Models.Sections exposing (SectionId, SectionExerciseId)


type Endpoint
    = Register
    | Login
    | Reauthorize
    | Exercises
    | Exercise ExerciseId
    | Routines
    | Routine RoutineId
    | Sections
    | Section SectionId
    | SectionExercises
    | SectionExercise SectionExerciseId


endpointToURL : Endpoint -> String
endpointToURL endpoint =
    let
        toURL endpoint =
            case endpoint of
                Register ->
                    "users/register"

                Login ->
                    "users/login"

                Reauthorize ->
                    "users/reauthorize"

                Exercises ->
                    "exercises"

                Exercise id ->
                    nestedUnder Exercises <| toString id

                Routines ->
                    "routines"

                Routine id ->
                    nestedUnder Routines <| toString id

                Sections ->
                    "sections"

                Section id ->
                    nestedUnder Sections <| toString id

                SectionExercises ->
                    "sectionExercises"

                SectionExercise id ->
                    nestedUnder SectionExercises <| toString id

        nestedUnder endpoint postfix =
            toURL endpoint ++ "/" ++ postfix
    in
        "/api/" ++ toURL endpoint
