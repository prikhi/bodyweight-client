module Auth exposing (..)

import Json.Decode as Decode
import Html exposing (Html, Attribute, div, text, h2, label, input, button, a)
import Html.Attributes exposing (class, id, type_, for, placeholder, value, checked, href)
import Html.Events exposing (onInput, onCheck, onSubmit, onWithOptions, defaultOptions)
import Routing


-- Model


type alias UserId =
    Int


{-| The current User.
-}
type alias User =
    { username : String
    , id : UserId
    , isAdmin : Bool
    , authToken : String
    }


{-| Decode a User from an API response.
-}
userDecoder : Decode.Decoder User
userDecoder =
    Decode.map4 User
        (Decode.field "name" Decode.string)
        (Decode.field "id" Decode.int)
        (Decode.field "isAdmin" Decode.bool)
        (Decode.field "authToken" Decode.string)


{-| The User can either be Anonymous, Logging In, Registering, or Authorized.
-}
type Status
    = Anonymous
    | LoggingIn
    | Registering
    | Authorized User


{-| The Login/Register Form.
-}
type alias Form =
    { username : String
    , password : String
    , passwordAgain : String
    , remember : Bool
    }


{-| The initial Authorization status is Anonymous, unless on the Login/Register
pages.
-}
initial : Routing.Route -> Status
initial route =
    case route of
        Routing.LoginRoute ->
            LoggingIn

        Routing.RegisterRoute ->
            Registering

        _ ->
            Anonymous


{-| The initial Form has all fields empty & is set to remember the User.
-}
initialForm : Form
initialForm =
    { username = ""
    , password = ""
    , passwordAgain = ""
    , remember = True
    }


{-| Retrieve the User's ID if Authorized.
-}
getUserId : Status -> Maybe Int
getUserId status =
    case status of
        Authorized { id } ->
            Just id

        _ ->
            Nothing



-- Messages


{-| A Message type for Form changes.
-}
type Msg
    = UsernameChanged String
    | PasswordChanged String
    | PasswordAgainChanged String
    | RememberToggled Bool



-- Update


{-| Update the Form Inputs.
-}
update : Msg -> Form -> Form
update msg form =
    case msg of
        UsernameChanged username ->
            { form | username = username }

        PasswordChanged password ->
            { form | password = password }

        PasswordAgainChanged password ->
            { form | passwordAgain = password }

        RememberToggled remember ->
            { form | remember = remember }



-- View


{-| An `onClick` Html Event that prevents the default action.
TODO: Refactor Utils module so we can import this from there with no cyclical dependencies
-}
onClickNoDefault : msg -> Attribute msg
onClickNoDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed msg)


{-| Render the Login and Registration pages.
-}
view : (Msg -> msg) -> (Routing.Route -> msg) -> msg -> Status -> Form -> Html msg
view tagger urlChange submitMsg status form =
    let
        passwordInput inputId inputValue inputPlaceholder inputMsg =
            [ label [ for inputId, class "sr-only" ] [ text inputPlaceholder ]
            , input
                [ type_ "password"
                , class "form-control"
                , id inputId
                , value inputValue
                , placeholder inputPlaceholder
                , onInput <| tagger << inputMsg
                ]
                []
            ]

        passwordInputs =
            (++) (passwordInput "password" form.password "Password" PasswordChanged) <|
                if status == Registering then
                    passwordInput "passwordAgain" form.passwordAgain "Verify Password" PasswordAgainChanged
                else
                    []

        ( linkRoute, linkText, titleText ) =
            if status == LoggingIn then
                ( Routing.RegisterRoute, "Register", "Log In" )
            else
                ( Routing.LoginRoute, "Login", "Register" )
    in
        div [ class "container" ]
            [ div [ class "justify-content-center row" ]
                [ Html.form [ class "col-sm-8 col-md-4", onSubmit submitMsg ]
                    [ h2 [] [ text titleText ]
                    , div [ class "form-group" ]
                        [ label [ for "username", class "sr-only" ] [ text "Username" ]
                        , input
                            [ type_ "text"
                            , class "form-control"
                            , id "username"
                            , placeholder "Username"
                            , onInput <| tagger << UsernameChanged
                            , value form.username
                            ]
                            []
                        , div [] passwordInputs
                        , div [ class "form-check" ]
                            [ label [ class "form-check-label" ]
                                [ input
                                    [ type_ "checkbox"
                                    , class "form-check-input"
                                    , checked form.remember
                                    , onCheck <| tagger << RememberToggled
                                    ]
                                    []
                                , text " Remember Me"
                                ]
                            ]
                        , button [ class "btn btn-primary btn-block", type_ "submit" ]
                            [ text titleText ]
                        , div [ class "text-right mt-1" ]
                            [ a [ onClickNoDefault <| urlChange linkRoute, href "#" ]
                                [ text linkText ]
                            ]
                        ]
                    ]
                ]
            ]
