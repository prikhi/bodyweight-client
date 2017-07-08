module Views.Routines exposing (..)

import Auth
import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (type_, value, name, selected, checked, class, id, disabled, for)
import Html.Events exposing (onClick, onSubmit, onInput, onCheck)
import Html.Keyed as Keyed
import Messages exposing (..)
import Model exposing (Model)
import Models.Exercises exposing (Exercise, ExerciseId)
import Models.Routines exposing (Routine)
import Models.Sections exposing (Section, SectionExercise, SectionForm)
import Routing exposing (Route(..), reverse)
import String
import Utils exposing (onSelectInt, findById, textField, intField, formField, navLink, htmlOrBlank, icon, anyInArray)


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
routinePage : Model -> Routine -> Html Msg
routinePage model { id, name, description, author, copyright } =
    let
        sections =
            List.filter (\s -> s.routine == id) model.sections

        canModify =
            case model.authStatus of
                Auth.Authorized user ->
                    user.isAdmin || user.id == author

                _ ->
                    False

        buttons =
            p []
                [ button
                    [ onClick <| NavigateTo <| RoutineEditRoute id
                    , class "btn btn-sm btn-secondary"
                    ]
                    [ text "Edit" ]
                , text " "
                , button
                    [ onClick <| DeleteRoutineClicked id
                    , class "btn btn-sm btn-danger"
                    ]
                    [ text "Delete" ]
                ]
    in
        div []
            [ h1 [] [ text name ]
            , htmlOrBlank canModify buttons
            , htmlOrBlank (not <| String.isEmpty copyright) <|
                p [] [ small [] [ text "Copyright: ", text copyright ] ]
            , htmlOrBlank (not <| String.isEmpty description) <|
                p [] [ text description ]
            , div [] <|
                List.map (sectionTable model) sections
            ]


{-| Render a Routine's Section as a Table.
-}
sectionTable : Model -> Section -> Html Msg
sectionTable model { id, name, description } =
    let
        sectionExercises =
            List.filter (\se -> se.section == id) model.sectionExercises
    in
        div []
            [ h2 [] [ text name ]
            , htmlOrBlank (not <| String.isEmpty description) <|
                p [] [ text description ]
            , table [ class "table table-sm table-striped" ]
                [ thead []
                    [ th [] [ text "Exercise" ]
                    , th [] [ text "Volume" ]
                    ]
                , tbody [] <| List.map (sectionExerciseRow model) sectionExercises
                ]
            ]


{-| Render a Section's SectionExercise as a Table Row.
-}
sectionExerciseRow : Model -> SectionExercise -> Html Msg
sectionExerciseRow model sectionExercise =
    let
        selectedExercises =
            getSelectedExercises model.exercises sectionExercise.exercises

        ifSelected pred =
            htmlOrBlank <| List.any pred selectedExercises

        setRepTimeCounts =
            [ ( List.any (not << .isHold) selectedExercises, toString sectionExercise.repCount )
            , ( List.any .isHold selectedExercises, toString sectionExercise.holdTime ++ "s" )
            ]
                |> List.filter Tuple.first
                |> List.map (\( _, count ) -> toString sectionExercise.setCount ++ "x" ++ count)
                |> List.intersperse ", "
                |> String.concat

        exerciseLink exercise =
            navLink exercise.name <| ExerciseRoute exercise.id

        exerciseLinks =
            List.map exerciseLink selectedExercises
                |> List.intersperse (text " > ")
                |> span []
    in
        tr []
            [ td [] [ exerciseLinks ]
            , td [] [ text setRepTimeCounts ]
            ]


{-| Get the selected Exercises from the list of all Exercises.
-}
getSelectedExercises : List Exercise -> Array ExerciseId -> List Exercise
getSelectedExercises exercises ids =
    Array.foldr (\id list -> findById id exercises :: list) [] ids
        |> List.filterMap identity


{-| Render a table of Routines.
-}
routineTable : List Routine -> Html Msg
routineTable routines =
    table [ class "table table-sm table-striped" ]
        [ thead []
            [ tr [] [ th [] [ text "Name" ] ] ]
        , tbody [] <| List.map routineRow routines
        ]


