module RoutineForm exposing (..)

import Array
import Messages exposing (..)
import Model exposing (Model)
import Models.Sections exposing (SectionExercise, SectionForm, initialSectionExercise, initialSectionForm, initialSection)
import Utils exposing (findById, updateByIndex, removeByIndex, indexIsSaved, swapIndexes)


{-| Update the Routine Form.
-}
updateRoutineForm : RoutineFormMessage -> Model -> Model
updateRoutineForm msg ({ routineForm, sectionForms } as model) =
    case msg of
        RoutineNameChange newName ->
            let
                updatedForm =
                    { routineForm | name = newName }
            in
                { model | routineForm = updatedForm }

        RoutineCopyrightChange newCopyright ->
            let
                updatedForm =
                    { routineForm | copyright = newCopyright }
            in
                { model | routineForm = updatedForm }

        RoutinePublicChange isPublic ->
            let
                updatedForm =
                    { routineForm | isPublic = isPublic }
            in
                { model | routineForm = updatedForm }

        MoveSectionUp sectionIndex ->
            { model | sectionForms = swapIndexes sectionIndex (sectionIndex - 1) sectionForms }

        MoveSectionDown sectionIndex ->
            { model | sectionForms = swapIndexes sectionIndex (sectionIndex + 1) sectionForms }

        AddSection ->
            { model
                | sectionForms =
                    Array.push (initialSectionForm routineForm.id) sectionForms
            }

        CancelSection index ->
            let
                isEditing =
                    Array.map (\{ section } -> section) sectionForms
                        |> indexIsSaved index

                updatedForms =
                    if isEditing then
                        updateByIndex index (resetSectionForm model) sectionForms
                    else
                        removeByIndex index sectionForms
            in
                { model | sectionForms = updatedForms }

        SectionFormMsg index subMsg ->
            { model
                | sectionForms =
                    updateByIndex index (updateSectionForm subMsg model) sectionForms
            }


{-| Reset a SectionForm to it's pre-modified state.
-}
resetSectionForm : Model -> SectionForm -> SectionForm
resetSectionForm model form =
    { section =
        findById form.section.id model.sections
            |> Maybe.withDefault (initialSection form.section.routine)
    , exercises =
        List.filter (\x -> x.section == form.section.id) model.sectionExercises
            |> Array.fromList
    , isCollapsed = False
    }


{-| Update a single Section form.
-}
updateSectionForm : SectionFormMessage -> Model -> SectionForm -> SectionForm
updateSectionForm msg model ({ section, exercises } as sectionForm) =
    case msg of
        ToggleCollapsed ->
            { sectionForm | isCollapsed = not sectionForm.isCollapsed }

        SectionNameChange newName ->
            let
                updatedSection =
                    { section | name = newName }
            in
                { sectionForm | section = updatedSection }

        MoveExerciseUp index ->
            { sectionForm | exercises = swapIndexes index (index - 1) sectionForm.exercises }

        MoveExerciseDown index ->
            { sectionForm | exercises = swapIndexes index (index + 1) sectionForm.exercises }

        AddSectionExercise ->
            { sectionForm
                | exercises =
                    Array.push (initialSectionExercise section.id) exercises
            }

        CancelSectionExercise index ->
            let
                newExercises =
                    if indexIsSaved index exercises then
                        updateByIndex index
                            (resetSectionExerciseForm model)
                            exercises
                    else
                        removeByIndex index exercises
            in
                { sectionForm | exercises = newExercises }

        SectionExerciseFormMsg index subMsg ->
            { sectionForm
                | exercises =
                    updateByIndex index (updateSectionExerciseForm subMsg) exercises
            }


{-| Reset the SectionExercise to the un-modified version.
-}
resetSectionExerciseForm : Model -> SectionExercise -> SectionExercise
resetSectionExerciseForm { sectionExercises } form =
    findById form.id sectionExercises
        |> Maybe.withDefault (initialSectionExercise form.section)


{-| Update a single SectionExercise form.
-}
updateSectionExerciseForm : SectionExerciseFormMessage -> SectionExercise -> SectionExercise
updateSectionExerciseForm msg ({ exercises } as form) =
    case msg of
        AddExercise id ->
            { form | exercises = Array.push id exercises }

        ChangeExercise index id ->
            { form | exercises = Array.set index id exercises }

        RemoveExercise index ->
            { form | exercises = removeByIndex index exercises }

        ChangeSetCount newSetCount ->
            { form | setCount = newSetCount }

        ChangeRepCount newRepCount ->
            { form | repCount = newRepCount }

        ChangeRepProgress newProgressCount ->
            { form | repsToProgress = newProgressCount }

        ChangeHoldTime newHoldTime ->
            { form | holdTime = newHoldTime }

        ChangeHoldProgress newProgressTime ->
            { form | timeToProgress = newProgressTime }
