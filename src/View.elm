module View exposing (view)

import Html exposing (Html, div, ul, li, text, h1, p, a)
import Html.Attributes exposing (href)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(..), reverse)
import Utils exposing (onClickNoDefault)
import Views.Exercises exposing (exercisesPage, exercisePage)


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
            homePage

        NotFoundRoute ->
            notFoundPage

        ExercisesRoute ->
            exercisesPage exercises

        ExerciseRoute id ->
            List.filter (\x -> x.id == id) exercises
                |> List.head
                |> Maybe.map exercisePage
                |> Maybe.withDefault notFoundPage


homePage : Html msg
homePage =
    div []
        [ h1 [] [ text "Home" ]
        , p [] [ text "Welcome to BodyWeightLogger." ]
        ]


notFoundPage : Html msg
notFoundPage =
    h1 [] [ text "404 - Not Found" ]
