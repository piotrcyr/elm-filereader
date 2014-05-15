module FileReader where

{-| FileReader module for elm, to be documented, promise
-}

import Signal(Signal)
import Basics(String)
import Date(Date)
import Graphics.Input (Handle)
import Native.FileReader

type Blob a = { a | size : Int }

type File = Blob { name : String, lastModifiedDate: Date }

data Error  = NOT_FOUND_ERR
            | SECURITY_ERR
            | NOT_READABLE_ERR
            | ENCODING_ERR
            | ABORT_ERR

data FileReader a   = Ready
                    | Success a
                    | Progress Int Int
                    | Error Error


fileInput : Handle a -> (Maybe File -> a) -> Element
fileInput = Native.FileReader.fileInput

customFileInput : Handle a -> (Maybe File -> a) -> Element -> Element
customFileInput = Native.FileReader.customFileInput

fileDroppable : Handle a -> Element -> Element
fileDroppable = Native.FileReader.fileDroppable

readAsText : Signal (Maybe (Blob a)) -> Signal (FileReader String)
readAsText = Native.FileReader.readAsText

results : FileReader String -> Maybe String
results fileReader = case fileReader of
                            Success string -> Just string
                            Error error    -> Just (show error)
                            _              -> Nothing

slice : Int -> Int -> Blob a -> Blob {}
slice = Native.FileReader.slice

mimeType : Blob a -> Maybe String
mimeType = Native.FileReader.mimeType
