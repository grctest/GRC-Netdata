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
type InBound_or_SubVer = String
type StartingHeight_or_Trust = Int

-- | Global variables
-- Change these filepath values at your discretion
versions_filepath = "peerinfo_versions.txt"
trust_filepath = "peerinfo_trust.txt"
height_filepath = "peerinfo_height.txt"
bound_filepath = "peerinfo_bound.txt"

-- | Configuring Aeson to handle the getpeerinfo.json fields
data GetPeerInfo = GetPeerInfo { subver :: String
                                 , inbound :: Bool
                                 , startingheight :: Int
                                 , nTrust :: Int
                                 } deriving (Show, Generic, Eq)

-- | Currently having issues using the custom data type.
-- Step 1 is to write the code messily.
-- Step 2 is to consolodate code.
--data OrderedListInputTypes = InBoundD [InBound] | SubVerD SubVer deriving (Show, Generic, Eq)

-- data UnorderedTypes = StartingHeightD [StartingHeight] | TrustD [Trust] deriving (Show, Generic, Eq)

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

-- | Full JSON data in, list of subver out
jsonToSubVerList :: [GetPeerInfo] -> [InBound_or_SubVer]
jsonToSubVerList [] = []
jsonToSubVerList (x:xs) = do
    [subver x] ++ jsonToSubVerList xs

-- | Full JSON data in, list of nTrust out
jsonToTrustList :: [GetPeerInfo] -> [StartingHeight_or_Trust]
jsonToTrustList [] = []
jsonToTrustList (x:xs) = do
    [nTrust x] ++ jsonToTrustList xs

-- | Full JSON data in, list of startingHeights out
jsonToStartingHeightList :: [GetPeerInfo] -> [StartingHeight_or_Trust]
jsonToStartingHeightList [] = []
jsonToStartingHeightList (x:xs) = do
    [startingheight x] ++ jsonToStartingHeightList xs

-- | Converting boolean to string for output to text file
-- source: https://stackoverflow.com/questions/37019716/how-do-we-convert-boolean-to-string-in-haskell
boolToString :: Bool -> String
boolToString True = "TRUE"
boolToString False = "FALSE"

-- | Full JSON data in, list of inbound values
-- Establish the quantity|percent of connections which full node is seeding.
-- Area chart! (x% false, y% true; x+y=100%) 
jsonToBoundList :: [GetPeerInfo] -> [InBound_or_SubVer]
jsonToBoundList [] = []
jsonToBoundList (x:xs) = do
    -- | Convert boolean value to string, as bools cannot be written to disk.
    -- Kinda ugly, but deal w/ it.
    let currentBoolVal = boolToString (inbound x)
    -- | Write current bool string to list
    -- Recursively call jsonToBoundList, passing the rest of the list in as input.
    [currentBoolVal] ++ jsonToBoundList xs

-- | Counting occurrence of item in a list
-- source: https://stackoverflow.com/questions/19554984/haskell-count-occurrences-function
countIt :: Eq a => a -> [a] -> Int
countIt x = length . filter (x==)

countedList :: [InBound_or_SubVer] -> [InBound_or_SubVer] ->  [(InBound_or_SubVer, Int)]
countedList [] referenceList = []
countedList (x:xs) referenceList = do
    let countedVal = (countIt x referenceList)
    -- | Input current 
    [(x, countedVal)] ++ countedList xs referenceList

-- | Writing the contents of each element of the list to file
-- Input the list of touples output by countedList
outputCountedList :: [(InBound_or_SubVer, Int)] -> Prelude.FilePath -> IO ExitCode
outputCountedList (x:xs) txtFilePath = do
    --let contents = T.pack((fst x) ++ " " ++ (show (snd x)))
    let contents = ((fst x)) ++ " " ++ (show (snd x))
    --print contents
    -- | How to catch empty xs when the output is IO?
    -- Perhaps worth trying "outputCountedList [] txtFilePath = []" for less code reuse
    if (xs == [])
        then do
            shell (T.pack ("echo '" ++ contents ++ "' >> " ++ txtFilePath)) Turtle.empty
            --(appendFile txtFilePath contents)
        else do
            shell (T.pack ("echo '" ++ contents ++ "' >> " ++ txtFilePath)) Turtle.empty
            --(appendFile txtFilePath contents) -- Does appendFile cut off the next line from running? Might need to switch for shell!
            outputCountedList xs txtFilePath

outputUnorderedList :: [StartingHeight_or_Trust] -> Prelude.FilePath -> IO ExitCode
outputUnorderedList (x:xs) txtFilePath = do
    --print x
    -- | How to catch empty xs when the output is IO?
    -- Perhaps worth trying "outputCountedList [] txtFilePath = []" for less code reuse
    if (xs == [])
        then do
            shell (T.pack ("echo '" ++ (show x) ++ "' >> " ++ txtFilePath)) Turtle.empty
        else do
            shell (T.pack ("echo '" ++ (show x) ++ "' >> " ++ txtFilePath)) Turtle.empty
            outputUnorderedList xs txtFilePath -- Does appendFile cut off the next line from running? Might need to switch for shell!

-- | Main function that is called from prelude!
main :: IO ExitCode
main = do

    -- | Empty the contents of the existing files!
    -- -n to prevent adding an empty line to the file
    shell "echo -n '' > peerinfo_versions.txt" Turtle.empty
    shell "echo -n '' > peerinfo_trust.txt" Turtle.empty
    shell "echo -n '' > peerinfo_height.txt" Turtle.empty
    shell "echo -n '' > peerinfo_bound.txt" Turtle.empty

    -- | gridcoinresearchd until the script is proven working in VM
    -- You will need to change this depending on your gridcoin setup!
    -- shell ("gridcoinresearchd getpeerinfo > echo > getpeerinfo.json") Turtle.empty
    shell ("grc getpeerinfo > echo > getpeerinfo.json") Turtle.empty

    -- | Finally works! Reads getpeerinfo.json from disk into memory!
    -- From this point onwards, we can reuse getpeerinfoJSON.
    gerpeerinfoJSON <- decode <$> (DBL.readFile jsonFile) :: IO (Maybe [GetPeerInfo])

    -- | Converting JSON to seperate lists
    let sVList = (jsonToSubVerList (fromJust gerpeerinfoJSON))
    let nTList = (jsonToTrustList (fromJust gerpeerinfoJSON))
    let shList = (jsonToStartingHeightList (fromJust gerpeerinfoJSON))
    let ibList = (jsonToBoundList (fromJust gerpeerinfoJSON))

    -- | Writing data to text files
    -- Counted lists (frequency of occurrence)
    outputCountedList (countedList (nub sVList) sVList) versions_filepath
    outputCountedList (countedList (nub ibList) ibList) bound_filepath
    -- Unorered output to text files
    outputUnorderedList shList height_filepath
    outputUnorderedList nTList trust_filepath

    --print "End!"