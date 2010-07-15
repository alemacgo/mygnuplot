module GeneracionCodigo (generarCodigo) where
import AS
import TablaSimbolos
import System.IO
import Debug.Trace
import qualified Data.Map as Map
import Data.Generics.Aliases

generarCodigo :: Bloque -> TablaDeSimbolos -> [String]
generarCodigo (Secuencia lista) tabla = traducir tabla lista
    where 
          traducir tabla ((DefFuncion nombre (Variable var) expresion):ls) =  
              --trace (show $ Map.insert nombre (var, expresion) tabla)
                    case revisarFuncion var expresion of
                        Nothing -> traducir (Map.insert nombre (var, simple) tabla) ls 
                                   where simple = expresionSimple tabla expresion
                        Just e  -> error $ "error: la funcion '" ++ nombre ++
                                   "' tiene la variable libre '" ++ e ++ "'"
                       
          traducir tabla ((Graficar rango expresion):ls) = 
              --trace (show tabla)
              instruccionGraficar : traducir tabla ls
              where instruccionGraficar = "plot " ++ evaluarEM tabla expresion 
          traducir tabla (_:ls) = traducir tabla ls
          traducir tabla [] = []

revisarFuncion :: String -> EM -> Maybe String
revisarFuncion var expresion = 
    case expresion of
        Suma e1 e2           -> revisarFuncion var e1 `orElse` revisarFuncion var e2 
        Resta e1 e2          -> revisarFuncion var e1 `orElse` revisarFuncion var e2 
        Multiplicacion e1 e2 -> revisarFuncion var e1 `orElse` revisarFuncion var e2 
        Division e1 e2       -> revisarFuncion var e1 `orElse` revisarFuncion var e2 
        Potencia e1 e2       -> revisarFuncion var e1 `orElse` revisarFuncion var e2 
        Menos e1             -> revisarFuncion var e1
        EMLlamada (LlamadaFuncion _ e1) -> revisarFuncion var e1
        EMVariable (Variable var_nueva) -> if var_nueva /= var
                                           then Just var_nueva -- variable libre
                                           else Nothing
        _                    -> Nothing -- casos base

-- Se asegura de que en 
expresionSimple :: TablaDeSimbolos -> EM -> EM
expresionSimple _ expresion = expresion

evaluarEM :: TablaDeSimbolos -> EM -> String
evaluarEM tabla (Suma e1 e2) =
         concat ["(", evaluarEM tabla e1, " + ", evaluarEM tabla e2, ")"]
evaluarEM tabla (Resta e1 e2) =
         concat ["(", evaluarEM tabla e1, " - ", evaluarEM tabla e2, ")"]
evaluarEM tabla (Multiplicacion e1 e2) =
         concat ["(", evaluarEM tabla e1, " * ", evaluarEM tabla e2, ")"]
evaluarEM tabla (Division e1 e2) =

         concat ["(", evaluarEM tabla e1, " / ", evaluarEM tabla e2, ")"]
evaluarEM tabla (Potencia e1 e2) =
         concat ["(", evaluarEM tabla e1, " ** ", evaluarEM tabla e2, ")"]
evaluarEM tabla (Menos e1) =
         concat ["-(", evaluarEM tabla e1, ")"]
evaluarEM tabla (Entero e1) = show e1
evaluarEM tabla (Real e1) = show e1
evaluarEM tabla (EMVariable (Variable s)) = "x"
evaluarEM tabla (EMLlamada (LlamadaFuncion nombre expresion)) =
        case Map.lookup nombre tabla of
              Nothing -> if nombre `elem` funcionesPredefinidas 
                         then concat [nombre, "(", evaluarEM tabla expresion, ")"] 
                         else error $ "error: no se encontro la funcion " ++ nombre
              Just e  -> evaluarEM tabla expresion -- desenrollar esta funcion!   

--traducir :: TablaDeSimbolos -> [Instruccion] -> [String]
--traducir tabla [] = ""
------ Definicion de funciones
--traducir tabla  ((DefFuncion nombre (Variable var) expresion):ls) = 
--    traducir (Map.insert nombre (var, expresion) tabla) ls

    --m <- Map.insert nombre (var, expresion) tabla -- se actualiza la tabla de simbolos
--traducir _ aSalida _ = ""
    
--traducir tabla _ (Asignacion _ em) = do
--    putStrLn $ evaluarEM tabla em 
--
--traducir tabla _ (Asignacion _ (EMLlamada (LlamadaFuncion nombre expresion))) = do
--    existe <- TablaSimbolos.lookup tabla nombre
--    case existe of
--         Nothing -> error $ "error: no existe la funcion " ++ nombre
--         Just _ -> return ()
---- Cualquier otro caso
--traducir _ aSalida _ = do
--                 --hPutStrLn aSalida "HOLA"
--                 return () -- no se genera codigo 

-- lv: lista de variables
--contarVariablesLibres :: LlamadaFuncion -> [String] -> Int
--contarVariablesLibres lv (LlamadaFuncion _ expresion) = cVL listaVar expresion
--    where cVL lv (Suma e1 e2) = cVL e1 + cVL e2
--          cVL lv (Resta e1 e2) = cVL e1 + cVL e2
--          cVL lv (Menos e1) = cVL e1
--          cVL lv (Multiplicacion e1 e2) = cVL e1 + cVL e2
--          cVL lv (Division e1 e2) = cVL e1 + cVL e2
--          cVL lv (Potencia e1 e2) = cVL e1 + cVL e2
--          cVL _ (Entero _) = 0
--          cVL _ (Real _) = 0
--          cVL f@(LlamadaFuncion _ _) = contarVariablesLibres f []
--          cVL lv EMVariable (Variable v) =  
--              case elemIndex v lv of
--                   Nothing -> 

--myReturn :: (Monad m) => m a -> a
--myReturn m a = a


--         case TablaSimbolos.lookup tabla nombre of
--              Nothing -> "a"
--              Just _ -> "b"
--         a <- return "hola2"
--         a
         --return a
         --a <- TablaSimbolos.lookup tabla nombre


    --case existe of
    --     Nothing -> error $ "error: no existe la funcion " ++ nombre
    --     Just _ -> return 'a'
--         show e1
--evaluarEM tabla (ArregloEM [EM] ) =
--         show e1

--producirEvaluacion :: LlamadaFuncion -> String
--producirEvaluacion (LlamadaFuncion f expresion) = cVL listaVar expresion
--    where cVL lv (Suma e1 e2) = cVL e1 + cVL e2
--          cVL lv (Resta e1 e2) = cVL e1 + cVL e2
--          cVL lv (Menos e1) = cVL e1
--          cVL lv (Multiplicacion e1 e2) = cVL e1 + cVL e2
--          cVL lv (Division e1 e2) = cVL e1 + cVL e2
--          cVL lv (Potencia e1 e2) = cVL e1 + cVL e2
--          cVL _ (Entero _) = 0
--          cVL _ (Real _) = 0
--          cVL f@(LlamadaFuncion _ _) = contarVariablesLibres f []
--          cVL lv EMVariable (Variable v) =  
--              case elemIndex v lv of
--                   Nothing -> 

