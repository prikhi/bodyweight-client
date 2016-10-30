module Utils exposing (..)

import Html exposing (Html, Attribute, label, input, text)
import Html.Attributes exposing (name, value)
import Html.Events exposing (onWithOptions, defaultOptions, on, onInput)
import Json.Decode as Decode exposing ((:=))


{-| An `onClick` Html Event that prevents the default action.
-}
onClickNoDefault : msg -> Attribute msg
onClickNoDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed msg)


{-| Find the first item with the matching `id` value.
-}
findById : a -> List { b | id : a } -> Maybe { b | id : a }
findById id items =
    case items of
        [] ->
            Nothing

        x :: xs ->
            if x.id == id then
                Just x
            else
                findById id xs


{-| Render an input field with some label text.
-}
formField : String -> Html msg -> Html msg
formField labelText field =
    label [] [ text labelText, field ]


{-| Render a text input field.
-}
textField : String -> String -> String -> (String -> msg) -> Html msg
textField labelText inputName inputValue msg =
    formField (labelText ++ ": ") <|
        input
            [ name inputName
            , value inputValue
            , onInput msg
            ]
            []
