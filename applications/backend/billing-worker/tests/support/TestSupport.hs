module TestSupport
  ( assertEqual,
    assertTrue,
    runNamed,
  )
where

runNamed :: String -> IO Bool -> IO Bool
runNamed label body = do
  putStrLn ("# " ++ label)
  body

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO Bool
assertEqual label expected actual
  | expected == actual = do
      putStrLn ("  ok  " ++ label)
      pure True
  | otherwise = do
      putStrLn
        ( "  FAIL "
            ++ label
            ++ "\n    expected="
            ++ show expected
            ++ "\n    actual="
            ++ show actual
        )
      pure False

assertTrue :: String -> Bool -> IO Bool
assertTrue label outcome
  | outcome = do
      putStrLn ("  ok  " ++ label)
      pure True
  | otherwise = do
      putStrLn ("  FAIL " ++ label)
      pure False
