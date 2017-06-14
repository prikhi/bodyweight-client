module Utils exposing (..)

import Array exposing (Array)
import Html exposing (Html, Attribute, label, input, text, a, node)
import Html.Attributes exposing (name, value, type_, href, class)
import Html.Events exposing (onWithOptions, defaultOptions, on, onInput, targetValue)
import Json.Decode as Decode
import Messages exposing (Msg(NavigateTo))
import Routing exposing (Route, reverse)
import String


{-| Decode the `target.value` value of an Html Event as an Int.
-}
targetValueIntDecoder : Decode.Decoder Int
targetValueIntDecoder =
    targetValue
        |> Decode.andThen
            (\val ->
                case String.toInt val of
                    Ok i ->
                        Decode.succeed i

                    Err err ->
                        Decode.fail err
            )


{-| An `onClick` Html Event that prevents the default action.
-}
onClickNoDefault : msg -> Attribute msg
onClickNoDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed msg)


{-| An Html Event for Select elements with Integer values.
-}
onSelectInt : (Int -> msg) -> Attribute msg
onSelectInt msg =
    on "change" (Decode.map msg targetValueIntDecoder)


{-| An Html Event for Input Events on elements with Integer values.
-}
onInputInt : (Int -> msg) -> Attribute msg
onInputInt msg =
    on "input" (Decode.map msg targetValueIntDecoder)


icon : String -> Html msg
icon iconClass =
    node "i" [ class <| "fa fa-" ++ iconClass ] []


{-| Create a link to an internal Route using some text.
-}
navLink : String -> Route -> Html Msg
navLink content route =
    a [ href <| reverse route, onClickNoDefault <| NavigateTo route ]
        [ text content ]


{-| Either render the given Html element or an empty node.
-}
htmlOrBlank : Bool -> Html msg -> Html msg
htmlOrBlank showHtml html =
    if showHtml then
        html
    else
        text ""


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


{-| Replace the first item that has the same `id` value.
-}
replaceById : { b | id : a } -> List { b | id : a } -> List { b | id : a }
replaceById newItem list =
    case list of
        [] ->
            [ newItem ]

        x :: xs ->
            if x.id == newItem.id then
                newItem :: xs
            else
                x :: replaceById newItem xs


{-| Determine if the item at the index has been saved to the backend by
checking if it's `id` is `0`.
-}
indexIsSaved : Int -> Array { a | id : Int } -> Bool
indexIsSaved index array =
    Array.get index array
        |> Maybe.map (\item -> item.id /= 0)
        |> Maybe.withDefault False


{-| Remove the item at a specific index from an `Array`.
-}
removeByIndex : Int -> Array a -> Array a
removeByIndex index array =
    Array.append (Array.slice 0 index array) <|
        Array.slice (index + 1) (Array.length array) array


{-| Update an item at a specific index in an `Array`
-}
updateByIndex : Int -> (a -> a) -> Array a -> Array a
updateByIndex index update array =
    Array.get index array
        |> Maybe.map (\item -> Array.set index (update item) array)
        |> Maybe.withDefault array


{-| Swap two values in an `Array`.
-}
swapIndexes : Int -> Int -> Array a -> Array a
swapIndexes fromIndex toIndex array =
    Array.get toIndex array
        |> Maybe.andThen
            (\temp ->
                Array.get fromIndex array
                    |> Maybe.map (\item -> Array.set toIndex item array)
                    |> Maybe.map (\list -> Array.set fromIndex temp list)
            )
        |> Maybe.withDefault array


{-| Determine if any item in an `Array` fulfills the given predicate.
-}
anyInArray : (a -> Bool) -> Array a -> Bool
anyInArray pred =
    Array.foldl
        (\item bool ->
            if bool then
                bool
            else
                pred item
        )
        False


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
            , type_ "text"
            , value inputValue
            , onInput msg
            ]
            []


{-| Render a integer input field.
-}
intField : String -> String -> String -> (Int -> msg) -> Html msg
intField labelText inputName inputValue msg =
    formField (labelText ++ ": ") <|
        input
            [ name inputName
            , type_ "number"
            , value inputValue
            , onInputInt msg
            ]
            []
