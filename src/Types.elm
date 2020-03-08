module Types exposing (AuthenticationStatus(..), ErrorMsg(..), FollowedUser(..), Model, Msg(..), Token(..), User, UserId(..))

import Animation exposing (px)
import Browser.Navigation exposing (Key)
import Http
import Url exposing (Url)


type Token
    = Token String


type UserId
    = UserId Int


type ErrorMsg
    = ErrorMsg String


type FollowedUser
    = FollowedUser UserId (Maybe User)


type alias User =
    { id : UserId
    , name : String
    , following : List FollowedUser
    }


type AuthenticationStatus
    = Unknown
    | LoggedIn Token User
    | LoggedOut


type alias Model =
    { navigationKey : Key
    , auth : AuthenticationStatus
    , errorMsg : Maybe ErrorMsg
    , style : Animation.State
    }


type Msg
    = GotUser Token (Result Http.Error User)
    | GotFollowed (Result Http.Error FollowedUser)
    | SignUserIn
    | SignUserOut
    | NoOp
    | SendUserToExternalUrl String
    | PushUrl Url
    | Toast
    | ClearErrorMsg
    | Animate Animation.Msg
