module Helpers.Form exposing (filterCandidate, filters, states, posts)

import Html exposing (Html, option, text)
import Html.Attributes exposing (value)
import Model exposing (Candidate, Form)
import Set
import Helpers.Name exposing (capitalize)
import Update exposing (Msg)


--
-- Build option nodes from list of candidates
--


type alias Option =
    { name : String
    , value : String
    }


filters : List (Html Msg)
filters =
    [ option [ value "none" ] [ text "Todas" ]
    , option [ value "number-of-suspicions" ] [ text "Mais de 10 suspeitas" ]
    , option [ value "total-sum" ] [ text "Mais de R$ 1.000,00 em suspeitas" ]
    ]


states : List Candidate -> List (Html Msg)
states candidates =
    candidates
        |> List.map .state
        |> Set.fromList
        |> Set.toList
        |> List.filter (\v -> v /= "BR")
        |> List.map (\v -> Option v v)
        |> (::) (Option "Eleições federais" "BR")
        |> (::) (Option "Todas" "")
        |> List.map (\o -> option [ value o.value ] [ text o.name ])


posts : List Candidate -> List (Html Msg)
posts candidates =
    candidates
        |> List.map .post
        |> Set.fromList
        |> Set.toList
        |> List.map capitalize
        |> List.map (\v -> Option v v)
        |> (::) (Option "Todos" "")
        |> List.map (\o -> option [ value o.value ] [ text o.name ])



--
-- Filter candidate from form input
--


compareStrings : String -> String -> Bool
compareStrings input reference =
    if String.isEmpty input then
        True
    else
        (String.toUpper input) == (String.toUpper reference)


byState : Form -> Candidate -> Bool
byState form candidate =
    compareStrings form.state candidate.state


byPost : Form -> Candidate -> Bool
byPost form candidate =
    compareStrings (String.replace "º" "O" form.post) candidate.post


byName : Form -> Candidate -> Bool
byName form candidate =
    if String.isEmpty form.name then
        True
    else
        String.contains
            (String.toUpper form.name)
            (String.toUpper candidate.name)


byFilterNumberOfSuspicions : Candidate -> Bool
byFilterNumberOfSuspicions candidate =
    if List.length candidate.suspicions >= 10 then
        True
    else
        False


byFilterTotalSum : Candidate -> Bool
byFilterTotalSum candidate =
    let
        sum : Float
        sum =
            candidate.suspicions
                |> List.map .value
                |> List.sum
    in
        if sum >= 1000.0 then
            True
        else
            False


byFilter : Form -> Candidate -> Bool
byFilter form candidate =
    if form.filter == "number-of-suspicions" then
        byFilterNumberOfSuspicions candidate
    else if form.filter == "total-sum" then
        byFilterTotalSum candidate
    else
        True


filterCandidate : Form -> Candidate -> Bool
filterCandidate form candidate =
    (byState form candidate) && (byPost form candidate) && (byName form candidate) && (byFilter form candidate)
