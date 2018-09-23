module Auth(getAccessToken, isAuthCallback, login, logout, handleAuthentication, AccessToken(..)) where

import Data.Show
import Prelude

import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFn2, EffectFnAff, fromEffectFnAff)
import Effect.Uncurried (EffectFn2, runEffectFn2)
import Effect.Class (liftEffect)

newtype AccessToken = AccessToken String
instance showAccessToken :: Show AccessToken where
  show (AccessToken at) = at

foreign import _getCachedAccessToken :: Fn2 (String -> Either String AccessToken) (String -> Either String AccessToken) (EffectFnAff (Either String AccessToken))
foreign import _getRenewedAccessToken :: Fn2 (String -> Either String AccessToken) (String -> Either String AccessToken) (EffectFnAff (Either String AccessToken))
foreign import _isAuthCallback :: Effect Boolean
foreign import _login :: Effect Unit
foreign import _logout :: Effect Unit
foreign import _handleAuthentication :: EffectFnAff Unit

getCachedAccessToken :: Aff (Either String AccessToken)
getCachedAccessToken = fromEffectFnAff $ runFn2 _getCachedAccessToken (Right <<< AccessToken) Left

getRenewedAccessToken :: Aff (Either String AccessToken)
getRenewedAccessToken = fromEffectFnAff $ runFn2 _getRenewedAccessToken (Right <<< AccessToken) Left

getAccessToken :: Aff (Either String AccessToken)
getAccessToken = do
  cachedAccessToken <- getCachedAccessToken
  case cachedAccessToken of
    Right token -> pure $ Right token
    Left _ -> getRenewedAccessToken

isAuthCallback :: Aff Boolean
isAuthCallback = liftEffect _isAuthCallback

login :: Aff Unit
login = liftEffect _login

logout :: Aff Unit
logout = liftEffect _logout

handleAuthentication :: Aff Unit
handleAuthentication = fromEffectFnAff _handleAuthentication
