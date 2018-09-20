module Main exposing (main)

import Browser
import Model exposing (Model, model)
import Update exposing (Msg, loadCandidates, update)
import View exposing (view)


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( model, loadCandidates )


main : Platform.Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = (\s -> Sub.none)
        }
