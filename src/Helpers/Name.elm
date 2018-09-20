module Helpers.Name exposing (capitalize)


replaceExceptions : String -> String
replaceExceptions value =
    let
        lower : List String
        lower =
            [ "Do", "Da", "Dos", "Das", "De", "Des", "Van", "Von" ]

        replacements : List ( String, String )
        replacements =
            [ ( "1O", "1º" )
            , ( "2O", "2º" )
            ]

        replaceLower : String -> String
        replaceLower word =
            if List.member word lower then
                String.toLower word
            else
                word

        replaceWord : String -> String
        replaceWord word =
            replacements
                |> List.filter (\pair -> Tuple.first pair == word)
                |> List.head
                |> Maybe.map (\pair -> Tuple.second pair)
                |> Maybe.withDefault word
    in
        value
            |> String.split " "
            |> List.map (replaceLower >> replaceWord)
            |> String.join " "


capitalize : String -> String
capitalize name =
    let
        letters : List Char
        letters =
            String.toList name

        previousLetters : List Char
        previousLetters =
            ' ' :: letters

        pairs : List ( Char, Char )
        pairs =
            List.map2 Tuple.pair letters previousLetters

        nextLetter : ( Char, Char ) -> Char
        nextLetter ( letter, previous ) =
            if Char.isAlpha previous then
                Char.toLower letter
            else
                Char.toUpper letter
    in
        pairs
            |> List.map nextLetter
            |> String.fromList
            |> replaceExceptions
