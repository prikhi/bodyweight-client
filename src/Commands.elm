module Commands exposing (..)

import Api.Endpoints as Endpoints
import Array exposing (Array)
import Auth exposing (UserId)
import HttpBuilder exposing (send, stringReader, jsonReader, get, post, put, withHeader, withJsonBody)
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(..), HttpMsg)
import Models.Exercises exposing (Exercise, ExerciseId, exerciseDecoder, exerciseEncoder)
import Models.Routines exposing (Routine, RoutineId, routineDecoder, routineEncoder)
import Models.Sections exposing (Section, SectionExercise, SectionId, SectionExerciseId, sectionDecoder, sectionEncoder, sectionExerciseDecoder, sectionExerciseEncoder)
import Models.Subscriptions exposing (SubscriptionId, subscriptionDecoder, subscriptionEncoder)
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
fetch : Endpoints.Endpoint -> Decode.Decoder a -> (HttpMsg a -> msg) -> Auth.Status -> Cmd msg
fetch endpoint decoder msg authStatus =
    get (Endpoints.endpointToURL endpoint)
        |> withAuthHeader authStatus
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Create data on the backend server.
-}
create : Endpoints.Endpoint -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Auth.Status -> Cmd msg
create endpoint jsonValue decoder msg authStatus =
    post (Endpoints.endpointToURL endpoint)
        |> withJsonBody jsonValue
        |> withAuthHeader authStatus
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Update a resource on the backend server.
-}
update : Endpoints.Endpoint -> Encode.Value -> Decode.Decoder a -> (HttpMsg a -> msg) -> Auth.Status -> Cmd msg
update endpoint jsonValue decoder msg authStatus =
    put (Endpoints.endpointToURL endpoint)
        |> withJsonBody jsonValue
        |> withAuthHeader authStatus
        |> send (jsonReader decoder) stringReader
        |> performApiRequest msg


{-| Delete a resource from the backend server.
-}
delete : (Int -> Endpoints.Endpoint) -> Int -> (HttpMsg Int -> msg) -> Auth.Status -> Cmd msg
delete endpoint id msg authStatus =
    HttpBuilder.delete (Endpoints.endpointToURL <| endpoint id)
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
    create Endpoints.Register
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
    create Endpoints.Login
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
    create Endpoints.Reauthorize
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
fetchExercises =
    fetch Endpoints.Exercises (Decode.field "exercise" (Decode.list exerciseDecoder)) FetchExercises


fetchExercise : Auth.Status -> ExerciseId -> Cmd Msg
fetchExercise authStatus id =
    fetch (Endpoints.Exercise id) (Decode.field "exercise" exerciseDecoder) FetchExercise authStatus


createExercise : Auth.Status -> Exercise -> Cmd Msg
createExercise authStatus exercise =
    create Endpoints.Exercises
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        (Decode.field "exercise" exerciseDecoder)
        CreateExercise
        authStatus


updateExercise : Auth.Status -> Exercise -> Cmd Msg
updateExercise authStatus exercise =
    update (Endpoints.Exercise exercise.id)
        (Encode.object [ ( "exercise", exerciseEncoder exercise ) ])
        (Decode.field "exercise" exerciseDecoder)
        CreateExercise
        authStatus


deleteExercise : Auth.Status -> ExerciseId -> Cmd Msg
deleteExercise authStatus exerciseId =
    delete Endpoints.Exercise exerciseId DeleteExercise authStatus



{- Routines -}


fetchRoutines : Auth.Status -> Cmd Msg
fetchRoutines =
    fetch Endpoints.Routines (Decode.field "routine" (Decode.list routineDecoder)) FetchRoutines


fetchRoutine : Auth.Status -> RoutineId -> Cmd Msg
fetchRoutine authStatus routineId =
    fetch (Endpoints.Routine routineId) (Decode.field "routine" routineDecoder) FetchRoutine authStatus


createRoutine : Auth.Status -> Routine -> Cmd Msg
createRoutine authStatus routine =
    create Endpoints.Routines
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        (Decode.field "routine" routineDecoder)
        CreateRoutine
        authStatus


updateRoutine : Auth.Status -> Routine -> Cmd Msg
updateRoutine authStatus routine =
    update (Endpoints.Routine routine.id)
        (Encode.object [ ( "routine", routineEncoder routine ) ])
        (Decode.field "routine" routineDecoder)
        UpdateRoutine
        authStatus


deleteRoutine : Auth.Status -> RoutineId -> Cmd Msg
deleteRoutine authStatus routineId =
    delete Endpoints.Routine routineId DeleteRoutine authStatus



{- Sections -}


fetchSections : Auth.Status -> Cmd Msg
fetchSections =
    fetch Endpoints.Sections (Decode.field "section" (Decode.list sectionDecoder)) FetchSections


createSection : Auth.Status -> Int -> Section -> Cmd Msg
createSection authStatus index section =
    create Endpoints.Sections
        (Encode.object [ ( "section", sectionEncoder { section | order = index } ) ])
        (Decode.field "section" sectionDecoder)
        (CreateSection index)
        authStatus


updateSection : Auth.Status -> Int -> Section -> Cmd Msg
updateSection authStatus index section =
    update (Endpoints.Section section.id)
        (Encode.object [ ( "section", sectionEncoder { section | order = index } ) ])
        (Decode.field "section" sectionDecoder)
        (UpdateSection index)
        authStatus


deleteSection : Auth.Status -> Int -> SectionId -> Cmd Msg
deleteSection authStatus index id =
    delete Endpoints.Section id (DeleteSection index) authStatus



{- Section Exercises -}


fetchSectionExercises : Auth.Status -> Cmd Msg
fetchSectionExercises =
    fetch Endpoints.SectionExercises
        (Decode.field "sectionExercise" (Decode.list sectionExerciseDecoder))
        FetchSectionExercises


createSectionExercise : Auth.Status -> Int -> Int -> SectionExercise -> Cmd Msg
createSectionExercise authStatus sectionIndex exerciseIndex sectionExercise =
    create Endpoints.SectionExercises
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
    update (Endpoints.SectionExercise sectionExercise.id)
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
    delete Endpoints.SectionExercise id (DeleteSectionExercise sectionIndex exerciseIndex) authStatus



{- Subscriptions -}


fetchSubscriptions : Auth.Status -> Cmd Msg
fetchSubscriptions =
    fetch Endpoints.Subscriptions
        (Decode.field "subscription" (Decode.list subscriptionDecoder))
        FetchSubscriptions


createSubscription : Auth.Status -> RoutineId -> Cmd Msg
createSubscription authStatus routineId =
    case authStatus of
        Auth.Authorized user ->
            create Endpoints.Subscriptions
                (Encode.object
                    [ ( "subscription", subscriptionEncoder user.id routineId )
                    ]
                )
                (Decode.field "subscription" subscriptionDecoder)
                CreateSubscription
                authStatus

        _ ->
            Cmd.none


deleteSubscription : Auth.Status -> SubscriptionId -> Cmd Msg
deleteSubscription authStatus id =
    case authStatus of
        Auth.Authorized user ->
            delete Endpoints.Subscription id DeleteSubscription authStatus

        _ ->
            Cmd.none
