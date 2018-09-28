module ReceiptListView  (State, Query(..), ui) where

import Prelude

import Api (getReceipts, receiptFileUrl)
import Auth (getAccessToken)
import Data.Array (length)
import Data.DateTime (adjust)
import Data.DateTime.Instant (instant, toDateTime)
import Data.Either (Either(..))
import Data.Formatter.DateTime as FDT
import Data.Formatter.Number (formatOrShowNumber)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Time.Duration (Minutes)
import Effect.Aff (Aff, Milliseconds(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Models (Receipt(..))
import ReceiptView as ReceiptView

data Slot = ReceiptViewSlot
derive instance eqSlot :: Eq Slot
derive instance ordSlot :: Ord Slot

type State =
  { loading :: Boolean
  , receipts :: Array Receipt
  , selectedReceipt :: Maybe Receipt
  , error :: Maybe String
  , timezoneOffset :: Minutes
  }

data Query a
  = Initialize a
  | SelectReceipt Receipt a
  | HandleReceiptView (ReceiptView.Message) a

getReceiptList :: Aff (Either String (Array Receipt))
getReceiptList = do
  accessTokenRes <- getAccessToken
  case accessTokenRes of
    Right accessToken -> getReceipts accessToken
    Left error -> pure $ Left error

renderReceipt :: Minutes -> Receipt -> H.ParentHTML Query ReceiptView.Query Slot Aff
renderReceipt timezoneOffset receipt@(Receipt r) =
  HH.li
    [ HP.class_ (HH.ClassName "mdc-list-item") ]
    [ HH.span
        [ HP.class_ (HH.ClassName "mdc-list-item__text")
        , HE.onClick (HE.input_ (SelectReceipt receipt))
        ]
        [ HH.span
            [ HP.class_ (HH.ClassName "mdc-list-item__primary-text") ]
            [ HH.text $ formatTotal r.total <> show (receiptFileUrl receipt) ]
        , HH.span
            [ HP.class_ (HH.ClassName "mdc-list-item__secondary-text") ]
            [ HH.text r.description ]
        ]
    , HH.span
        [ HP.class_ (HH.ClassName "mdc-list-item__meta") ]
        [ HH.text $ formatMilliseconds r.transactionTime timezoneOffset ]
    ]

formatTotal :: Maybe Number -> String
formatTotal (Just total) = "$" <> formatOrShowNumber "0.00" total
formatTotal Nothing = ""

formatMilliseconds :: Number -> Minutes -> String
formatMilliseconds timestamp timezoneOffset = fromMaybe "date-error" do
  dt <- map toDateTime (instant $ Milliseconds timestamp)
  adjusted <- adjust timezoneOffset dt
  pure $ case FDT.formatDateTime "YYYY-MM-DD HH:mm" adjusted of
    Left error -> error
    Right formatted -> formatted

renderReceipts :: Minutes -> Array Receipt -> H.ParentHTML Query ReceiptView.Query Slot Aff
renderReceipts timezoneOffset receipts =
  HH.ul
    [ HP.class_ (HH.ClassName "mdc-list mdc-list--two-line") ]
    (map (renderReceipt timezoneOffset) receipts)

renderStats :: Array Receipt -> H.ParentHTML Query ReceiptView.Query Slot Aff
renderStats receipts =
  HH.div_
    [ HH.text $ "Total receipts: " <> (show $ length receipts) ]

ui :: H.Component HH.HTML Query Minutes Void Aff
ui =
  H.lifecycleParentComponent
    { initialState: initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    }
  where

  initialState :: Minutes -> State
  initialState timezoneOffset =
    { loading: false
    , receipts: []
    , selectedReceipt: Nothing
    , error: Nothing
    , timezoneOffset: timezoneOffset
  }

  render :: State -> H.ParentHTML Query ReceiptView.Query Slot Aff
  render st =
    HH.div_ $
      [ renderReceipts st.timezoneOffset st.receipts
      , HH.p_
        [ HH.text (if st.loading then "Working..." else "") ]
      , case st.selectedReceipt of
          Just receipt -> HH.slot ReceiptViewSlot ReceiptView.ui receipt (HE.input HandleReceiptView)
          Nothing -> renderStats st.receipts
      ]

  eval :: Query ~> H.ParentDSL State Query ReceiptView.Query Slot Void Aff
  eval = case _ of
    Initialize next -> do
      H.modify_ (_ { loading = true })
      receiptsRes <- H.liftAff getReceiptList
      case receiptsRes of
        Right receipts -> do
          H.modify_ (_ { loading = false, receipts = receipts })
        Left error -> do
          H.modify_ (_ { loading = false, error = Just error })
      pure next
    SelectReceipt receipt next -> do
      H.modify_ (_ { selectedReceipt = Just receipt })
      _ <- H.query ReceiptViewSlot $ H.action (ReceiptView.SetReceipt receipt)
      pure next
    HandleReceiptView _ next -> do
      pure next