{-| Render a table row representing a Routine.
-}
routineRow : Routine -> Html Msg
routineRow { id, name } =
    tr [] [ td [] [ navLink name <| RoutineRoute id ] ]


{-| Render the form for creating an initial Routine before adding Exercises.
-}
addRoutineForm : Routine -> Html Msg
addRoutineForm routineForm =
    div []
        [ h1 [] [ text "Add Routine" ]
        , form [ onSubmit SubmitAddRoutineForm ]
            [ textField "Name" "name" routineForm.name (RoutineFormChange << RoutineNameChange)
            , p []
                [ input
                    [ class "btn btn-primary"
                    , type_ "submit"
                    , value "Save"
                    ]
                    []
                , text " "
                , button
                    [ class "btn btn-secondary"
                    , onClick CancelAddRoutineForm
                    ]
                    [ text "Cancel" ]
                ]
            ]
        ]


{-| Render the form for editing Routines & creating Sections/SectionExercises
-}
editRoutineForm : Model -> Html Msg
editRoutineForm { exercises, routineForm, sectionForms } =
    div []
        [ h1 [] [ text <| "Edit Routine - " ++ routineForm.name ]
        , textField "Routine Name" "name" routineForm.name (RoutineFormChange << RoutineNameChange)
        , br [] []
        , textField "Copyright" "copyright" routineForm.copyright (RoutineFormChange << RoutineCopyrightChange)
        , br [] []
        , formField "Description: " <|
            div []
                [ textarea
                    [ name "description"
                    , value routineForm.description
                    , onInput <| RoutineFormChange << RoutineDescriptionChange
                    ]
                    []
                ]
        , div [ class "form-check" ]
            [ label [ class "form-check-label" ]
                [ input
                    [ type_ "checkbox"
                    , class "form-check-input"
                    , checked routineForm.isPublic
                    , onCheck (RoutineFormChange << RoutinePublicChange)
                    ]
                    []
                , text " Is Public"
                ]
            ]
        , div [] <|
            Array.toList <|
                Array.indexedMap (editSectionForm exercises <| Array.length sectionForms)
                    sectionForms
        , p [ class "mt-1" ]
            [ button
                [ class "btn btn-sm btn-primary"
                , onClick (RoutineFormChange AddSection)
                ]
                [ text "Add Section" ]
            , text " "
            , button
                [ class "btn btn-sm btn-success"
                , onClick SubmitEditRoutineForm
                ]
                [ text "Save Routine" ]
            , text " "
            , button
                [ class "btn btn-sm btn-danger"
                , onClick CancelEditRoutineForm
                ]
                [ text "Cancel" ]
            ]
        ]


