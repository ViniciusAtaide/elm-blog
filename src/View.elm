module View exposing (body, header)

import Animation exposing (px)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as F
import Types exposing (AuthenticationStatus(..), ErrorMsg(..), Msg(..))


title : Element Msg
title =
    E.el
        [ E.width E.fill
        , F.extraBold
        , F.size 24
        , F.alignLeft
        ]
        (E.text "Elm Blog")


navOptions : Element Msg
navOptions =
    E.row
        [ E.width E.fill ]
        [ navOption "Docs"
        , navOption "Examples"
        , navOption "Blog"
        ]


navOption : String -> Element Msg
navOption t =
    E.column
        [ E.paddingEach { top = 0, bottom = 0, left = 0, right = 20 }
        , E.mouseOver [ F.color <| E.rgb255 255 255 255 ]
        , E.pointer
        ]
        [ E.link
            []
            { label = E.text t
            , url = "https://www.google.com"
            }
        ]


linkStyles : List (E.Attribute msg)
linkStyles =
    [ Border.solid
    , Border.color <| E.rgb255 255 255 255
    , Border.width 1
    , E.alignRight
    , Border.rounded 3
    , E.paddingXY 15 8
    , F.medium
    , E.mouseOver
        [ Border.color <| E.rgb255 155 155 155
        , F.color <| E.rgb255 255 255 255
        , Background.color <| E.rgb255 59 189 176
        ]
    , E.pointer
    ]


signOutButton : Element Msg
signOutButton =
    E.column []
        [ E.link
            linkStyles
            { label = E.text "Sign Out"
            , url = "/signout"
            }
        ]


signInButton : Element Msg
signInButton =
    E.link
        linkStyles
        { label = E.text "Sign In"
        , url = "http://localhost:3000/auth"
        }


nav : AuthenticationStatus -> Element Msg
nav authStatus =
    E.el
        [ F.size 16
        , F.light
        , F.color <| E.rgba255 255 255 255 0.8
        , E.width E.fill
        ]
    <|
        E.row
            [ E.width E.fill ]
            [ navOptions
            , case authStatus of
                LoggedIn _ _ ->
                    signOutButton

                _ ->
                    signInButton
            ]


header : AuthenticationStatus -> Element Msg
header authStatus =
    E.column
        [ E.width E.fill
        , E.padding 30
        , Background.color <| E.rgb255 79 209 196
        , F.color <| E.rgb255 255 255 255
        , E.spacingXY 0 30
        ]
        [ title
        , nav authStatus
        ]


body : Animation.State -> Maybe ErrorMsg -> Element Msg
body style error =
    E.column [ E.htmlAttribute List.head <| Animation.render style ]
        [ case error of
            Just (ErrorMsg err) ->
                E.el [] <|
                    E.text err

            Nothing ->
                E.none
        ]
