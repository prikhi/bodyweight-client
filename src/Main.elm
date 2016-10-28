module Main exposing (main)

import Html exposing (Html, h1, div, text, table, thead, tr, th, tbody, td)
import Html.App exposing (program)
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing ((:=))
import Task


main : Program Never
main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }



{- Model -}


type alias Model =
    { exercises : List Exercise }


type alias Exercise =
    { id : Int
    , name : String
    , description : String
    , isHold : Bool
    , amazonIds : String
    , youtubeIds : String
    }


exerciseDecoder : Decode.Decoder Exercise
exerciseDecoder =
    Decode.object6 Exercise
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)
        ("isHold" := Decode.bool)
        ("amazonIds" := Decode.string)
        ("youtubeIds" := Decode.string)


init : ( Model, Cmd Msg )
init =
    ( { exercises = [] }, fetchExercises )



{- Update -}


type Msg
    = FetchExercisesSucceed (List Exercise)
    | FetchExercisesFail (Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchExercisesSucceed newData ->
            ( { exercises = newData }, Cmd.none )

        FetchExercisesFail _ ->
            ( model, Cmd.none )


fetchExercises =
    let
        decoder =
            "exercise" := Decode.list exerciseDecoder
    in
        get "http://localhost:8080/exercises"
            |> send (jsonReader decoder) stringReader
            |> Task.perform FetchExercisesFail (FetchExercisesSucceed << .data)



{- View -}


view : Model -> Html Msg
view { exercises } =
    div []
        [ h1 [] [ text "Exercises" ]
        , exerciseTable exercises
        ]


exerciseTable : List Exercise -> Html msg
exerciseTable exercises =
    table []
        [ thead []
            [ tr []
                [ th [] [ text "Name" ]
                , th [] [ text "Type" ]
                ]
            ]
        , tbody [] <| List.map exerciseRow exercises
        ]


exerciseRow : Exercise -> Html msg
exerciseRow { name, isHold } =
    let
        exerciseType =
            if isHold then
                "Hold"
            else
                "Reps"
    in
        tr []
            [ td [] [ text name ]
            , td []
                [ text <|
                    if isHold then
                        "Hold"
                    else
                        "Reps"
                ]
            ]
