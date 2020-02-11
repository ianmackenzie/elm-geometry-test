port module CopyFromElmGeometry exposing (main)

import Json.Encode exposing (Value)
import Script exposing (Script)
import Script.Directory as Directory exposing (Directory, Writable)
import Script.File as File


ensureEmpty : Directory Writable -> Script String ()
ensureEmpty directory =
    Directory.checkExistence directory
        |> Script.thenWith
            (\existence ->
                case existence of
                    Directory.Exists ->
                        Directory.obliterate directory
                            |> Script.andThen (Directory.create directory)

                    Directory.DoesNotExist ->
                        Directory.create directory

                    Directory.IsNotADirectory ->
                        Script.fail (Directory.name directory ++ " already exists and is not a directory")
            )


script : Script.Init -> Script String ()
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
    ensureEmpty destinationDirectory
        |> Script.andThen (Directory.create (Directory.in_ destinationDirectory "Geometry"))
        |> Script.andThen (Directory.create (Directory.in_ destinationDirectory "Polygon2d"))
        |> Script.andThen
            (fileNames
                |> Script.each
                    (\fileName ->
                        File.copy (File.in_ sourceDirectory fileName)
                            (File.in_ destinationDirectory fileName)
                    )
            )


port requestPort : Value -> Cmd msg


port responsePort : (Value -> msg) -> Sub msg


main : Script.Program
main =
    Script.program script requestPort responsePort
