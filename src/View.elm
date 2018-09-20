module View exposing (view)

import Browser exposing (Document)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (spanishLocale)
import Helpers.Form exposing (filterCandidate, posts, states)
import Helpers.Name exposing (capitalize)
import Html exposing (Html, a, div, h4, i, img, input, label, select, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (alt, class, for, href, id, src, type_, value)
import Html.Events exposing (onInput)
import Json.Decode exposing (map, string)
import Model exposing (Candidate, Model, Suspicion)
import Update exposing (Msg(..))


loadingView : Html Msg
loadingView =
    div [ id "loading", class "ui active centered inline loader" ] []


failedView : Html Msg
failedView =
    div
        [ id "failed", class "ui active centered inline" ]
        [ text "Erro ao carregar o site. Por favor, tente novamente." ]


form : Model -> Html Msg
form model =
    div
        [ class "ui form" ]
        [ div
            [ class "fields" ]
            [ div
                [ class "eight wide field" ]
                [ label [ for "name" ] [ text "Nome" ]
                , input
                    [ id "name"
                    , type_ "text"
                    , onInput (UpdateForm "name")
                    , value model.form.name
                    ]
                    []
                ]
            , div
                [ class "three wide field" ]
                [ label [ for "state" ] [ text "UF" ]
                , select
                    [ id "state", onInput (UpdateForm "state") ]
                    (states model.candidates)
                ]
            , div
                [ class "five wide field" ]
                [ label [ for "post" ] [ text "Cargo" ]
                , select
                    [ id "cargo", onInput (UpdateForm "post") ]
                    (posts model.candidates)
                ]
            ]
        ]


suspicion : Suspicion -> Html Msg
suspicion data =
    a
        [ class "ui label"
        , href data.url
        ]
        [ i [ class "linkify icon" ] []
        , text data.reason
        ]


row : Candidate -> Html Msg
row candidate =
    let
        count : String
        count =
            candidate.suspicions
                |> List.length
                |> String.fromInt

        total : String
        total =
            candidate.suspicions
                |> List.map .value
                |> List.sum
                |> format { spanishLocale | decimals = 2 }
                |> (++) "R$ "

        pictureLabel : String
        pictureLabel =
            "Foto de " ++ (capitalize candidate.name)

        party : String
        party =
            candidate.party ++ "/" ++ candidate.state
    in
        tr
            []
            [ td
                []
                [ h4
                    [ class "ui image header" ]
                    [ img
                        [ class "ui large rounded image"
                        , src candidate.picture
                        , alt pictureLabel
                        ]
                        []
                    , div
                        [ class "content" ]
                        [ text (capitalize candidate.name)
                        , div [ class "sub header" ] [ text party ]
                        ]
                    ]
                ]
            , td [] [ text (capitalize candidate.post) ]
            , td
                []
                [ div
                    [ class "ui label" ]
                    [ text "Suspeitas", div [ class "detail" ] [ text count ] ]
                , div
                    [ class "ui label" ]
                    [ text "Total", div [ class "detail" ] [ text total ] ]
                ]
            , td [] (List.map suspicion candidate.suspicions)
            ]


contents : Model -> Html Msg
contents model =
    let
        rows : List (Html Msg)
        rows =
            model.candidates
                |> List.filter (filterCandidate model.form)
                |> List.map row
    in
        if List.isEmpty rows then
            div
                [ id "no-results" ]
                [ text "Nenhum candidato(a) de acordo com esses filtros" ]
        else
            table
                [ id "main-table", class "ui very basic collapsing celled table" ]
                [ thead
                    []
                    [ tr
                        []
                        [ th [ class "three wide" ] [ text "Nome" ]
                        , th [ class "three wide" ] [ text "Se candidatando a" ]
                        , th [ class "three wide" ] [ text "Resumo da Rosie" ]
                        , th [ class "ten wide" ] [ text "Links para o Jarbas" ]
                        ]
                    ]
                , tbody [] rows
                ]


footer : Html Msg
footer =
    h4
        [ id "footer", class "ui horizontal divider header" ]
        [ a
            [ class "item"
            , href "https://github.com/okfn-brasil/serenata-relatorio-catarse"
            ]
            [ i [ class "heart outline icon" ] []
            , text "Feito com dados abertos e código aberto"
            , i [ class "code icon" ] []
            ]
        ]


mainView : Model -> Html Msg
mainView model =
    div [] [ form model, contents model, footer ]


view : Model -> Document Msg
view model =
    let
        mainHtml : Html Msg
        mainHtml =
            if List.isEmpty model.candidates then
                case model.error of
                    Just error ->
                        failedView

                    Nothing ->
                        loadingView
            else
                mainView model

        body : List (Html Msg)
        body =
            [ div
                [ class "ui centered grid" ]
                [ div [ class "sixteen wide column" ] [ mainHtml ] ]
            ]

        title : String
        title =
            if List.isEmpty model.candidates then
                case model.error of
                    Just error ->
                        "Erro ao carregar o site. Por favor, tente novamente."

                    Nothing ->
                        "Carregando…"
            else
                "Rosie nas Eleições 2018"
    in
        Document title body
