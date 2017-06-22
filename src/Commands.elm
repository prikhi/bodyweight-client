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
fetchForRoute : Auth.Status -> Route -> Cmd Msg
fetchForRoute authStatus route =
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
            fetchExercises authStatus

        ExerciseAddRoute ->
            Cmd.none

        ExerciseRoute id ->
            fetchExercise authStatus id

        ExerciseEditRoute id ->
            fetchExercise authStatus id

        RoutinesRoute ->
            fetchRoutines authStatus

        RoutineAddRoute ->
            Cmd.none

        RoutineRoute id ->
            Cmd.batch
                [ fetchExercises authStatus
                , fetchRoutine authStatus id
                , fetchSections authStatus
                , fetchSectionExercises authStatus
                ]

        RoutineEditRoute id ->
            Cmd.batch
                [ fetchExercises authStatus
                , fetchRoutine authStatus id
                , fetchSections authStatus
                , fetchSectionExercises authStatus
                ]

        NotFoundRoute ->
            Cmd.none


{-| Add a `Auth-Token` Header if the User is Authorized.
-}
withAuthHeader : Auth.Status -> HttpBuilder.RequestBuilder -> HttpBuilder.RequestBuilder
withAuthHeader status builder =
    case status of
        Auth.Authorized { authToken } ->
            withHeader "Auth-Token" authToken builder

        _ ->
            builder


{-| Perform a request on the backend server, mapping the `Result` to some message.
-}
performApiRequest : (Result a b -> msg) -> Task.Task a (HttpBuilder.Response b) -> Cmd msg
performApiRequest msg =
    Task.attempt (Result.map .data >> msg)


{-| Fetch data from the backend server.
-}
fetch : String -> Decode.Decoder a -> (HttpMsg a -> msg) -> Auth.Status -> Cmd msg
fetch url decoder msg authStatus =
    get ("/api/" ++ url)
        |> withAuthHeader authStatus
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Create data on the backend server.
-}
create : String -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Auth.Status -> Cmd msg
create url jsonValue decoder msg authStatus =
    post ("/api/" ++ url)
        |> withJsonBody jsonValue
        |> withAuthHeader authStatus
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Update a resource on the backend server.
-}
update : String -> Int -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Auth.Status -> Cmd msg
update url id jsonValue decoder msg authStatus =
    put ("/api/" ++ url ++ "/" ++ toString id)
        |> withJsonBody jsonValue
        |> withAuthHeader authStatus
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Delete a resource from the backend server.
-}
delete : String -> Int -> (HttpMsg Int -> msg) -> Auth.Status -> Cmd msg
delete url id msg authStatus =
    HttpBuilder.delete ("/api/" ++ url ++ "/" ++ toString id)
        |> withAuthHeader authStatus
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
        Auth.Anonymous


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
        Auth.Anonymous


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
        Auth.Anonymous



{- Exercises -}


fetchExercises : Auth.Status -> Cmd Msg
fetchExercises authStatus =
    fetch "exercises" (Decode.field "exercise" (Decode.list exerciseDecoder)) FetchExercises authStatus


fetchExercise : Auth.Status -> ExerciseId -> Cmd Msg
fetchExercise authStatus id =
    fetch ("exercises/" ++ toString id) (Decode.field "exercise" exerciseDecoder) FetchExercise authStatus


createExercise : Auth.Status -> Exercise -> Cmd Msg
createExercise authStatus exercise =
    create "exercises"
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        (Decode.field "exercise" exerciseDecoder)
        CreateExercise
        authStatus


updateExercise : Auth.Status -> Exercise -> Cmd Msg
updateExercise authStatus exercise =
    update "exercises"
        exercise.id
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        (Decode.field "exercise" exerciseDecoder)
        CreateExercise
        authStatus


deleteExercise : Auth.Status -> ExerciseId -> Cmd Msg
deleteExercise authStatus exerciseId =
    delete "exercises" exerciseId DeleteExercise authStatus



{- Routines -}


fetchRoutines : Auth.Status -> Cmd Msg
fetchRoutines authStatus =
    fetch "routines" (Decode.field "routine" (Decode.list routineDecoder)) FetchRoutines authStatus


fetchRoutine : Auth.Status -> RoutineId -> Cmd Msg
fetchRoutine authStatus routineId =
    fetch ("routines/" ++ toString routineId) (Decode.field "routine" routineDecoder) FetchRoutine authStatus


createRoutine : Auth.Status -> Routine -> Cmd Msg
createRoutine authStatus routine =
    create "routines"
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        (Decode.field "routine" routineDecoder)
        CreateRoutine
        authStatus


updateRoutine : Auth.Status -> Routine -> Cmd Msg
updateRoutine authStatus routine =
    update "routines"
        routine.id
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        (Decode.field "routine" routineDecoder)
        UpdateRoutine
        authStatus


deleteRoutine : Auth.Status -> RoutineId -> Cmd Msg
deleteRoutine authStatus routineId =
    delete "routines" routineId DeleteRoutine authStatus



{- Sections -}


fetchSections : Auth.Status -> Cmd Msg
fetchSections authStatus =
    fetch "sections" (Decode.field "section" (Decode.list sectionDecoder)) FetchSections authStatus


createSection : Auth.Status -> Int -> Section -> Cmd Msg
createSection authStatus index section =
    create "sections"
        (Encode.object [ ( "section", sectionEncoder { section | order = index } ) ])
        (Decode.field "section" sectionDecoder)
        (CreateSection index)
        authStatus


updateSection : Auth.Status -> Int -> Section -> Cmd Msg
updateSection authStatus index section =
    update "sections"
        section.id
        (Encode.object [ ( "section", sectionEncoder { section | order = index } ) ])
        (Decode.field "section" sectionDecoder)
        (UpdateSection index)
        authStatus


deleteSection : Auth.Status -> Int -> SectionId -> Cmd Msg
deleteSection authStatus index id =
    delete "sections" id (DeleteSection index) authStatus



{- Section Exercises -}


fetchSectionExercises : Auth.Status -> Cmd Msg
fetchSectionExercises authStatus =
    fetch "sectionExercises"
        (Decode.field "sectionExercise" (Decode.list sectionExerciseDecoder))
        FetchSectionExercises
        authStatus


createSectionExercise : Auth.Status -> Int -> Int -> SectionExercise -> Cmd Msg
createSectionExercise authStatus sectionIndex exerciseIndex sectionExercise =
    create "sectionExercises"
        (Encode.object
            [ ( "sectionExercise"
              , sectionExerciseEncoder { sectionExercise | order = exerciseIndex }
              )
            ]
        )
        (Decode.field "sectionExercise" sectionExerciseDecoder)
        (CreateSectionExercise sectionIndex exerciseIndex)
        authStatus


updateSectionExercise : Auth.Status -> Int -> Int -> SectionExercise -> Cmd Msg
updateSectionExercise authStatus sectionIndex exerciseIndex sectionExercise =
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
        authStatus


deleteSectionExercise : Auth.Status -> Int -> Int -> SectionExerciseId -> Cmd Msg
deleteSectionExercise authStatus sectionIndex exerciseIndex id =
    delete "sectionExercises" id (DeleteSectionExercise sectionIndex exerciseIndex) authStatus
