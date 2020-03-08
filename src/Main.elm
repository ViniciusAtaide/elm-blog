port module Main exposing (main)

import Animation exposing (px)
import Api
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Navigation exposing (Key)
import Element as E
import Process
import Routing exposing (Route(..), parseUrlToRoute)
import Task
import Types exposing (AuthenticationStatus(..), ErrorMsg(..), Model, Msg(..), Token(..))
import Url exposing (Url)
import View exposing (body, header)


type alias Flags =
    { storedToken : Maybe String
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        parsedUrl =
            parseUrlToRoute url

        token =
            case parsedUrl of
                Signin maybeGithubToken ->
                    Maybe.map Token maybeGithubToken

                _ ->
                    Maybe.map Token flags.storedToken

        commands =
            case token of
                (Just (Token tok)) as fullToken ->
                    Cmd.batch
                        [ sendTokenToStorage tok
                        , Api.fetchAuthenticatedUser fullToken
                        ]

                Nothing ->
                    Cmd.none

        newModel =
            { auth =
                case token of
                    Nothing ->
                        LoggedOut

                    Just _ ->
                        Unknown
            , navigationKey = key
            , errorMsg = Nothing
            , style =
                Animation.style
                    [ Animation.opacity 1.0
                    ]
            }
    in
    ( newModel, commands )


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Blog"
    , body = [ E.layout [] (E.column [ E.width E.fill, E.spacingXY 0 40 ] [ header model.auth, body model.style model.errorMsg ]) ]
    }


onUrlRequest : UrlRequest -> Msg
onUrlRequest urlRequest =
    case urlRequest of
        External externalUrl ->
            SendUserToExternalUrl externalUrl

        Internal url ->
            case parseUrlToRoute url of
                Signout ->
                    SignUserOut

                Auth ->
                    SignUserIn

                _ ->
                    NoOp


onUrlChange : Url -> Msg
onUrlChange _ =
    NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotUser token result ->
            case result of
                Err _ ->
                    ( { model
                        | auth = LoggedOut
                        , errorMsg = Just <| ErrorMsg "Não Consegue Conectar ao Servidor"
                      }
                    , Cmd.batch
                        [ Navigation.pushUrl model.navigationKey "/"
                        , Task.perform (\_ -> ClearErrorMsg) (Process.sleep 3000)
                        ]
                    )

                Ok user ->
                    ( { model | auth = LoggedIn token user }, Api.fetchFollowedUsersForUser token user )

        GotFollowed result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok _ ->
                    case model.auth of
                        LoggedIn token loggedInUser ->
                            let
                                newFollowing =
                                    List.map
                                        (\followedUser ->
                                            followedUser
                                        )
                                        loggedInUser.following

                                newUser =
                                    { loggedInUser | following = newFollowing }

                                newStatus =
                                    LoggedIn token newUser
                            in
                            ( { model | auth = newStatus }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

        SignUserIn ->
            ( model, Navigation.load "/auth" )

        SignUserOut ->
            ( { model | auth = LoggedOut }
            , Cmd.batch
                [ Navigation.pushUrl model.navigationKey "/"
                , clearTokenFromStorage ()
                ]
            )

        SendUserToExternalUrl url ->
            ( model, Navigation.load url )

        PushUrl url ->
            ( model, Navigation.load <| Url.toString url )

        Toast ->
            ( { model
                | style =
                    Animation.interrupt
                        [ Animation.to
                            [ Animation.opacity 0
                            ]
                        , Animation.to
                            [ Animation.opacity 1
                            ]
                        ]
                        model.style
              }
            , Cmd.none
            )

        ClearErrorMsg ->
            ( { model | errorMsg = Nothing }, Cmd.none )

        Animate animMsg ->
            ( { model
                | style = Animation.update animMsg model.style
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.style ]


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }


port sendTokenToStorage : String -> Cmd msg


port clearTokenFromStorage : () -> Cmd msg
