module Models where

import Prelude (bind, pure, ($))
import Data.Maybe (Maybe)
import Data.Show
import Data.Argonaut (class DecodeJson, decodeJson, (.?))
--import Data.Argonaut (class DecodeJson, decodeJson, class EncodeJson, jsonEmptyObject, (~>), (:=), (.?))

newtype File = File
  { id :: String
  , parentId :: Maybe String
  , ext :: String
  }

newtype Receipt = Receipt
  { id :: String
  , files :: Array File
  , description :: String
  , total :: Maybe Number
  , timestamp :: Number
  , lastModified :: Number
  , transactionTime :: Number
  , tags :: Array String
  }

newtype UserInfo = UserInfo
  { id :: String
  , userName :: String
  }

instance decodeJsonFile :: DecodeJson File where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .? "id"
    parentId <- obj .? "parentId"
    ext <- obj .? "ext"
    pure $ File { id: id, parentId: parentId, ext: ext }

instance decodeJsonReceipt :: DecodeJson Receipt where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .? "id"
    files <- obj .? "files"
    description <- obj .? "description"
    total <- obj .? "total"
    timestamp <- obj .? "timestamp"
    lastModified <- obj .? "lastModified"
    transactionTime <- obj .? "transactionTime"
    tags <- obj .? "tags"
    pure $ Receipt
      { id: id
      , files: files
      , description: description
      , total: total
      , timestamp: timestamp
      , lastModified: lastModified
      , transactionTime: transactionTime
      , tags: tags
      }

instance showReceipt :: Show Receipt where
  show (Receipt receipt) = receipt.id

instance decodeUserInfo :: DecodeJson UserInfo where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .? "id"
    userName <- obj .? "userName"
    pure $ UserInfo { id: id, userName: userName }

instance showUserInfo :: Show UserInfo where
  show (UserInfo userInfo) = userInfo.userName
