module Commands exposing (..)

import Array exposing (Array)
import Auth
import HttpBuilder exposing (send, stringReader, jsonReader, get, post, put, withHeader, withJsonBody)
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(..), HttpMsg)
import Models.Exercises exposing (Exercise, ExerciseId, exerciseDecoder, exerciseEncoder)
import Models.Routines exposing (Routine, RoutineId, routineDecoder, routineEncoder)
import Models.Sections exposing (Section, SectionExercise, SectionId, SectionExerciseId, sectionDecoder, sectionEncoder, sectionExerciseDecoder, sectionExerciseEncoder)
import Routing exposing (Route(..))
import Task


{-| Return a command that fetches any relevant data for the Route.
-}
fetchForRoute : Route -> Cmd Msg
fetchForRoute route =
    case route of
        HomeRoute ->
            Cmd.none

        LoginRoute ->
            Cmd.none

        RegisterRoute ->
            Cmd.none

        LogoutRoute ->
            Cmd.none

        ExercisesRoute ->
            fetchExercises

        ExerciseAddRoute ->
            Cmd.none

        ExerciseRoute id ->
            fetchExercise id

        ExerciseEditRoute id ->
            fetchExercise id

        RoutinesRoute ->
            fetchRoutines

        RoutineAddRoute ->
            Cmd.none

        RoutineRoute id ->
            Cmd.batch
                [ fetchExercises
                , fetchRoutine id
                , fetchSections
                , fetchSectionExercises
                ]

        RoutineEditRoute id ->
            Cmd.batch
                [ fetchExercises
                , fetchRoutine id
                , fetchSections
                , fetchSectionExercises
                ]

        NotFoundRoute ->
            Cmd.none


{-| Perform a request on the backend server, mapping the `Result` to some message.
-}
performApiRequest : (Result a b -> msg) -> Task.Task a (HttpBuilder.Response b) -> Cmd msg
performApiRequest msg =
    Task.attempt (Result.map .data >> msg)


{-| Fetch data from the backend server.
-}
fetch : String -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
fetch url decoder msg =
    get ("/api/" ++ url)
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Create data on the backend server.
-}
create : String -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
create url jsonValue decoder msg =
    post ("/api/" ++ url)
        |> withJsonBody jsonValue
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Update a resource on the backend server.
-}
update : String -> Int -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Cmd msg
update url id jsonValue decoder msg =
    put ("/api/" ++ url ++ "/" ++ toString id)
        |> withJsonBody jsonValue
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Delete a resource from the backend server.
-}
delete : String -> Int -> (HttpMsg Int -> msg) -> Cmd msg
delete url id msg =
    HttpBuilder.delete ("/api/" ++ url ++ "/" ++ toString id)
        |> send (jsonReader (Decode.succeed id)) stringReader
        |> performApiRequest msg


{-| Either create or update a resource, depending on whether it has an `id` of 0 or not.
-}
createOrUpdate :
    ({ a | id : Int } -> Cmd msg)
    -> ({ a | id : Int } -> Cmd msg)
    -> { a | id : Int }
    -> Cmd msg
createOrUpdate createFunc updateFunc item =
    if item.id == 0 then
        createFunc item
    else
        updateFunc item


{-| Create a batch of create/update commands from an array of items with `id`s.
-}
createOrUpdateArray :
    (a -> { b | id : Int })
    -> (Int -> { b | id : Int } -> Cmd Msg)
    -> (Int -> { b | id : Int } -> Cmd Msg)
    -> Array a
    -> Cmd Msg
createOrUpdateArray selector createFunc updateFunc =
    Array.indexedMap
        (\i -> selector >> createOrUpdate (createFunc i) (updateFunc i))
        >> Array.toList
        >> Cmd.batch



{- Auth -}


register : Auth.Form -> Cmd Msg
register form =
    create "users/register"
        (Encode.object
            [ ( "registrationName", Encode.string form.username )
            , ( "registrationPassword", Encode.string form.password )
            , ( "registrationEmail", Encode.string "" )
            ]
        )
        (Decode.field "user" Auth.userDecoder)
        AuthorizeUser


login : Auth.Form -> Cmd Msg
login form =
    create "users/login"
        (Encode.object
            [ ( "loginName", Encode.string form.username )
            , ( "loginPassword", Encode.string form.password )
            ]
        )
        (Decode.field "user" Auth.userDecoder)
        AuthorizeUser


