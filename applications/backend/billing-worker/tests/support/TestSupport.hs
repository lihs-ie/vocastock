module TestSupport
  ( assertEqual,
    assertTrue,
    runNamed,
  )
where

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual label expected actual =
  if expected == actual
    then pure ()
    else
      error $
        label
          ++ " expected "
          ++ show expected
          ++ " but got "
          ++ show actual

assertTrue :: String -> Bool -> IO ()
assertTrue label condition =
  if condition
    then pure ()
    else error (label ++ " expected True but got False")

runNamed :: String -> IO () -> IO ()
runNamed _ action = action
