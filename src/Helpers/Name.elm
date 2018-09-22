module Helpers.Name exposing (capitalize)

import Regex


capitalize : String -> String
capitalize name =
    let
        exceptions : List String
        exceptions =
            [ "do", "da", "dos", "das", "de", "des", "van", "von" ]

        safeRegex : String -> Regex.Regex
        safeRegex =
            Maybe.withDefault Regex.never << Regex.fromString

        capitalizeWord : String -> String
        capitalizeWord str =
            if List.member str exceptions then
                str
            else
                Regex.replace (safeRegex "^(\\w)") (.match >> String.toUpper) str
    in
        name
            |> String.toLower
            |> Regex.replace (safeRegex "^\\do ") (.match >> String.replace "o" "º")
            |> Regex.replace (safeRegex "(\\w+)") (.match >> capitalizeWord)
