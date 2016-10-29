module Main exposing (main)

import Html.App exposing (program)
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing ((:=))
import Messages exposing (Msg(..), HttpMsg)
import Model exposing (Model)
import Models.Exercises exposing (Exercise, ExerciseId)
import Routing exposing (Route(..), routeFromResult, reverse, parser)
import Navigation
import String
import Task
import View exposing (view)


main : Program Never
main =
    Navigation.program parser
        { init = init
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = always Sub.none
        , view = view
        }


init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        route =
            routeFromResult result
    in
        ( { exercises = [], route = route }, fetchForRoute route )


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


fetch : String -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
fetch url decoder msg =
    get ("http://localhost:8080/" ++ url)
        |> send (jsonReader decoder) stringReader
        |> Task.perform (msg << Err) (msg << Ok << .data)


fetchExercises : Cmd Msg
fetchExercises =
    fetch "exercises" ("exercise" := Decode.list exerciseDecoder) FetchExercises


fetchExercise : ExerciseId -> Cmd Msg
fetchExercise id =
    fetch ("exercises/" ++ toString id) ("exercise" := exerciseDecoder) FetchExercise


exerciseDecoder : Decode.Decoder Exercise
exerciseDecoder =
    Decode.object6 Exercise
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)
        ("isHold" := Decode.bool)
        ("amazonIds" := Decode.string)
        ("youtubeIds" := Decode.string)



{- Update -}


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
