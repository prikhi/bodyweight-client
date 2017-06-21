port module Ports exposing (..)

{-| This module contains all the ports used throughout the application.
-}


{-| Store the Current User's Token & ID in Local Storage.
-}
port storeAuthDetails : ( String, Int ) -> Cmd msg


{-| Remove the Current User's Token & ID from Local Storage.
-}
port removeAuthDetails : () -> Cmd msg
