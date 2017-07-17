module Models.Subscriptions exposing (..)

import Auth exposing (UserId)
import Json.Decode as Decode
import Json.Encode as Encode
import Models.Routines exposing (RoutineId)


type alias SubscriptionId =
    Int


type alias Subscription =
    { id : SubscriptionId
    , user : UserId
    , routine : RoutineId
    }


subscriptionDecoder : Decode.Decoder Subscription
subscriptionDecoder =
    Decode.map3 Subscription
        (Decode.field "id" Decode.int)
        (Decode.field "user" Decode.int)
        (Decode.field "routine" Decode.int)


subscriptionEncoder : UserId -> RoutineId -> Encode.Value
subscriptionEncoder userId routineId =
    Encode.object
        [ ( "user", Encode.int userId )
        , ( "routine", Encode.int routineId )
        ]
