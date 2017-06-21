module Navbar exposing (nav)

import Auth
import Html exposing (Html, div, ul, li, text, h1, p, a, span, nav, button)
import Html.Attributes exposing (class, id, href, type_, attribute)
import Routing exposing (Route(..), reverse)
import Messages exposing (Msg(..))
import Utils exposing (onClickNoDefault, ifAdmin)


{-| Render a single link in the Navbar.
-}
navbarLink : String -> Route -> Html Msg
navbarLink content route =
    li [ class "nav-item" ]
        [ a
            [ class "nav-link"
            , href <| reverse route
            , onClickNoDefault <| NavigateTo route
            ]
            [ text content ]
        ]


{-| Render the Nav Menu.
-}
nav : Auth.Status -> Html Msg
nav authStatus =
    let
        ( loginText, loginRoute ) =
            case authStatus of
                Auth.Authorized _ ->
                    ( "Logout", LogoutRoute )

                _ ->
                    ( "Login", LoginRoute )

        ifAuthorized content =
            case authStatus of
                Auth.Authorized _ ->
                    content

                _ ->
                    text ""
    in
        Html.nav [ class "navbar navbar-inverse bg-inverse navbar-toggleable-sm mb-2" ]
            [ button
                [ attribute "aria-controls" "navbarContent"
                , attribute "aria-expanded" "false"
                , attribute "aria-label" "Toggle navigation"
                , class "navbar-toggler navbar-toggler-right"
                , attribute "data-target" "#navbarContent"
                , attribute "data-toggle" "collapse"
                , type_ "button"
                ]
                [ span [ class "navbar-toggler-icon" ] [] ]
            , a
                [ class "navbar-brand"
                , href <| reverse HomeRoute
                , onClickNoDefault <| NavigateTo HomeRoute
                ]
                [ text "BodyWeight Logger" ]
            , div [ class "container ml-0" ]
                [ div [ class "collapse navbar-collapse", id "navbarContent" ]
                    [ ul [ class "navbar-nav mr-auto" ]
                        [ navbarLink "Routines" RoutinesRoute
                        , ifAuthorized <| navbarLink "Add Routine" RoutineAddRoute
                        , navbarLink "Exercises" ExercisesRoute
                        , ifAdmin authStatus <| navbarLink "Add Exercise" ExerciseAddRoute
                        ]
                    , ul [ class "navbar-nav justify-content-end" ]
                        [ navbarLink loginText loginRoute ]
                    ]
                ]
            ]
