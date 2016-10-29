module Routing exposing (..)

import Models.Exercises exposing (ExerciseId)
import Navigation
import String
import UrlParser exposing (..)


{-| The Route type encompasses all possible pages in the application.
-}
type Route
    = HomeRoute
    | ExercisesRoute
    | ExerciseRoute ExerciseId
    | NotFoundRoute


{-| Parse a URL into a Route.
-}
matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ format HomeRoute (s "")
        , format ExercisesRoute (s "exercises" </> s "")
        , format ExerciseRoute (s "exercises" </> int)
        ]


{-| Attempt to parse a Locaton's Hash into a Route.
-}
hashParser : Navigation.Location -> Result String Route
hashParser location =
    location.hash |> String.dropLeft 1 |> parse identity matchers


{-| The Hash Parser used by the application.
-}
parser : Navigation.Parser (Result String Route)
parser =
    Navigation.makeParser hashParser


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

                    ExerciseRoute id ->
                        routeToString ExercisesRoute ++ toString id

                    NotFoundRoute ->
                        ""
    in
        "#" ++ routeToString route
