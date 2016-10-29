module Views.Routines exposing (..)

import Html exposing (..)
import Messages exposing (Msg)
import Models.Routines exposing (Routine)


{-| Render a listing of Routines.
-}
routinesPage : List Routine -> Html Msg
routinesPage routines =
    div []
        [ h1 [] [ text "Routines" ]
        , routineTable routines
        ]


{-| Render a table of Routines.
-}
routineTable : List Routine -> Html msg
routineTable routines =
    table []
        [ thead []
            [ tr [] [ th [] [ text "Name" ] ] ]
        , tbody [] <| List.map routineRow routines
        ]


{-| Render a table row representing a Routine.
-}
routineRow : Routine -> Html msg
routineRow { name } =
    tr [] [ td [] [ text name ] ]
