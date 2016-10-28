module Main exposing (main)

import Html exposing (..)
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
    | ExerciseRoute ExerciseId
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    let
        s =
            UrlParser.s
    in
        oneOf
            [ format HomeRoute (s "")
            , format ExercisesRoute (s "exercises" </> s "")
            , format ExerciseRoute (s "exercises" </> int)
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



{- Model -}


type alias Model =
    { exercises : List Exercise
    , route : Route
    }


type alias ExerciseId =
    Int


type alias Exercise =
    { id : ExerciseId
    , name : String
    , description : String
    , isHold : Bool
    , amazonIds : String
    , youtubeIds : String
    }


exerciseType : Exercise -> String
exerciseType { isHold } =
    if isHold then
        "Hold"
    else
        "Reps"


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
    | VisitExercise ExerciseId
    | FetchExercisesSucceed (List Exercise)
    | FetchExercisesFail (Error String)


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
            notFoundPage

        ExercisesRoute ->
            div []
                [ h1 [] [ text "Exercises" ]
                , exerciseTable exercises
                ]

        ExerciseRoute id ->
            List.filter (\x -> x.id == id) exercises
                |> List.head
                |> Maybe.map exercisePage
                |> Maybe.withDefault notFoundPage


notFoundPage : Html msg
notFoundPage =
    h1 [] [ text "404 - Not Found" ]


exercisePage : Exercise -> Html msg
exercisePage ({ name, description } as exercise) =
    let
        descriptionText =
            if String.isEmpty description then
                ""
            else
                " - " ++ description
    in
        div []
            [ h1 [] [ text name ]
            , button [] [ text "Edit" ]
            , text " "
            , button [] [ text "Delete" ]
            , p [] [ text "TODO - Youtube Embed Here" ]
            , p []
                [ b [] [ text <| exerciseType exercise ]
                , text descriptionText
                ]
            , p [] [ text "TODO - Amazon Links Here" ]
            ]


exerciseTable : List Exercise -> Html Msg
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


exerciseRow : Exercise -> Html Msg
exerciseRow ({ id, name, isHold } as exercise) =
    tr []
        [ td []
            [ a
                [ href <| reverse <| ExerciseRoute id
                , onClickNoDefault <| VisitExercise id
                ]
                [ text name ]
            ]
        , td []
            [ text <| exerciseType exercise
            ]
        ]



{- Utils -}


onClickNoDefault : msg -> Attribute msg
onClickNoDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed msg)
