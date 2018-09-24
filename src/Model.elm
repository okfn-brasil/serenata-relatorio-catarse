module Model exposing (Candidate, Form, Model, Suspicion, model)

import Http


type alias Form =
    { name : String
    , state : String
    , post : String
    , filter : String
    }


type alias Suspicion =
    { value : Float
    , reason : String
    , url : String
    }


type alias Candidate =
    { name : String
    , party : String
    , state : String
    , post : String
    , picture : String
    , suspicions : List Suspicion
    }


type alias Model =
    { candidates : List Candidate
    , form : Form
    , error : Maybe Http.Error
    }


form : Form
form =
    Form "" "" "" ""


model : Model
model =
    Model [] form Nothing
