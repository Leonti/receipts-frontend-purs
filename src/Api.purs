module Api(getReceipts, ensureUserExists, receiptFileUrl) where

import Prelude

import Affjax as AX
import Affjax.RequestBody (RequestBody(..))
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Auth (AccessToken(..))
import Data.Argonaut (class EncodeJson, decodeJson, encodeJson, jsonEmptyObject, (.?), (:=), (~>))
import Data.Argonaut.Core as J
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Models (File(..), Receipt(..), UserInfo(..))
import Data.Array (head)

receiptFileUrl :: Receipt -> Maybe String
receiptFileUrl (Receipt receipt) = map (\(File file) -> "http://localhost:9000/receipt/" <> receipt.id <> "/file/" <> file.id <>  "." <> file.ext) (head receipt.files)

getReceipts :: AccessToken -> Aff (Either String (Array Receipt))
getReceipts (AccessToken accessToken) = do
  res <- AX.request (AX.defaultRequest
    { url = "http://localhost:9000/receipt"
    , method = Left GET
    , headers = [RequestHeader "Authorization" ("Bearer " <> accessToken) ]
    , responseFormat = ResponseFormat.json
    })
  case res.body of
    Left err -> pure $ Left $ AX.printResponseFormatError err
    Right json -> pure $ decodeJson json

newtype OpenIdToken = OpenIdToken { token :: String }
instance encodeJsonOpenIdToken :: EncodeJson OpenIdToken where
  encodeJson (OpenIdToken token)
     = "token" := token.token
    ~> jsonEmptyObject

ensureUserExists :: AccessToken -> Aff (Either String UserInfo)
ensureUserExists (AccessToken accessToken) = do
  res <- AX.request (AX.defaultRequest
    { url = "http://localhost:9000/oauth/openid"
    , method = Left POST
    , content = Just $ Json $ encodeJson (OpenIdToken { token: accessToken })
    , headers = [RequestHeader "Authorization" ("Bearer " <> accessToken) ]
    , responseFormat = ResponseFormat.json
    })
  case res.body of
    Left err -> pure $ Left $ AX.printResponseFormatError err
    Right json -> pure $ decodeJson json
