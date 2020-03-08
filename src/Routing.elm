module Routing exposing (Route(..), parseUrlToRoute)

import Url exposing (Url)
import Url.Parser as Parser exposing ((<?>), Parser)
import Url.Parser.Query as Query


type Route
    = Signin (Maybe String)
    | Signout
    | Auth
    | NotFound


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Signin (Parser.s "signin" <?> Query.string "code")
        , Parser.map Signout (Parser.s "signout")
        , Parser.map Auth (Parser.s "auth")
        ]


parseUrlToRoute : Url -> Route
parseUrlToRoute url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)
