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
    ( { exercises = [], route = routeFromResult result }, fetchExercises )


fetchExercises =
    get "http://localhost:8080/exercises"
        |> send (jsonReader <| "exercise" := Decode.list exerciseDecoder) stringReader
        |> Task.perform FetchExercisesFail (FetchExercisesSucceed << .data)


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
    ( { model | route = routeFromResult result }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VisitHome ->
            ( model, Navigation.newUrl <| reverse HomeRoute )

        VisitExercises ->
            ( model, Navigation.newUrl <| reverse ExercisesRoute )

        VisitExercise id ->
            ( model, Navigation.newUrl <| reverse <| ExerciseRoute id )

        FetchExercisesSucceed newData ->
            ( { model | exercises = newData }, Cmd.none )

        FetchExercisesFail _ ->
            ( model, Cmd.none )
