{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BangPatterns #-}
module Main where

import qualified Network.Wai.Handler.Warp as Warp
import qualified Network.Wai as Wai
import qualified Network.HTTP.Types as HTypes
import qualified Database.MySQL.Simple as MySQL
import qualified Data.Aeson as Aeson
import qualified Data.ByteString.Lazy as LBS
{-import qualified Data.Map as Map-}

import Data.Pool (Pool, createPool, withResource)
import Data.Aeson.Types (ToJSON,toJSON,object,(.=),FromJSON,(.:))
import Database.MySQL.Simple.QueryResults
import Database.MySQL.Simple.Result
import Data.Maybe (fromJust)
{-import Text.RawString.QQ (r)-}

data Todo = Todo {id :: Int, text :: String} deriving(Eq)

newtype Todo' = Todo' Todo deriving(Eq)

instance QueryResults Todo' where
    convertResults [fa,fb] [va,vb] = Todo' $ Todo a b
        where !a = convert fa va
              !b = convert fb vb
    convertResults fs vs  = convertError fs vs 2

instance ToJSON Todo where
  toJSON (Todo id text) =
    object ["id" .= id
           ,"text" .= text
           ]

instance ToJSON Todo' where
  toJSON (Todo' (Todo id text)) =
    object ["id" .= id
           ,"text" .= text
           ]

main :: IO ()
main = do
  cp <- createPool connect close 10 10 10
  withResource cp $ \conn -> MySQL.execute_ conn "CREATE TABLE IF NOT EXISTS todo (id INTEGER PRMARY KEY AUTOINCREMENTM,text TEXT NOT NULL)"
  withResource cp $ \conn -> MySQL.execute_ conn "INSERT INTO todo (text) VALUES (\"hoge\")"
  Warp.runSettings (
    Warp.setPort 8000 $
    Warp.defaultSettings
    ) $ routerApp cp
  where
    connect :: IO MySQL.Connection
    connect = MySQL.connect MySQL.defaultConnectInfo {
      MySQL.connectHost = "localhost",
      MySQL.connectUser = "root",
      MySQL.connectPassword = "Raise_1229",
      MySQL.connectDatabase = "todo"
    }
    close = MySQL.close
  

routerApp :: Pool MySQL.Connection -> Wai.Application
routerApp cp req = do {
  case Wai.requestMethod req of
    methodGET   -> router cp req
    methodPOST  -> postRouter cp req
    _           -> notFoundApp req
}

postRouter :: Pool MySQL.Connection -> Wai.Application
postRouter cp req =
  case Wai.pathInfo req of
    ["add"]     -> addHandler cp req
    ["delete"]  -> deleteHandler cp req
    _           -> notFoundApp req

addHandler :: Pool MySQL.Connection -> Wai.Application
addHandler cp req = undefined

deleteHandler :: Pool MySQL.Connection -> Wai.Application
deleteHandler cp req = undefined


router :: Pool MySQL.Connection -> Wai.Application
router cp req response =
  case Wai.pathInfo req of
    []       -> Aeson.encode <$> (withResource cp $ \conn ->  select_todo conn) >>= \bs -> response $ response200 bs

select_todo :: MySQL.Connection -> IO [Todo']
select_todo conn =
  MySQL.query_ conn "SELECT id, text FROM todo ORDER BY id"

helloApp :: Wai.Application
helloApp req send 
  = send $ Wai.responseBuilder HTypes.status200 [] "hello wai"

fooApp :: Wai.Application
fooApp req send
  = send $ Wai.responseBuilder HTypes.status200 [] "bar buz"

notFoundApp :: Wai.Application
notFoundApp req send
  = send $ Wai.responseBuilder HTypes.status404 [] "not found"

response200 :: LBS.ByteString -> Wai.Response
response200 = Wai.responseLBS HTypes.status200 [("Content-Type","application/json")] 