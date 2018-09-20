module Decoder exposing (decoder)

import Json.Decode exposing (Decoder, at, field, float, list, map3, map6, string)
import Model exposing (Candidate, Suspicion)


suspicion : Decoder Suspicion
suspicion =
    map3 Suspicion
        (field "valor" float)
        (field "suspeita" string)
        (field "url" string)


candidate : Decoder Candidate
candidate =
    map6 Candidate
        (field "candidato" string)
        (field "partido" string)
        (field "uf" string)
        (field "cargo" string)
        (field "foto" string)
        (field "suspeitas" (list suspicion))


decoder : Decoder (List Candidate)
decoder =
    field "candidatos" (list candidate)
