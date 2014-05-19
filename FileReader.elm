module FileReader where

{-| Library for reading files and creating file inputs.
You should probably get familiar with the  `Input` abstraction defined in
[`Graphics.Input`](Graphics-Input) library first.

# Creating file inputs
@docs fileInput 

# Custom file inputs
@docs customFileInput

# File drop zones
@docs fileDroppable

# Files and blobs
A `Blob` is just a fancy handle for some data with a known size. If we have
additional information, we call that blob a `File`.
@docs File, Blob, mimeType

# Slicing
@docs slice

# Reading
@docs FileReader, readAsText

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

{-| This is how you would create a basic file input.

    files : Input (Maybe File)
    files = input Nothing

    inputFile : Element
    inputFile = fileInput files.handle id

This creates your standard <input type='file'/> control that lets the user
select a file. Whenever that control changes it's state (i.e. when the
user selects file or cancels her choice) the resulting value will be used to
update the `files` input.
-}
fileInput : Handle a -> (Maybe File -> a) -> Element
fileInput = Native.FileReader.fileInput

{-| You can easily replace the standard input control with any `Element`.

    prettyThing : Element

    inputFile : Element
    inputFile = customFileInput files.handle id prettyThing

When the `inputFile` `Element` is clicked the user will be asked for a file.
-}
customFileInput : Handle a -> (Maybe File -> a) -> Element -> Element
customFileInput = Native.FileReader.customFileInput

{-| Catch a file that the user dragged and dropped on a specific `Element`.

    dropZone : Element
    dropZone = collage 200 200 [outlined (dashed black) <| rect 180 180]

    fileWell : Element
    fileWell = fileDroppable files.handle dropZone
-}
fileDroppable : Handle a -> Element -> Element
fileDroppable = Native.FileReader.fileDroppable

{-| Read a file. The input signal changes when user passes a file to
the browser. The output signal changes throughout the process of loading
file:
* before any user files are passed the `FileReader` signal has a value of `Ready`
* while loading the file each loaded chunk provokes an update to the signal with
a value of (`Progress` `total` `loaded`) where `total` is the total work to be
done in bytes and loaded is the work performed so far.
* after the loading ends the signal is updated to `Success` with the file contents
returned as `String`.
-}
readAsText : Signal (Maybe (Blob a)) -> Signal (FileReader String)
readAsText = Native.FileReader.readAsText

results : FileReader String -> Maybe String
results fileReader = case fileReader of
                            Success string -> Just string
                            _              -> Nothing

{-| `slice` will create a new `Blob` object containing the data in the specified
range of bytes of the source `Blob`. Note, that all `File`s are also `Blob`s.
`slice` takes two `Int` arguments:

* start is an index into the `Blob` indicating the first byte to copy into
the new `Blob`. If you specify a negative value, it's treated as an offset
from the end of the `Blob` toward the beginning. For example, -10 would be
the 10th from last byte in the `Blob`. If you specify a value for start
that is larger than the size of the source `Blob`, the returned `Blob`
has size 0 and contains no data.

* end is an index into the `Blob` indicating the last byte to copy into
the new `Blob`. If you specify a negative value, it's treated as an offset
from the end of the `Blob` toward the beginning. For example, -10 would be
the 10th from last byte in the `Blob`.
-}
slice : Int -> Int -> Blob a -> Blob {}
slice = Native.FileReader.slice

{-| Returns a (`Just` type) value indicating the MIME type of the data contained
in the `Blob`.
If the type is unknown, returns `Nothing`.
-}
mimeType : Blob a -> Maybe String
mimeType = Native.FileReader.mimeType
