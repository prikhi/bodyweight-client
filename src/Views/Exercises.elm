module Views.Exercises exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Messages exposing (Msg(..))
import Models.Exercises exposing (Exercise, exerciseType)
import Routing exposing (Route(..), reverse)
import String
import Utils exposing (onClickNoDefault)


{-| Render a listing of Exercises
-}
exercisesPage : List Exercise -> Html Msg
exercisesPage exercises =
    div []
        [ h1 [] [ text "Exercises" ]
        , exerciseTable exercises
        ]


{-| Render an Exercise's details.
-}
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


{-| Render Exercises as a table.
-}
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


{-| Render an Exercise as a table row.
-}
exerciseRow : Exercise -> Html Msg
exerciseRow ({ id, name, isHold } as exercise) =
    tr []
        [ td []
            [ a
                [ href <| reverse <| ExerciseRoute id
                , onClickNoDefault <| NavigateTo <| ExerciseRoute id
                ]
                [ text name ]
            ]
        , td []
            [ text <| exerciseType exercise
            ]
        ]
