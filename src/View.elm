module View exposing (view)

import Html exposing (Html, div, ul, li, text, h1, p, a)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(..), reverse)
import Utils exposing (findById, navLink)
import Views.Exercises exposing (exercisesPage, exercisePage, exerciseForm)
import Views.Routines exposing (routinesPage, routinePage, addRoutineForm, editRoutineForm)


{-| Render the Navigation and Page Content
-}
view : Model -> Html Msg
view model =
    div [] [ nav, page model ]


{-| Render the Nav Menu.
-}
nav : Html Msg
nav =
    ul []
        [ li []
            [ navLink "Home" HomeRoute ]
        , li []
            [ navLink "Exercises" ExercisesRoute
            , ul []
                [ li [] [ navLink "Add Exercise" ExerciseAddRoute ] ]
            ]
        , li []
            [ navLink "Routines" RoutinesRoute
            , ul []
                [ li [] [ navLink "Add Routine" RoutineAddRoute ] ]
            ]
        ]


{-| Render the Page Content using the current Route.
-}
page : Model -> Html Msg
page ({ route, exercises, routines } as model) =
    case route of
        HomeRoute ->
            homePage

        NotFoundRoute ->
            notFoundPage

        ExercisesRoute ->
            exercisesPage exercises

        ExerciseAddRoute ->
            exerciseForm model

        ExerciseRoute id ->
            findById id exercises
                |> Maybe.map exercisePage
                |> Maybe.withDefault notFoundPage

        ExerciseEditRoute id ->
            findById id exercises
                |> Maybe.map (always <| exerciseForm model)
                |> Maybe.withDefault notFoundPage

        RoutinesRoute ->
            routinesPage routines

        RoutineAddRoute ->
            addRoutineForm model.routineForm

        RoutineRoute id ->
            findById id routines
                |> Maybe.map routinePage
                |> Maybe.withDefault notFoundPage

        RoutineEditRoute id ->
            findById id routines
                |> Maybe.map (always <| editRoutineForm model)
                |> Maybe.withDefault notFoundPage


{-| Render the Home Page.
-}
homePage : Html msg
homePage =
    div []
        [ h1 [] [ text "Home" ]
        , p [] [ text "Welcome to BodyWeightLogger.", text "test em dubs" ]
        ]


{-| Render the 404 Page.
-}
notFoundPage : Html msg
notFoundPage =
    h1 [] [ text "404 - Not Found" ]
