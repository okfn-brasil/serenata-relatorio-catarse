module Helpers.Form exposing (filterCandidate, states, posts)

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


filterCandidate : Form -> Candidate -> Bool
filterCandidate form candidate =
    (byState form candidate) && (byPost form candidate) && (byName form candidate)
