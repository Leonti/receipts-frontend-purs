module ReceiptView  (State, Query(..), Message(..), ui) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Models (Receipt(..))

type State =
  { receipt :: Receipt
  , total :: String
  , description :: String
  }

data Message = Updated Receipt

data Query a
  = SetReceipt Receipt a

ui :: H.Component HH.HTML Query Receipt Message Aff
ui =
  H.lifecycleComponent
    { initialState: initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  initialState :: Receipt -> State
  initialState receipt@(Receipt r) =
    { receipt: receipt
    , total: show r.total
    , description: r.description
    }

  render :: State -> H.ComponentHTML Query
  render st =
    HH.div_ $
      [ HH.text st.total
      ]

  eval :: Query ~> H.ComponentDSL State Query Message Aff
  eval = case _ of
    SetReceipt receipt next -> do
      H.modify_ (\_ -> initialState receipt)
      pure next
