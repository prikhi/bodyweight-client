module Main exposing (main)

import Auth
import Commands exposing (fetchForRoute, reauthorize)
import Messages exposing (Msg(UrlUpdate))
import Model exposing (Model, initialModel)
import Navigation
import Routing exposing (Route, routeFromResult, routeParser)
import Update exposing (update)
import View exposing (view)


{-| Accept an Auth Token on initialization if we were told to remember the
User's Login.
-}
type alias Flags =
    { authToken : Maybe String
    , authUserId : Maybe Int
    }


{-| Hook the update/view functions up to the initial model.
-}
main : Program Flags Model Msg
main =
    Navigation.programWithFlags parser
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


{-| Generate the initial model & commands for the route.
-}
init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        route =
            routeParser location

        fetchCmd =
            case ( flags.authToken, flags.authUserId ) of
                ( Just _, Just _ ) ->
                    Cmd.none

                _ ->
                    fetchForRoute Auth.Anonymous route

        reauthorizeCmd =
            Maybe.map2 reauthorize flags.authToken flags.authUserId
                |> Maybe.withDefault Cmd.none
    in
        ( initialModel route, Cmd.batch [ fetchCmd, reauthorizeCmd ] )


{-| Parse the Location and wrap the resulting Route with a UrlUpdate Msg.
-}
parser : Navigation.Location -> Msg
parser location =
    UrlUpdate <| routeParser location
