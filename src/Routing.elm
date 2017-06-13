module Routing exposing (..)

import Models.Exercises exposing (ExerciseId)
import Models.Routines exposing (RoutineId)
import Navigation
import UrlParser exposing (..)


{-| The Route type encompasses all possible pages in the application.
-}
type Route
    = HomeRoute
    | ExercisesRoute
    | ExerciseAddRoute
    | ExerciseRoute ExerciseId
    | ExerciseEditRoute ExerciseId
    | RoutinesRoute
    | RoutineAddRoute
    | RoutineRoute RoutineId
    | RoutineEditRoute RoutineId
    | NotFoundRoute


{-| Parse a URL into a Route.
-}
matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map ExercisesRoute (s "exercises" </> s "")
        , map ExerciseAddRoute (s "exercises" </> s "add")
        , map ExerciseEditRoute (s "exercises" </> int </> s "edit")
        , map ExerciseRoute (s "exercises" </> int)
        , map RoutinesRoute (s "routines" </> s "")
        , map RoutineAddRoute (s "routines" </> s "add")
        , map RoutineEditRoute (s "routines" </> int </> s "edit")
        , map RoutineRoute (s "routines" </> int)
        ]


{-| Attempt to parse a Locaton's Hash into a Route.
-}
routeParser : Navigation.Location -> Route
routeParser location =
    location |> parseHash matchers |> Maybe.withDefault NotFoundRoute


{-| Pull a Route out of the parsed URL, defaulting to the `NotFoundRoute`.
-}
routeFromResult : Result String Route -> Route
routeFromResult =
    Result.withDefault NotFoundRoute


{-| Turn a Route into the URL the Route represents.
-}
reverse : Route -> String
reverse route =
    let
        routeToString route =
            flip (++) "/" <|
                case route of
                    HomeRoute ->
                        ""

                    ExercisesRoute ->
                        "exercises"

                    ExerciseAddRoute ->
                        routeToString ExercisesRoute ++ "add"

                    ExerciseRoute id ->
                        routeToString ExercisesRoute ++ toString id

                    ExerciseEditRoute id ->
                        routeToString (ExerciseRoute id) ++ "edit"

                    RoutinesRoute ->
                        "routines"

                    RoutineAddRoute ->
                        routeToString RoutinesRoute ++ "add"

                    RoutineRoute id ->
                        routeToString RoutinesRoute ++ toString id

                    RoutineEditRoute id ->
                        routeToString (RoutineRoute id) ++ "edit"

                    NotFoundRoute ->
                        ""
    in
        "#" ++ routeToString route
