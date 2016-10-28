module Main exposing (main)

import Html.App exposing (program)
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing ((:=))
import Messages exposing (Msg(..))
import Model exposing (Model)
import Models.Exercises exposing (Exercise)
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


fetchExercises =
    get "http://localhost:8080/exercises"
        |> send (jsonReader <| "exercise" := Decode.list exerciseDecoder) stringReader
        |> Task.perform FetchExercisesFail (FetchExercisesSucceed << .data)


fetchExercise id =
    get ("http://localhost:8080/exercises/" ++ toString id)
        |> send (jsonReader <| "exercise" := exerciseDecoder) stringReader
        |> Task.perform FetchExerciseFail (FetchExerciseSucceed << .data)


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

        FetchExercisesSucceed newData ->
            ( { model | exercises = newData }, Cmd.none )

        FetchExercisesFail _ ->
            ( model, Cmd.none )

        FetchExerciseSucceed newData ->
            ( { model | exercises = newData :: model.exercises }, Cmd.none )

        FetchExerciseFail _ ->
            ( model, Cmd.none )
