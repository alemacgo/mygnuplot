module Main (main) where

import qualified System as S
import Lexer
import Parser
import TablaSimbolos
import GeneracionCodigo
import System.IO
import qualified Data.Map as Map

main = do
       args <- S.getArgs
       nombreEntrada <- return $ head args
       nombreSalida <- return $ (head args) ++ ".pl"

       aSalida <- openFile nombreSalida WriteMode

       contenido <- readFile nombreEntrada
       arbol <- return $ parse (lexer contenido)
       print arbol

       putStr (unlines $ "set term postscript" : generarCodigo arbol (Map.empty))
       --Cuando este listo activar esto, escribe en el archivo de texto
       --directamente!
       --hPutStr aSalida
       --        (unlines $ "set term postscript" : generarCodigo arbol (Map.empty))
       hClose aSalida
