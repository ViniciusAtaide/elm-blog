module Api exposing (fetchAuthenticatedUser, fetchFollowedUsersForUser)

import Http
import HttpBuilder exposing (withExpect, withHeader)
import Json.Decode as D exposing (Decoder)
import Types exposing (FollowedUser(..), Msg(..), Token(..), User, UserId(..))


userIdDecoder : Decoder UserId
userIdDecoder =
    D.map UserId D.int


followedUserDecoder : Decoder FollowedUser
followedUserDecoder =
    D.map (\userId -> FollowedUser userId Nothing) userIdDecoder


userDecoder : Decoder User
userDecoder =
    D.map3 User
        (D.field "id" userIdDecoder)
        (D.field "name" D.string)
        (D.field "following" (D.list followedUserDecoder))


fetchUser : Token -> UserId -> Cmd Msg
fetchUser (Token token) (UserId userId) =
    HttpBuilder.get ("http://localhost:3000/api/users/" ++ String.fromInt userId)
        |> HttpBuilder.withHeader "X-Token" token
        |> HttpBuilder.withExpect (Http.expectJson GotFollowed followedUserDecoder)
        |> HttpBuilder.request


fetchAuthenticatedUser : Maybe Token -> Cmd Msg
fetchAuthenticatedUser token =
    case token of
        Just ((Token tok) as fullToken) ->
            HttpBuilder.get
                "http://localhost:3000/api/me"
                |> HttpBuilder.withHeader "X-Token" tok
                |> HttpBuilder.withExpect (Http.expectJson (GotUser fullToken) userDecoder)
                |> HttpBuilder.request

        Nothing ->
            Cmd.none


fetchFollowedUsersForUser : Token -> User -> Cmd Msg
fetchFollowedUsersForUser token user =
    user.following
        |> List.map
            (\followedUser ->
                case followedUser of
                    FollowedUser userId Nothing ->
                        fetchUser token userId

                    FollowedUser (UserId _) (Just _) ->
                        Cmd.none
            )
        |> Cmd.batch
