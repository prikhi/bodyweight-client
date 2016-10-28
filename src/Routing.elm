module Routing exposing (..)

import Models.Exercises exposing (ExerciseId)
import Navigation
import String
import UrlParser exposing (..)


type Route
    = HomeRoute
    | ExercisesRoute
    | ExerciseRoute ExerciseId
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    let
        s =
            UrlParser.s
    in
        oneOf
            [ format HomeRoute (s "")
            , format ExercisesRoute (s "exercises" </> s "")
            , format ExerciseRoute (s "exercises" </> int)
            ]


hashParser : Navigation.Location -> Result String Route
hashParser location =
    location.hash |> String.dropLeft 1 |> parse identity matchers


parser : Navigation.Parser (Result String Route)
parser =
    Navigation.makeParser hashParser


routeFromResult : Result String Route -> Route
routeFromResult =
    Result.withDefault NotFoundRoute


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

                    ExerciseRoute id ->
                        routeToString ExercisesRoute ++ toString id

                    NotFoundRoute ->
                        ""
    in
        "#" ++ routeToString route
