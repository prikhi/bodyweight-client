module Main exposing (main)

import Commands exposing (fetchForRoute)
import Messages exposing (Msg)
import Model exposing (Model, initialModel)
import Navigation
import Routing exposing (Route, routeFromResult, parser)
import Update exposing (update, urlUpdate)
import View exposing (view)


{-| Hook the update/view functions up to the initial model.
-}
main : Program Never
main =
    Navigation.program parser
        { init = init
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = always Sub.none
        , view = view
        }


{-| Generate the initial model & commands for the route.
-}
init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        route =
            routeFromResult result
    in
        ( initialModel route, fetchForRoute route )
