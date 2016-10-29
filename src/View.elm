module View exposing (view)

import Html exposing (Html, div, ul, li, text, h1, p, a)
import Html.Attributes exposing (href)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(..), reverse)
import Utils exposing (onClickNoDefault)
import Views.Exercises exposing (exercisesPage, exercisePage)


{-| Render the Navigation and Page Content
-}
view : Model -> Html Msg
view model =
    div [] [ nav, page model ]


{-| Render the Nav Menu.
-}
nav : Html Msg
nav =
    let
        navLink content route =
            a [ href <| reverse route, onClickNoDefault <| NavigateTo route ]
                [ text content ]
    in
        ul []
            [ li []
                [ navLink "Home" HomeRoute ]
            , li []
                [ navLink "Exercises" ExercisesRoute
                ]
            ]


{-| Render the Page Content using the current Route.
-}
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
