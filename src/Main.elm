module Main exposing (main)

import Commands exposing (fetchForRoute, createExercise)
import Messages exposing (Msg(..), HttpMsg, ExerciseFormMessage(..))
import Model exposing (Model, initialModel)
import Models.Exercises exposing (initialExercise)
import Navigation
import Routing exposing (Route(..), routeFromResult, reverse, parser)
import View exposing (view)


{-| Hook the update/view functions up to the initial model.
-}
main : Program Never
main =
    Navigation.program parser
        { init = init
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = always Sub.none
        , view = view
        }


{-| Generate the initial model & commands for the route.
-}
init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        route =
            routeFromResult result
    in
        ( initialModel route, fetchForRoute route )


{-| Update the Model's `route` when the URL changes.
-}
urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        route =
            routeFromResult result

        updatedModel =
            { model | route = route }

        updateModel oldModel =
            case route of
                ExerciseAddRoute ->
                    { oldModel | exerciseForm = initialExercise }

                _ ->
                    oldModel
    in
        ( updateModel updatedModel, fetchForRoute route )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateTo route ->
            ( model, Navigation.newUrl <| reverse route )

        ExerciseFormChange subMsg ->
            updateExerciseForm subMsg model

        SubmitExerciseForm ->
            ( model, createExercise model.exerciseForm )

        CancelExerciseForm ->
            ( model, Navigation.newUrl <| reverse ExercisesRoute )

        FetchExercises (Ok newExercises) ->
            ( { model | exercises = newExercises }, Cmd.none )

        FetchExercises (Err _) ->
            ( model, Cmd.none )

        FetchExercise (Ok newExercise) ->
            ( { model | exercises = newExercise :: model.exercises }, Cmd.none )

        FetchExercise (Err _) ->
            ( model, Cmd.none )

        CreateExercise (Ok newExercise) ->
            ( { model | exercises = newExercise :: model.exercises }
            , Navigation.newUrl <| reverse <| ExerciseRoute newExercise.id
            )

        CreateExercise (Err _) ->
            ( model, Cmd.none )


updateExerciseForm : ExerciseFormMessage -> Model -> ( Model, Cmd msg )
updateExerciseForm msg ({ exerciseForm } as model) =
    let
        updatedForm =
            case msg of
                NameChange newName ->
                    { exerciseForm | name = newName }

                DescriptionChange newDescription ->
                    { exerciseForm | description = newDescription }
    in
        ( { model | exerciseForm = updatedForm }, Cmd.none )
