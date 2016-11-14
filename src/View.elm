module View exposing (view)

import Html exposing (Html, div, text, h1, p)
import Html.Attributes exposing (class)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Navbar exposing (nav)
import Routing exposing (Route(..), reverse)
import Utils exposing (findById, navLink, onClickNoDefault)
import Views.Exercises exposing (exercisesPage, exercisePage, exerciseForm)
import Views.Routines exposing (routinesPage, routinePage, addRoutineForm, editRoutineForm)


{-| Render the Navigation and Page Content
-}
view : Model -> Html Msg
view model =
    div [] [ nav, div [ class "container" ] [ page model ] ]


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
                |> Maybe.map (routinePage model)
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
        , p [] [ text "Welcome to BodyWeightLogger." ]
        ]


{-| Render the 404 Page.
-}
notFoundPage : Html msg
notFoundPage =
    h1 [] [ text "404 - Not Found" ]
