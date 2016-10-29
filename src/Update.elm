module Update exposing (urlUpdate, update)

import Commands exposing (fetchForRoute, createExercise, updateExercise, deleteExercise)
import Messages exposing (Msg(..), HttpMsg, ExerciseFormMessage(..))
import Model exposing (Model, initialModel)
import Models.Exercises exposing (ExerciseId, Exercise, initialExercise)
import Navigation
import Routing exposing (Route(..), routeFromResult, reverse, parser)


{-| Update the Model's `route` when the URL changes.
-}
urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        route =
            routeFromResult result

        updatedModel =
            case route of
                ExerciseAddRoute ->
                    { model | exerciseForm = initialExercise }

                ExerciseEditRoute id ->
                    setExerciseForm id model

                _ ->
                    model
    in
        ( { updatedModel | route = route }, fetchForRoute route )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateTo route ->
            ( model, Navigation.newUrl <| reverse route )

        DeleteExerciseClicked exerciseId ->
            List.filter (\x -> x.id == exerciseId) model.exercises
                |> List.head
                |> Maybe.map (deleteExercise << .id)
                |> Maybe.withDefault Cmd.none
                |> \cmd -> ( model, cmd )

        ExerciseFormChange subMsg ->
            ( { model | exerciseForm = updateExerciseForm subMsg model }, Cmd.none )

        SubmitExerciseForm ->
            if model.exerciseForm.id == 0 then
                ( model, createExercise model.exerciseForm )
            else
                ( model, updateExercise model.exerciseForm )

        CancelExerciseForm ->
            if model.exerciseForm.id == 0 then
                ( model, Navigation.newUrl <| reverse ExercisesRoute )
            else
                ( model, Navigation.newUrl <| reverse <| ExerciseRoute model.exerciseForm.id )

        FetchExercises (Ok newExercises) ->
            ( { model | exercises = newExercises }, Cmd.none )

        FetchExercises (Err _) ->
            ( model, Cmd.none )

        FetchExercise (Ok newExercise) ->
            let
                updatedModel =
                    { model | exercises = newExercise :: model.exercises }
            in
                case model.route of
                    ExerciseEditRoute id ->
                        ( setExerciseForm id updatedModel, Cmd.none )

                    _ ->
                        ( updatedModel, Cmd.none )

        FetchExercise (Err _) ->
            ( model, Cmd.none )

        CreateExercise (Ok newExercise) ->
            ( { model | exercises = newExercise :: model.exercises }
            , Navigation.newUrl <| reverse <| ExerciseRoute newExercise.id
            )

        CreateExercise (Err _) ->
            ( model, Cmd.none )

        DeleteExercise (Ok exerciseId) ->
            ( { model | exercises = List.filter (\x -> x.id /= exerciseId) model.exercises }
            , Navigation.newUrl <| reverse <| ExercisesRoute
            )

        DeleteExercise (Err _) ->
            ( model, Cmd.none )

        FetchRoutines (Ok newRoutines) ->
            ( { model | routines = newRoutines }, Cmd.none )

        FetchRoutines (Err _) ->
            ( model, Cmd.none )

        FetchRoutine (Ok newRoutine) ->
            ( { model | routines = newRoutine :: model.routines }, Cmd.none )

        FetchRoutine (Err _) ->
            ( model, Cmd.none )


{-| Set the Exercise Form to the Exercise with the specified Id.
-}
setExerciseForm : ExerciseId -> Model -> Model
setExerciseForm id model =
    let
        newForm =
            List.filter (\x -> x.id == id) model.exercises
                |> List.head
                |> Maybe.withDefault initialExercise
    in
        { model | exerciseForm = newForm }


{-| Update the Exercise Form when a field has changed.
-}
updateExerciseForm : ExerciseFormMessage -> Model -> Exercise
updateExerciseForm msg ({ exerciseForm } as model) =
    case msg of
        NameChange newName ->
            { exerciseForm | name = newName }

        DescriptionChange newDescription ->
            { exerciseForm | description = newDescription }

        IsHoldChange newHold ->
            { exerciseForm | isHold = newHold }

        YoutubeChange newYoutube ->
            { exerciseForm | youtubeIds = newYoutube }

        AmazonChange newAmazon ->
            { exerciseForm | amazonIds = newAmazon }