{-| Render the form for editing a single `Section` of a `Routine`.
-}
editSectionForm : List Exercise -> Int -> Int -> SectionForm -> Html Msg
editSectionForm exercises totalForms index ({ section } as form) =
    let
        formMsg =
            RoutineFormChange << SectionFormMsg index

        ( collapseIcon, collapseClass ) =
            Tuple.mapFirst icon <|
                if form.isCollapsed then
                    ( "chevron-right", "collapse" )
                else
                    ( "chevron-down", "" )

        totalSectionExercises =
            Array.length form.exercises

        sectionExerciseForms =
            Array.indexedMap (sectionExerciseForm exercises totalSectionExercises index)
                form.exercises
                |> Array.toList
                |> div [ class "row justify-content-center" ]

        ( resetButtonText, resetButtonClass ) =
            if section.id == 0 then
                ( "Remove", "btn-danger" )
            else
                ( "Reset", "btn-secondary" )
    in
        fieldset [ class "mb-4" ]
            [ legend []
                [ span
                    [ onClick <| formMsg ToggleCollapsed, class "pointer" ]
                    [ collapseIcon ]
                , text " Section: "
                , input
                    [ name "name"
                    , type_ "text"
                    , value section.name
                    , onInput <| formMsg << SectionNameChange
                    ]
                    []
                , text " "
                , button
                    [ class "btn btn-sm btn-secondary"
                    , onClick <| RoutineFormChange <| MoveSectionUp index
                    , disabled <| index == 0
                    ]
                    [ icon "arrow-up" ]
                , button
                    [ class "btn btn-sm btn-secondary"
                    , onClick <| RoutineFormChange <| MoveSectionDown index
                    , disabled <| index == totalForms - 1
                    ]
                    [ icon "arrow-down" ]
                ]
            , div [ class collapseClass ]
                [ div [ class "form-group" ]
                    [ label [ for <| "section-desc-" ++ toString index ]
                        [ text "Description:" ]
                    , textarea
                        [ name "description"
                        , id <| "section-desc-" ++ toString index
                        , value section.description
                        , onInput <| formMsg << SectionDescriptionChange
                        ]
                        []
                    ]
                ]
            , div [ class collapseClass ] [ sectionExerciseForms ]
            , div [ class <| "mt-1 " ++ collapseClass ]
                [ button
                    [ class "btn btn-sm btn-secondary"
                    , onClick <| formMsg <| AddSectionExercise
                    ]
                    [ text "Add Exercise" ]
                , text " "
                , button
                    [ class "btn btn-sm btn-success"
                    , onClick <| SaveSectionClicked index
                    ]
                    [ text "Save Section" ]
                , text " "
                , button
                    [ class <| "btn btn-sm " ++ resetButtonClass
                    , onClick <| RoutineFormChange <| CancelSection index
                    ]
                    [ text resetButtonText ]
                , text " "
                , if section.id /= 0 then
                    button
                        [ class "btn btn-sm btn-danger"
                        , onClick <| DeleteSectionClicked index section.id
                        ]
                        [ text "Delete Section" ]
                  else
                    text ""
                ]
            ]


{-| Render the form for editing a single `SectionExercise` of a `Section`
-}
sectionExerciseForm : List Exercise -> Int -> Int -> Int -> SectionExercise -> Html Msg
sectionExerciseForm exercises totalForms sectionIndex exerciseIndex form =
    let
        sectionMsg =
            RoutineFormChange << SectionFormMsg sectionIndex

        formMsg =
            sectionMsg << SectionExerciseFormMsg exerciseIndex

        progressionCount =
            Array.length form.exercises

        progressionName =
            Array.get (progressionCount - 1) form.exercises
                |> Maybe.andThen (flip findById exercises)
                |> Maybe.map
                    (\{ name } ->
                        if progressionCount > 1 then
                            name ++ " Progression"
                        else
                            name
                    )
                |> Maybe.withDefault ""

        unselectedExercises =
            exercises
                |> List.filter (\e -> not <| anyInArray ((==) e.id) form.exercises)

        exerciseInputs =
            Array.toList <|
                Array.indexedMap
                    (editExerciseSelect exercises sectionIndex exerciseIndex)
                    form.exercises

        addExerciseInput =
            Keyed.node "div"
                []
                [ ( toString <| Array.length form.exercises
                  , addExerciseSelect unselectedExercises sectionIndex exerciseIndex
                  )
                ]

        selectedExercises =
            getSelectedExercises exercises form.exercises

        ifSelected pred =
            htmlOrBlank <| List.any pred selectedExercises

        setInput =
            if List.length selectedExercises /= 0 then
                intField "Sets" "sets" (toString form.setCount) <|
                    formMsg
                        << ChangeSetCount
            else
                text ""

        multipleExercisesSelected =
            Array.length form.exercises > 1

        repInput =
            ifSelected (not << .isHold) <|
                span []
                    [ intField "Reps" "reps" (toString form.repCount) <|
                        formMsg
                            << ChangeRepCount
                    , text " "
                    , htmlOrBlank multipleExercisesSelected <|
                        intField "Reps to Progress"
                            "progress-reps"
                            (toString form.repsToProgress)
                            (formMsg << ChangeRepProgress)
                    ]

        holdInput =
            ifSelected .isHold <|
                span []
                    [ intField "Hold Time" "hold-time" (toString form.holdTime) <|
                        formMsg
                            << ChangeHoldTime
                    , text " "
                    , htmlOrBlank multipleExercisesSelected <|
                        intField "Time to Progress"
                            "progress-time"
                            (toString form.timeToProgress)
                            (formMsg << ChangeHoldProgress)
                    ]
    in
        div [ class "col-12 col-md-6 col-xl-4" ]
            [ div [ class "card mb-2" ]
                [ h5 [ class "card-header clearfix" ]
                    [ span []
                        [ text <|
                            "Exercise #"
                                ++ toString (exerciseIndex + 1)
                                ++ " "
                                ++ progressionName
                        ]
                    , div [ class "float-right" ]
                        [ button
                            [ class "btn btn-sm btn-secondary"
                            , onClick <| sectionMsg <| MoveExerciseUp exerciseIndex
                            , disabled <| exerciseIndex == 0
                            ]
                            [ icon "arrow-up" ]
                        , button
                            [ class "btn btn-sm btn-secondary"
                            , onClick <| sectionMsg <| MoveExerciseDown exerciseIndex
                            , disabled <| exerciseIndex == totalForms - 1
                            ]
                            [ icon "arrow-down" ]
                        , text " "
                        ]
                    , div [ class "mt-1" ]
                        [ button
                            [ class "btn btn-sm btn-success"
                            , onClick <| SaveSectionExerciseClicked sectionIndex exerciseIndex
                            ]
                            [ icon "save" ]
                        , button
                            [ class "btn btn-sm btn-secondary"
                            , onClick <| sectionMsg <| CancelSectionExercise exerciseIndex
                            ]
                            [ icon <|
                                if form.id /= 0 then
                                    "refresh"
                                else
                                    "remove"
                            ]
                        , if form.id /= 0 then
                            button
                                [ class "btn btn-sm btn-danger"
                                , onClick <|
                                    DeleteSectionExerciseClicked sectionIndex exerciseIndex form.id
                                ]
                                [ icon "remove" ]
                          else
                            text ""
                        ]
                    ]
                , div [ class "card-block" ]
                    [ div [] exerciseInputs
                    , addExerciseInput
                    , div [ class "short-inputs" ]
                        [ setInput
                        , text " "
                        , repInput
                        , holdInput
                        ]
                    ]
                ]
            ]


