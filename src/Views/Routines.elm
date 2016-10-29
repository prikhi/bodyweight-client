module Views.Routines exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href)
import Messages exposing (Msg(..))
import Models.Routines exposing (Routine)
import Routing exposing (Route(..), reverse)
import Utils exposing (onClickNoDefault)


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
