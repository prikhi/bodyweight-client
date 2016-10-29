module Main exposing (main)

import Commands exposing (fetchForRoute)
import Messages exposing (Msg(..), HttpMsg)
import Model exposing (Model, initialModel)
import Navigation
import Routing exposing (Route(..), routeFromResult, reverse, parser)
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


{-| Update the Model's `route` when the URL changes.
-}
urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        route =
            routeFromResult result
    in
        ( { model | route = route }, fetchForRoute route )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateTo route ->
            ( model, Navigation.newUrl <| reverse route )

        FetchExercises (Ok newExercises) ->
            ( { model | exercises = newExercises }, Cmd.none )

        FetchExercises (Err _) ->
            ( model, Cmd.none )

        FetchExercise (Ok newExercise) ->
            ( { model | exercises = newExercise :: model.exercises }, Cmd.none )

        FetchExercise (Err _) ->
            ( model, Cmd.none )