{-| Render the select element for adding new `Exercises` to a `SectionExercise`.
-}
addExerciseSelect : List Exercise -> Int -> Int -> Html Msg
addExerciseSelect exercises sectionIndex exerciseIndex =
    select
        [ name "exercise"
        , class "form-control add-exercise-select"
        , onSelectInt <|
            RoutineFormChange
                << SectionFormMsg sectionIndex
                << SectionExerciseFormMsg exerciseIndex
                << AddExercise
        ]
    <|
        option [ selected True ] [ text "Add a Progression" ]
            :: List.map (exerciseOption Nothing) exercises


{-| Render the select element for editing the `Exercises` of a `SectionExercise`.
-}
editExerciseSelect : List Exercise -> Int -> Int -> Int -> ExerciseId -> Html Msg
editExerciseSelect exercises sectionIndex exerciseIndex index exerciseId =
    let
        formMsg =
            RoutineFormChange
                << SectionFormMsg sectionIndex
                << SectionExerciseFormMsg exerciseIndex
    in
        div [ class "input-group" ]
            [ select
                [ name <| "exercise-" ++ toString index
                , class "form-control"
                , onSelectInt <| formMsg << ChangeExercise index
                ]
              <|
                List.map (exerciseOption <| Just exerciseId) exercises
            , text " "
            , span [ onClick <| formMsg <| RemoveExercise index, class "input-group-addon" ]
                [ icon "times fa-lg text-danger" ]
            ]


{-| Render an option element for an `Exercise` select element.
-}
exerciseOption : Maybe ExerciseId -> Exercise -> Html Msg
exerciseOption maybeId exercise =
    option
        [ value <| toString exercise.id
        , selected (Maybe.map (\id -> id == exercise.id) maybeId |> Maybe.withDefault False)
        ]
        [ text exercise.name ]
