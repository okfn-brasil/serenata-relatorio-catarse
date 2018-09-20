module View exposing (view)

import Browser exposing (Document)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (spanishLocale)
import Helpers.Form exposing (filterCandidate, posts, states)
import Helpers.Name exposing (capitalize)
import Html exposing (..)
import Html.Attributes exposing (alt, class, for, href, id, src, type_, value)
import Html.Events exposing (onInput)
import Json.Decode exposing (map, string)
import Model exposing (Candidate, Model, Suspicion)
import Update exposing (Msg(..))


loadingView : List (Html Msg)
loadingView =
    [ div [ class "ui active centered inline loader" ] [] ]


failedView : List (Html Msg)
failedView =
    [ div
        [ class "ui active centered inline" ]
        [ text "Erro ao carregar o site. Por favor, tente novamente." ]
    ]


formView : Model -> Html Msg
formView model =
    form
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


suspicionView : Suspicion -> Html Msg
suspicionView data =
    a
        [ class "ui label"
        , href data.url
        ]
        [ i [ class "linkify icon" ] []
        , text data.reason
        ]


rowView : Candidate -> Html Msg
rowView candidate =
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
            , td [] (List.map suspicionView candidate.suspicions)
            ]


tableView : Model -> Html Msg
tableView model =
    let
        rows : List (Html Msg)
        rows =
            model.candidates
                |> List.filter (filterCandidate model.form)
                |> List.map rowView
    in
        if List.isEmpty rows then
            div
                [ class "centered" ]
                [ text "Nenhum candidato(a) de acordo com esses filtros" ]
        else
            table
                [ class "ui table" ]
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


disclaimerView : Html Msg
disclaimerView =
    div
        [ class "ui purple inverted segment" ]
        [ p
            []
            [ text """
                Olá. Aqui embaixo você vai ver uma lista com políticos que
                estão concorrendo nessas eleições e apresentaram despesas
                suspeitas com a cota parlamentar. Antes de continuar, você
                precisa saber que este não é um ranking de corrupção, mas uma
                lista de despesas que merecem ser checadas novamente, por serem
                suspeitas.
            """ ]
        , p
            []
            [ text """
                Aparecer nas linhas abaixo não é condenação a ninguém, assim
                como não aparecer não é atestado de idoneidade.
            """ ]
        , p [] [ text "Aproveite :)" ]
        ]


footerView : Html Msg
footerView =
    footer
        []
        [ h4
            [ class "ui horizontal divider header" ]
            [ a
                [ class "item"
                , href "https://github.com/okfn-brasil/serenata-relatorio-catarse"
                ]
                [ i [ class "heart outline icon" ] []
                , text "Feito com dados abertos e código aberto"
                , i [ class "code icon" ] []
                ]
            ]
        ]


mainView : Model -> List (Html Msg)
mainView model =
    [ disclaimerView
    , formView model
    , tableView model
    , footerView
    ]


view : Model -> Document Msg
view model =
    let
        contents : List (Html Msg)
        contents =
            if List.isEmpty model.candidates then
                case model.error of
                    Just error ->
                        failedView

                    Nothing ->
                        loadingView
            else
                mainView model

        title : String
        title =
            if List.isEmpty model.candidates then
                case model.error of
                    Just error ->
                        "Erro ao carregar o site. Por favor, tente novamente."

                    Nothing ->
                        "Carregando…"
            else
                """
                Relatório para apoiadores da Operação Serenata de Amor no
                Catarse (2016) — Rosie nas Eleições 2018
                """
    in
        Document title [ main_ [] contents ]
