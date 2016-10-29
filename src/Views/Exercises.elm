module Views.Exercises exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, name, value, checked, type', width, height, src, attribute)
import Html.Events exposing (onInput, onClick, onCheck, onSubmit)
import Messages exposing (Msg(..), ExerciseFormMessage(..))
import Model exposing (Model)
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
exercisePage : Exercise -> Html Msg
exercisePage ({ id, name, description } as exercise) =
    let
        descriptionText =
            if String.isEmpty description then
                ""
            else
                " - " ++ description

        youtubeIframe =
            if String.isEmpty exercise.youtubeIds then
                text ""
            else
                p []
                    [ iframe
                        [ type' "text/html"
                        , width 516
                        , height 315
                        , src <| "https://www.youtube.com/embed/" ++ exercise.youtubeIds
                        , attribute "frameborder" "0"
                        , attribute "allowfullscreen" ""
                        ]
                        []
                    ]

        amazonIframe =
            if String.isEmpty exercise.amazonIds then
                text ""
            else
                p []
                    [ iframe
                        [ attribute "frameborder" "0"
                        , attribute "marginheight" "0"
                        , attribute "marginwidth" "0"
                        , attribute "scrolling" "no"
                        , src exercise.amazonIds
                        , attribute "style" "width:120px;height:240px;"
                        ]
                        []
                    ]
    in
        div []
            [ h1 [] [ text name ]
            , button [ onClick <| NavigateTo <| ExerciseEditRoute id ] [ text "Edit" ]
            , text " "
            , button [ onClick <| DeleteExerciseClicked id ] [ text "Delete" ]
            , youtubeIframe
            , p []
                [ b [] [ text <| exerciseType exercise ]
                , text descriptionText
                ]
            , amazonIframe
            ]


{-| Render the Add/Edit Exercise form.
-}
exerciseForm : Model -> Html Msg
exerciseForm { exerciseForm } =
    let
        titleText =
            if exerciseForm.id == 0 then
                "Add Exercise"
            else
                "Edit Exercise"
    in
        form [ onSubmit SubmitExerciseForm ]
            [ h1 [] [ text titleText ]
            , label []
                [ text "Name: "
                , input
                    [ name "name"
                    , value exerciseForm.name
                    , onInput (ExerciseFormChange << NameChange)
                    ]
                    []
                ]
            , br [] []
            , label []
                [ text "Description: "
                , br [] []
                , textarea
                    [ name "description"
                    , value exerciseForm.description
                    , onInput (ExerciseFormChange << DescriptionChange)
                    ]
                    []
                ]
            , br [] []
            , label []
                [ text "Is Hold? "
                , input
                    [ name "is-hold"
                    , type' "checkbox"
                    , checked exerciseForm.isHold
                    , onCheck (ExerciseFormChange << IsHoldChange)
                    ]
                    []
                ]
            , br [] []
            , label []
                [ text "Youtube ID: "
                , input
                    [ name "youtube"
                    , value exerciseForm.youtubeIds
                    , onInput (ExerciseFormChange << YoutubeChange)
                    ]
                    []
                ]
            , br [] []
            , label []
                [ text "Amazon ID: "
                , input
                    [ name "amazon"
                    , value exerciseForm.amazonIds
                    , onInput (ExerciseFormChange << AmazonChange)
                    ]
                    []
                ]
            , p []
                [ input [ type' "submit", value "Save" ] []
                , text " "
                , button [ onClick CancelExerciseForm ] [ text "Cancel" ]
                ]
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
