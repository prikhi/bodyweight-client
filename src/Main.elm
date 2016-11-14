module Main exposing (main)

import Commands exposing (fetchForRoute)
import Messages exposing (Msg(UrlUpdate))
import Model exposing (Model, initialModel)
import Navigation
import Routing exposing (Route, routeFromResult, routeParser)
import Update exposing (update)
import View exposing (view)


{-| Hook the update/view functions up to the initial model.
-}
main : Program Never Model Msg
main =
    Navigation.program parser
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


{-| Generate the initial model & commands for the route.
-}
init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            routeParser location
    in
        ( initialModel route, fetchForRoute route )


{-| Parse the Location and wrap the resulting Route with a UrlUpdate Msg.
-}
parser : Navigation.Location -> Msg
parser location =
    UrlUpdate <| routeParser location
