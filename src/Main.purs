module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Effect.Class (liftEffect)
import Effect.Aff(launchAff)
import Data.Either (Either(..))
import Auth
import Api(getReceipts, ensureUserExists)

--main = launchAff do
--  logout

{--
main = launchAff do
  isCallback <- isAuthCallback
  liftEffect $ log $ "Is auth callback: " <> show isCallback
  if isCallback then handleAuthentication else login
--}


main = launchAff do
  response <- getAccessToken
  liftEffect $ log $ "Access token: " <> show response
  receiptsResponse <- case response of
                        Right accessToken -> do
                          userExistsResponse <- ensureUserExists accessToken
                          liftEffect $ log $ "userExistsResponse: " <> show userExistsResponse
                          receiptsResponse <- getReceipts accessToken
                          pure $ show receiptsResponse
                        Left error -> pure $ "No access token"
  liftEffect $ log $ "receiptsResponse: " <> show receiptsResponse

--main :: Effect Unit
--main = do
--  token <- getAT
--  log $ "Access token: " <> show token