reauthorize : String -> Int -> Cmd Msg
reauthorize authToken userId =
    create "users/reauthorize"
        (Encode.object
            [ ( "authToken", Encode.string authToken )
            , ( "authUserId", Encode.int userId )
            ]
        )
        (Decode.field "user" Auth.userDecoder)
        AuthorizeUser



{- Exercises -}


fetchExercises : Cmd Msg
fetchExercises =
    fetch "exercises" (Decode.field "exercise" (Decode.list exerciseDecoder)) FetchExercises


fetchExercise : ExerciseId -> Cmd Msg
fetchExercise id =
    fetch ("exercises/" ++ toString id) (Decode.field "exercise" exerciseDecoder) FetchExercise


createExercise : Exercise -> Cmd Msg
createExercise exercise =
    create "exercises"
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        (Decode.field "exercise" exerciseDecoder)
        CreateExercise


updateExercise : Exercise -> Cmd Msg
updateExercise exercise =
    update "exercises"
        exercise.id
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        (Decode.field "exercise" exerciseDecoder)
        CreateExercise


deleteExercise : ExerciseId -> Cmd Msg
deleteExercise exerciseId =
    delete "exercises" exerciseId DeleteExercise



{- Routines -}


fetchRoutines : Cmd Msg
fetchRoutines =
    fetch "routines" (Decode.field "routine" (Decode.list routineDecoder)) FetchRoutines


fetchRoutine : RoutineId -> Cmd Msg
fetchRoutine routineId =
    fetch ("routines/" ++ toString routineId) (Decode.field "routine" routineDecoder) FetchRoutine


createRoutine : Routine -> Cmd Msg
createRoutine routine =
    create "routines"
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        (Decode.field "routine" routineDecoder)
        CreateRoutine


updateRoutine : Routine -> Cmd Msg
updateRoutine routine =
    update "routines"
        routine.id
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        (Decode.field "routine" routineDecoder)
        UpdateRoutine


deleteRoutine : RoutineId -> Cmd Msg
deleteRoutine routineId =
    delete "routines" routineId DeleteRoutine



{- Sections -}


fetchSections : Cmd Msg
fetchSections =
    fetch "sections" (Decode.field "section" (Decode.list sectionDecoder)) FetchSections


createSection : Int -> Section -> Cmd Msg
createSection index section =
    create "sections"
        (Encode.object [ ( "section", sectionEncoder { section | order = index } ) ])
        (Decode.field "section" sectionDecoder)
        (CreateSection index)


updateSection : Int -> Section -> Cmd Msg
updateSection index section =
    update "sections"
        section.id
        (Encode.object [ ( "section", sectionEncoder { section | order = index } ) ])
        (Decode.field "section" sectionDecoder)
        (UpdateSection index)


deleteSection : Int -> SectionId -> Cmd Msg
deleteSection index id =
    delete "sections" id (DeleteSection index)



{- Section Exercises -}


fetchSectionExercises : Cmd Msg
fetchSectionExercises =
    fetch "sectionExercises"
        (Decode.field "sectionExercise" (Decode.list sectionExerciseDecoder))
        FetchSectionExercises


createSectionExercise : Int -> Int -> SectionExercise -> Cmd Msg
createSectionExercise sectionIndex exerciseIndex sectionExercise =
    create "sectionExercises"
        (Encode.object
            [ ( "sectionExercise"
              , sectionExerciseEncoder { sectionExercise | order = exerciseIndex }
              )
            ]
        )
        (Decode.field "sectionExercise" sectionExerciseDecoder)
        (CreateSectionExercise sectionIndex exerciseIndex)


updateSectionExercise : Int -> Int -> SectionExercise -> Cmd Msg
updateSectionExercise sectionIndex exerciseIndex sectionExercise =
    update "sectionExercises"
        sectionExercise.id
        (Encode.object
            [ ( "sectionExercise"
              , sectionExerciseEncoder { sectionExercise | order = exerciseIndex }
              )
            ]
        )
        (Decode.field "sectionExercise" sectionExerciseDecoder)
        (UpdateSectionExercise sectionIndex exerciseIndex)


deleteSectionExercise : Int -> Int -> SectionExerciseId -> Cmd Msg
deleteSectionExercise sectionIndex exerciseIndex id =
    delete "sectionExercises" id (DeleteSectionExercise sectionIndex exerciseIndex)
