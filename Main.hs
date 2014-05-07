{-# LANGUAGE OverloadedStrings #-}

import Control.Lens
import Control.Monad.IO.Class
import Data.Aeson.Lens
import Data.ByteString.Lazy
import Data.Monoid (mconcat)
import qualified Data.Text as T
import qualified Network.Wreq as W
import System.Environment (getEnv)
import Web.Scotty

data BuildResult = Success | Failure | Aborted | NotBuilt | Unstable

instance Show BuildResult where
  show Success = "success"
  show Failure = "failure"
  show Aborted = "aborted"
  show NotBuilt = "not built"
  show Unstable = "unstable"

jenkinsUrl :: String -> Maybe String
jenkinsUrl "fedora" = Just "http://jenkins.cloud.fedoraproject.org"
jenkinsUrl _        = Nothing

getBuildResult :: T.Text -> Maybe BuildResult
getBuildResult "SUCCESS"   = Just Success
getBuildResult "FAILURE"   = Just Failure
getBuildResult "ABORTED"   = Just Aborted
getBuildResult "NOT_BUILT" = Just NotBuilt
getBuildResult "UNSTABLE"  = Just Unstable
getBuildResult _           = Nothing

getShield :: BuildResult -> IO ByteString
getShield n = do
  r <- liftIO $ W.get ("http://img.shields.io/badge/build-" ++ show n ++ "-" ++ colorForResult n ++ ".svg")
  return $ r ^. W.responseBody
  where
    colorForResult Success = "brightgreen"
    colorForResult Failure = "red"
    colorForResult Aborted = "lightgrey"
    colorForResult NotBuilt = "yellowgreen"
    colorForResult Unstable = "blue"

main :: IO ()
main = do
  port <- fmap read $ getEnv "PORT"
  scotty port $ do
    get "/:jenkins/:project" $ do
      jenkins <- param "jenkins"
      case jenkinsUrl jenkins of
        Nothing -> do
          text $
            mconcat [ "That is not a valid jenkins key. To add a jenkins "
                    , "instance, see https://github.com/CodeBlock/shieldkins/"
                    ]
        Just u -> do
          project <- param "project"
          r <- liftIO $ W.get $ u ++ "/job/" ++ project ++ "/lastBuild/api/json"
          let s = fmap getShield (getBuildResult (r ^. W.responseBody . key "result" . _String))
          case s of
            Nothing -> text "Invalid result received from Jenkins."
            Just iobs -> do
              setHeader "Content-Type" "image/svg+xml"
              liftIO iobs >>= raw
