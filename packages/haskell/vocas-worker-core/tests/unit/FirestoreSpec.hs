{-# LANGUAGE OverloadedStrings #-}

module FirestoreSpec (run) where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString.Lazy.Char8 as LBS8
import Vocas.Worker.Core.Firestore
  ( encodeArrayField,
    encodeFieldsObject,
    encodeIntegerField,
    encodeMapField,
    encodeNullableStringField,
    encodeStringField,
    readArrayField,
    readIntegerField,
    readMapField,
    readNullableStringField,
    readStringField,
  )

run :: IO Bool
run = do
  putStrLn "# FirestoreSpec"
  cases <-
    sequence
      [ caseStringRoundTrip,
        caseNullableRoundTrip,
        caseIntegerRoundTrip,
        caseMapRoundTrip,
        caseArrayRoundTrip,
        caseFieldsEnvelope
      ]
  pure (all id cases)

assertTrue :: String -> Bool -> IO Bool
assertTrue label outcome =
  if outcome
    then do
      putStrLn ("  ok  " ++ label)
      pure True
    else do
      putStrLn ("  FAIL " ++ label)
      pure False

caseStringRoundTrip :: IO Bool
caseStringRoundTrip = do
  let encoded = encodeStringField "hello"
  let wrapper = Aeson.object [Key.fromText "field" Aeson..= encoded]
  case readStringField wrapper "field" of
    Just "hello" -> assertTrue "string round trip" True
    other -> assertTrue ("string round trip: " <> show other) False

caseNullableRoundTrip :: IO Bool
caseNullableRoundTrip = do
  let encodedNothing = encodeNullableStringField Nothing
  let encodedJust = encodeNullableStringField (Just "ok")
  let wrapperNothing = Aeson.object [Key.fromText "field" Aeson..= encodedNothing]
  let wrapperJust = Aeson.object [Key.fromText "field" Aeson..= encodedJust]
  result1 <- assertTrue "nullable Nothing" (readNullableStringField wrapperNothing "field" == Just Nothing)
  result2 <- assertTrue "nullable Just" (readNullableStringField wrapperJust "field" == Just (Just "ok"))
  pure (result1 && result2)

caseIntegerRoundTrip :: IO Bool
caseIntegerRoundTrip = do
  let encoded = encodeIntegerField 42
  let wrapper = Aeson.object [Key.fromText "n" Aeson..= encoded]
  assertTrue "integer round trip" (readIntegerField wrapper "n" == Just 42)

caseMapRoundTrip :: IO Bool
caseMapRoundTrip = do
  let encoded =
        encodeMapField
          [ ("inner", encodeStringField "value"),
            ("count", encodeIntegerField 3)
          ]
  let wrapper = Aeson.object [Key.fromText "nested" Aeson..= encoded]
  case readMapField wrapper "nested" of
    Just inner ->
      assertTrue
        "map round trip"
        (readStringField inner "inner" == Just "value" && readIntegerField inner "count" == Just 3)
    Nothing -> assertTrue "map round trip" False

caseArrayRoundTrip :: IO Bool
caseArrayRoundTrip = do
  let encoded = encodeArrayField [encodeStringField "a", encodeStringField "b"]
  let wrapper = Aeson.object [Key.fromText "items" Aeson..= encoded]
  case readArrayField wrapper "items" of
    Just values ->
      assertTrue
        "array round trip"
        ( length values == 2
            && case values of
              [v1, v2] ->
                let extract = \value -> case value of
                      Aeson.Object wrapperObj -> case KeyMap.lookup (Key.fromText "stringValue") wrapperObj of
                        Just (Aeson.String s) -> Just s
                        _ -> Nothing
                      _ -> Nothing
                 in extract v1 == Just "a" && extract v2 == Just "b"
              _ -> False
        )
    Nothing -> assertTrue "array round trip" False

caseFieldsEnvelope :: IO Bool
caseFieldsEnvelope = do
  let fieldsValue =
        encodeFieldsObject
          [("text", encodeStringField "run"), ("count", encodeIntegerField 1)]
  let serialized = LBS8.unpack (Aeson.encode fieldsValue)
  passed1 <-
    assertTrue
      "fields envelope contains text stringValue"
      (isInfixOf "\"text\":{\"stringValue\":\"run\"}" serialized)
  passed2 <-
    assertTrue
      "fields envelope contains count integerValue"
      (isInfixOf "\"count\":{\"integerValue\":\"1\"}" serialized)
  pure (passed1 && passed2)

isInfixOf :: Eq a => [a] -> [a] -> Bool
isInfixOf needle haystack = any (needle `isPrefixOf'`) (tails haystack)
  where
    tails [] = [[]]
    tails xs@(_ : rest) = xs : tails rest
    isPrefixOf' [] _ = True
    isPrefixOf' _ [] = False
    isPrefixOf' (x : xs) (y : ys) = x == y && isPrefixOf' xs ys
