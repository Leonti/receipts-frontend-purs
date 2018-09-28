module Main where

import Auth
import Prelude

import Api (getReceipts, ensureUserExists)
import Data.Either (Either(..))
import Data.JSDate (getTimezoneOffset, now)
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import ReceiptListView (ui)
import Data.Time.Duration (Minutes(..))

--main = launchAff do
--  logout

main :: Effect Unit
main = do
  d <- now
  timezoneOffset <- getTimezoneOffset d
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI ui (Minutes timezoneOffset) body

{--
main = launchAff do
  isCallback <- isAuthCallback
  liftEffect $ log $ "Is auth callback: " <> show isCallback
  if isCallback
    then do
      handleAuthentication
      accessTokenResponse <- getAccessToken
      case accessTokenResponse of
        Right accessToken -> do
          _ <- ensureUserExists accessToken
          liftEffect $ log $ "User logged in succesfully"
        Left error -> liftEffect $ log $ "error getting access token: " <> show error
    else login
--}

{--
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
--}

--main :: Effect Unit
--main = do
--  token <- getAT
--  log $ "Access token: " <> show token
