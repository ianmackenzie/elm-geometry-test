port module CopyFromElmGeometry exposing (main)

import Json.Encode exposing (Value)
import Script exposing (Script)
import Script.Directory as Directory
import Script.File as File


script : Script.Init -> Script Int ()
script { userPrivileges } =
    let
        sourceDirectory =
            Directory.readOnly userPrivileges "C:/Git/ianmackenzie/elm-geometry/src"

        destinationDirectory =
            Directory.writable userPrivileges "C:/Git/ianmackenzie/elm-geometry-test/src"

        fileNames =
            [ "Geometry/Fuzz.elm"
            , "Geometry/Expect.elm"
            , "Polygon2d/Random.elm"
            ]
    in
    Directory.obliterate destinationDirectory
        |> Script.andThen (Directory.create destinationDirectory)
        |> Script.andThen (Directory.create (Directory.subdir destinationDirectory "Geometry"))
        |> Script.andThen (Directory.create (Directory.subdir destinationDirectory "Polygon2d"))
        |> Script.andThen
            (fileNames
                |> Script.each
                    (\fileName ->
                        File.copy (File.in_ sourceDirectory fileName)
                            (File.in_ destinationDirectory fileName)
                    )
            )
        |> Script.onError
            (\{ message } -> Script.printLine message |> Script.andThen (Script.fail 1))


port requestPort : Value -> Cmd msg


port responsePort : (Value -> msg) -> Sub msg


main : Script.Program
main =
    Script.program script requestPort responsePort
