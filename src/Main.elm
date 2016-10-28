module Main exposing (main)

import Html exposing (Html, Attribute, h1, div, text, table, thead, tr, th, tbody, td, ul, li, a, p)
import Html.App exposing (program)
import Html.Attributes exposing (href)
import Html.Events exposing (onWithOptions, defaultOptions, on, targetValue)
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing ((:=))
import Navigation
import String
import Task
import UrlParser exposing (..)


main : Program Never
main =
    Navigation.program parser
        { init = init
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = always Sub.none
        , view = view
        }



{- Routing -}


type Route
    = HomeRoute
    | ExercisesRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ format HomeRoute (s "")
        , format ExercisesRoute (s "exercises" </> s "")
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
            case route of
                HomeRoute ->
                    ""

                ExercisesRoute ->
                    "exercises/"

                NotFoundRoute ->
                    ""
    in
        "#" ++ routeToString route



{- Model -}


type alias Model =
    { exercises : List Exercise
    , route : Route
    }


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


init : Result String Route -> ( Model, Cmd Msg )
init result =
    ( { exercises = [], route = routeFromResult result }, fetchExercises )



{- Update -}


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    ( { model | route = routeFromResult result }, Cmd.none )


type Msg
    = VisitHome
    | VisitExercises
    | FetchExercisesSucceed (List Exercise)
    | FetchExercisesFail (Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VisitHome ->
            ( model, Navigation.newUrl <| reverse HomeRoute )

        VisitExercises ->
            ( model, Navigation.newUrl <| reverse ExercisesRoute )

        FetchExercisesSucceed newData ->
            ( { model | exercises = newData }, Cmd.none )

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
view model =
    div [] [ nav, page model ]


nav : Html Msg
nav =
    ul []
        [ li []
            [ a
                [ href <| reverse HomeRoute
                , onClickNoDefault VisitHome
                ]
                [ text "Home" ]
            ]
        , li []
            [ a
                [ href <| reverse ExercisesRoute
                , onClickNoDefault VisitExercises
                ]
                [ text "Exercises" ]
            ]
        ]


page : Model -> Html Msg
page { route, exercises } =
    case route of
        HomeRoute ->
            div []
                [ h1 [] [ text "Home" ]
                , p [] [ text "Welcome to BodyWeightLogger." ]
                ]

        NotFoundRoute ->
            h1 [] [ text "404 - Not Found" ]

        ExercisesRoute ->
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



{- Utils -}


onClickNoDefault : msg -> Attribute msg
onClickNoDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed msg)
