module SavingStatus exposing (..)

{-| SavingStatus is used to track the progress of multiple saving operations.
-}


{-| Store the status of the latest saving operation.
-}
type Model
    = NotSaving
    | InProgress Int Int
    | FinishedSaving


{-| Default the status to not currently saving.
-}
initial : Model
initial =
    NotSaving


{-| Start saving if currently not saving
-}
start : Model -> Model
start status =
    if status == NotSaving then
        InProgress 0 0
    else
        status


{-| Determine whether saving has completed.
-}
isFinished : Model -> Bool
isFinished status =
    status == FinishedSaving


{-| Increase the number of items queued to save.
-}
enqueue : Model -> Int -> Model
enqueue status num =
    case status of
        InProgress toSave hasSaved ->
            InProgress (toSave + num) hasSaved

        NotSaving ->
            NotSaving

        FinishedSaving ->
            FinishedSaving


{-| Increase the number of items that have been saved by 1.
-}
finishOne : Model -> Model
finishOne status =
    case status of
        InProgress toSave hasSaved ->
            if hasSaved + 1 == toSave then
                FinishedSaving
            else
                InProgress toSave (hasSaved + 1)

        NotSaving ->
            NotSaving

        FinishedSaving ->
            FinishedSaving
