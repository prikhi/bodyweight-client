module Utils exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (onWithOptions, defaultOptions, on)
import Json.Decode as Decode exposing ((:=))


onClickNoDefault : msg -> Attribute msg
onClickNoDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed msg)
