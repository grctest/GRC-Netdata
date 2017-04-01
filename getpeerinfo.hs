#!/usr/bin/env runhaskell

{-# LANGUAGE DeriveAnyClass, DeriveGeneric, OverloadedStrings, ScopedTypeVariables #-}

import qualified Data.ByteString.Lazy as DBL
import qualified Data.Text as T
import qualified Data.HashMap.Strict as HM

import Control.Applicative ((<$>))
import Data.Aeson
import Data.Aeson.Types
import Data.List
import Data.Maybe
import GHC.Generics
import Turtle

-- | Declaring fancy types
-- Not neccessary, but makes interpretation of the script easier.
type InBound = Bool
type StartingHeight = Int
type Trust = Int
type SubVer = String

-- | Global variables
-- Change these filepath values at your discretion
versions_filepath = "peerinfo_versions.txt"
trust_filepath = "peerinfo_trust.txt"
height_filepath = "peerinfo_height.txt"
bound_filepath = "peerinfo_bound.txt"
empty_file = ""

-- | Configuring Aeson to handle the getpeerinfo.json fields
data GetPeerInfo = GetPeerInfo { subver :: String
                                 , inbound :: Bool
                                 , startingheight :: Int
                                 , nTrust :: Int
                                 } deriving (Show, Generic, Eq)

instance ToJSON GetPeerInfo where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON GetPeerInfo

    -- | Example of 'getpeerinfo' command.
    --{
    --    "addr" : "158.69.48.143:32749",
    --    "services" : "00000001",
    --    "lastsend" : 1490978975,
    --    "lastrecv" : 1490978975,
    --    "conntime" : 1490978864,
    --    "pingtime" : 0.31145300,
    --    "version" : 180322,
    --    "subver" : "/Nakamoto:3.5.8.7(0)/",
    --    "inbound" : false,
     --   "startingheight" : 858387,
    --    "sNeuralNetworkVersion" : "",
    --    "nTrust" : 0,
    --    "banscore" : 0,
    --    "Neural Network" : false,
    --    "Neural Hash" : ""
    --}

-- | Specify the filename of the JSON file we want to import
jsonFile :: Prelude.FilePath
jsonFile = "getpeerinfo.json"

-- | Specifying the filepath of the text file we want to write to
-- Users need to modify this to suit their gridcoin installation.
outputFileVersions :: Prelude.FilePath
outputFileVersions = "peerinfo_versions.txt"

-- | File path for output file containing peer starting heights
outputFileHeight :: Prelude.FilePath
outputFileHeight = "peerinfo_height.txt"

-- | File path for output file containing peer trust 
outputFileTrust :: Prelude.FilePath
outputFileTrust = "peerinfo_trust.txt"

-- | Full JSON data in, list of subver out
jsonToSubVerList :: [GetPeerInfo] -> [SubVer]
jsonToSubVerList [] = []
jsonToSubVerList (x:xs) = do
    [subver x] ++ jsonToSubVerList xs

-- | Full JSON data in, list of nTrust out
jsonToTrustList :: [GetPeerInfo] -> [Trust]
jsonToTrustList [] = []
jsonToTrustList (x:xs) = do
    [nTrust x] ++ jsonToTrustList xs

-- | Full JSON data in, list of startingHeights out
jsonToStartingHeightList :: [GetPeerInfo] -> [StartingHeight]
jsonToStartingHeightList [] = []
jsonToStartingHeightList (x:xs) = do
    [startingheight x] ++ jsonToStartingHeightList xs

-- | Full JSON data in, list of inbound values
-- Establish the quantity|percent of connections which full node is seeding.
-- Area chart! (x% false, y% true; x+y=100%) 
jsonToBoundList :: [GetPeerInfo] -> [InBound]
jsonToBoundList [] = []
jsonToBoundList (x:xs) = do
    [inbound x] ++ jsonToBoundList xs

-- | Counting occurrence of item in a list
-- source: https://stackoverflow.com/questions/19554984/haskell-count-occurrences-function
countIt :: Eq a => a -> [a] -> Int
countIt x = length . filter (x==)

countedList :: [a] -> [a] ->  [(a, Int)]
countedList [] referenceList = []
countedList (x:xs) referenceList = do
    let countedVal = (countIt x referenceList)
    [(x, countedVal)]

-- | Writing the contents of each element of the list to file
-- Input the list of touples output by countedList
outputCountedList :: [(a, Int)] -> Prelude.FilePath -> IO ()
outputCountedList (x:xs) txtFilePath = do
    let contents = T.pack((fst x) ++ " " ++ (show (snd x)))

    -- | How to catch empty xs when the output is IO?
    -- Perhaps worth trying "outputCountedList [] txtFilePath = []" for less code reuse
    if (xs == [])
        then do
            (appendFile txtFilePath contents)
        else do
            (appendFile txtFilePath contents)
            outputCountedList xs txtFilePath

outputUnorderedList :: [String] -> Prelude.FilePath -> IO ()
outputUnorderedList (x:xs) txtFilePath = do
    -- | How to catch empty xs when the output is IO?
    -- Perhaps worth trying "outputCountedList [] txtFilePath = []" for less code reuse
    if (xs == [])
        then do
            (appendFile txtFilePath x)
        else do
            (appendFile txtFilePath x)
            outputUnorderedList xs txtFilePath

-- | Main function that is called from prelude!
main :: IO ()
main = do

    shell "echo '' > peerinfo_versions.txt" Turtle.empty
    shell "echo '' > peerinfo_trust.txt" Turtle.empty
    shell "echo '' > peerinfo_height.txt" Turtle.empty
    shell "echo '' > peerinfo_bound.txt" Turtle.empty


    -- | Fancy way of clearing the file
    -- Doesn't work, this is IO & ends the output (shell line etc isn't called).
    -- benchmark shell vs writefile? perhaps just delete
    --writeFile versions_filepath empty_file --sVList
    --writeFile trust_filepath empty_file --nTList
    --writeFile height_filepath empty_file --shList
    --writeFile bound_filepath empty_file --ibList

    -- | gridcoinresearchd until the script is proven working in VM
    shell ("gridcoinresearchd getpeerinfo > echo > getpeerinfo.json") Turtle.empty

    -- | Finally works! Reads getpeerinfo.json from disk into memory!
    -- From this point onwards, we can reuse getpeerinfoJSON.
    gerpeerinfoJSON <- decode <$> (DBL.readFile jsonFile) :: IO (Maybe [GetPeerInfo])

    -- | Converting JSON to seperate lists
    let sVList = (jsonToSubVerList (fromJust gerpeerinfoJSON))
    --let nTList = (jsonToTrustList (fromJust gerpeerinfoJSON))
    --let shList = (jsonToStartingHeightList (fromJust gerpeerinfoJSON))
    --let ibList = (jsonToBoundList (fromJust gerpeerinfoJSON))

    -- | Writing data to text files
    -- Counted lists (frequency of occurrence)
    outputCountedList sVList versions_filepath 
    --outputCountedList nTList trust_filepath --Trust could be totaled or averaged, perhaps better than 200 lines (less resource hungry)
    --outputCountedList ibList bound_filepath 

    -- | Writing data to text file
    -- Unsorted data
    --outputUnorderedList shList height_filepath

    print "End!"

{-|
-- Example getpeerinfo in list format
["/Nakamoto:3.5.8.7(317.1999)/","/Nakamoto:3.5.8.7(317.1999)/","/Nakamoto:3.5.8.7(317.1999)/","/Nakamoto:3.5.8.7(317.1999)/","/Nakamoto:3.5.8.7(317.1999)/","/Nakamoto:3.5.8.7(0)/","/Nakamoto:3.5.8.7(0)/","/Nakamoto:3.5.8.7(0)/"]
[9,2,1,2,1,1,0,2]
[858608,858608,858608,858608,858608,858609,858610,858610]
[False,False,False,False,False,False,False,False]
-}