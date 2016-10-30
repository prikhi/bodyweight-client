module Views.Routines exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onSubmit)
import Html.Attributes exposing (href, type', value)
import Messages exposing (Msg(..))
import Models.Routines exposing (Routine)
import Routing exposing (Route(..), reverse)
import Utils exposing (onClickNoDefault, textField)


{-| Render a listing of Routines.
-}
routinesPage : List Routine -> Html Msg
routinesPage routines =
    div []
        [ h1 [] [ text "Routines" ]
        , routineTable routines
        ]


{-| Render the details of a single `Routine`.
-}
routinePage : Routine -> Html Msg
routinePage { id, name } =
    div []
        [ h1 [] [ text name ]
        , button [ onClick <| DeleteRoutineClicked id ] [ text "Delete" ]
        ]


{-| Render a table of Routines.
-}
routineTable : List Routine -> Html Msg
routineTable routines =
    table []
        [ thead []
            [ tr [] [ th [] [ text "Name" ] ] ]
        , tbody [] <| List.map routineRow routines
        ]


{-| Render a table row representing a Routine.
-}
routineRow : Routine -> Html Msg
routineRow { id, name } =
    tr []
        [ td []
            [ a
                [ href <| reverse <| RoutineRoute id
                , onClickNoDefault <| NavigateTo <| RoutineRoute id
                ]
                [ text name ]
            ]
        ]


{-| Render the form for creating an initial Routine before adding Exercises.
-}
addRoutineForm : Routine -> Html Msg
addRoutineForm routineForm =
    div []
        [ h1 [] [ text "Add Routine" ]
        , form [ onSubmit SubmitRoutineForm ]
            [ textField "Name" "name" routineForm.name RoutineFormNameChange
            , p []
                [ input [ type' "submit", value "Save" ] []
                , text " "
                , button [ onClick CancelRoutineForm ] [ text "Cancel" ]
                ]
            ]
        ]
