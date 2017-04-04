#!/usr/bin/env runhaskell

{-# LANGUAGE DeriveAnyClass, DeriveGeneric, OverloadedStrings, ScopedTypeVariables #-}

-- | Importing qualified packages
import qualified Data.ByteString.Lazy as DBL
import qualified Data.Text as T
import qualified Data.HashMap.Strict as HM

-- | Importing further Haskell packages
import Control.Applicative ((<$>))
import Data.Aeson -- You need to install this (cabal install aeson)
import Data.Aeson.Types
import Data.List
import Data.Maybe
import GHC.Generics
import Turtle -- You need to install this (cabal install turtle)

-- | Declaring fancy types
-- Not neccessary, but makes interpretation of the script easier.
type InBound_or_SubVer = String
type StartingHeight_or_Trust = Int
type Counter = Int
type DimensionTXT = Prelude.FilePath
type SetTXT = Prelude.FilePath

-- | Global variables
-- Change these filepath values at your discretion
chosenDirectory = "~/GRC-Netdata/getpeerinfo/"
dimensions_versions_filepath = chosenDirectory ++ "dimensions_peerinfo_versions.txt"
set_versions_filepath = chosenDirectory ++ "set_peerinfo_versions.txt"
trust_filepath = chosenDirectory ++ "peerinfo_trust.txt"
avg_trust_filepath = chosenDirectory ++ "avg_peerinfo_trust.txt"
height_filepath = chosenDirectory ++ "peerinfo_height.txt"
avg_height_filepath = chosenDirectory ++ "avg_peerinfo_height.txt"
dimensions_bound_filepath = chosenDirectory ++ "dimensions_peerinfo_bound.txt"
set_bound_filepath = chosenDirectory ++ "set_peerinfo_bound.txt"
infiniteList = [1 .. ]

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

-- | Counting the occurrence of unique list elements within a non-unique list
countedList :: [InBound_or_SubVer] -> [InBound_or_SubVer] ->  [(InBound_or_SubVer, Int)]
countedList [] referenceList = []
countedList (x:xs) referenceList = do
    let countedVal = (countIt x referenceList)
    -- | Input current countedVal, recursively call function with the tail of the input list.
    [(x, countedVal)] ++ countedList xs referenceList

-- | Writing the contents of each element of the list to file
-- Input the list of touples output by countedList
outputCountedList :: [(InBound_or_SubVer, Int)] -> DimensionTXT -> SetTXT -> Counter -> IO ExitCode
outputCountedList (x:xs) dimensionTXTFilePath setTXTFilePath counter = do
    
    -- | defining variables for use by shell
    let dimensionCounter = "Dimension" ++ (show counter)
    let dimensionTitle = fst x
    let dimensionValue = show (snd x)

    -- | How to catch empty xs when the output is IO?
    -- Perhaps worth trying "outputCountedList [] txtFilePath = []" for less code reuse
    if (xs == [])
        then do
            shell (T.pack ("echo 'DIMENSION " ++ dimensionCounter ++ " " ++ dimensionTitle ++ " absolute 1 1' >> " ++ dimensionTXTFilePath)) Turtle.empty
            shell (T.pack ("echo 'SET " ++ dimensionCounter ++ " = " ++ dimensionValue ++ "' >> " ++ setTXTFilePath)) Turtle.empty
        else do
            shell (T.pack ("echo 'DIMENSION " ++ dimensionCounter ++ " " ++ dimensionTitle ++ " absolute 1 1' >> " ++ dimensionTXTFilePath)) Turtle.empty
            shell (T.pack ("echo 'SET " ++ dimensionCounter ++ " = " ++ dimensionValue ++ "' >> " ++ setTXTFilePath)) Turtle.empty
            outputCountedList xs dimensionTXTFilePath setTXTFilePath (counter + 1)

-- | Outputting the contents of the list to a text file
-- This isn't actually that useful, as we can't/shouldn't have 200+ lines within a graph!
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

-- | Outputting the average of a list of values
-- Used for outputting average starting block height & trust levels
outputAvgValues :: [StartingHeight_or_Trust] -> Prelude.FilePath -> IO ExitCode
outputAvgValues inputList txtFilePath = do
    let listTotal = foldl (+) 0 inputList
    let quantityElementsInList = countList inputList 0
    let avgVal = listTotal`div`quantityElementsInList
    shell (T.pack ("echo '" ++ (show avgVal) ++ "' >> " ++ txtFilePath)) Turtle.empty

-- | Counting the elements within a given list
countList :: [StartingHeight_or_Trust] -> Counter -> Int
countList [] counterVal = counterVal
countList (x:xs) counterVal = countList xs (counterVal + 1) 

-- | Main function that is called from prelude!
main :: IO ExitCode
main = do

    -- | Empty the contents of the existing files!
    -- -n to prevent adding an empty line to the file
    shell (T.pack ("echo -n '' > " ++ dimensions_versions_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ set_versions_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ trust_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ avg_trust_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ height_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ avg_height_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ dimensions_bound_filepath)) Turtle.empty
    shell (T.pack ("echo -n '' > " ++ set_bound_filepath)) Turtle.empty


    -- | gridcoinresearchd until the script is proven working in VM
    -- You will need to change this depending on your gridcoin setup!
      -- shell ("gridcoinresearchd getpeerinfo > echo > getpeerinfo.json") Turtle.empty
      -- shell ("grc getpeerinfo > echo > getpeerinfo.json") Turtle.empty
    -- shell ("sudo -u gridcoin gridcoinresearchd -datadir=/home/gridcoin/.GridcoinResearch/ getpeerinfo > echo > getpeerinfo.json") Turtle.empty
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
    outputCountedList (countedList (nub sVList) sVList) dimensions_versions_filepath set_versions_filepath 0
    outputCountedList (countedList (nub ibList) ibList) dimensions_bound_filepath set_bound_filepath 0
    -- Unorered output to text files
    outputUnorderedList shList height_filepath
    outputUnorderedList nTList trust_filepath

    -- Avg trust
    outputAvgValues shList avg_height_filepath
    -- Avg Height
    outputAvgValues nTList avg_trust_filepath