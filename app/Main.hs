{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Network.Wai.Handler.Warp as Warp
import qualified Network.Wai as Wai
import qualified Network.HTTP.Types as HTypes

main :: IO ()
main = Warp.run 8000 router

router :: Wai.Application
router req =
  case Wai.pathInfo req of
    []       -> helloApp req
    ["foo"]  -> fooApp req
    _        -> notFoundApp req

helloApp :: Wai.Application
helloApp req send 
  = send $ Wai.responseBuilder HTypes.status200 [] "hello wai"

fooApp :: Wai.Application
fooApp req send
  = send $ Wai.responseBuilder HTypes.status200 [] "bar buz"

notFoundApp :: Wai.Application
notFoundApp req send
  = send $ Wai.responseBuilder HTypes.status404 [] "not found"