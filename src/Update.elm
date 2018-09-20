module Update exposing (Msg(..), loadCandidates, update)

import Decoder exposing (decoder)
import Dict exposing (Dict)
import Http
import Model exposing (Candidate, Form, Model, Suspicion)


type Msg
    = Candidates (Result Http.Error (List Candidate))
    | UpdateForm String String


loadCandidates : Cmd Msg
loadCandidates =
    Http.send Candidates (Http.get "/candidates.json" decoder)


updateForm : Form -> String -> String -> Form
updateForm form key value =
    let
        formAsDict : Dict String String
        formAsDict =
            [ ( "name", form.name )
            , ( "state", form.state )
            , ( "post", form.post )
            ]
                |> Dict.fromList
                |> Dict.update key (\_ -> Just (String.toUpper value))
    in
        Form
            (Dict.get "name" formAsDict |> Maybe.withDefault "")
            (Dict.get "state" formAsDict |> Maybe.withDefault "")
            (Dict.get "post" formAsDict |> Maybe.withDefault "")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newModel : Model
        newModel =
            case msg of
                Candidates (Ok candidates) ->
                    { model | candidates = candidates }

                Candidates (Err error) ->
                    { model | error = Just error }

                UpdateForm key value ->
                    { model | form = updateForm model.form key value }
    in
        ( newModel, Cmd.none )
