#
#
#           The Nim Compiler
#        (c) Copyright 2015 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

# This module handles the conditional symbols.

import
  strtabs

from options import Feature
from lineinfos import HintsToStr, WarningsToStr

proc defineSymbol*(symbols: StringTableRef; symbol: string, value: string = "true") =
  symbols[symbol] = value

proc undefSymbol*(symbols: StringTableRef; symbol: string) =
  symbols.del(symbol)

#proc lookupSymbol*(symbols: StringTableRef; symbol: string): string =
#  result = if isDefined(symbol): gSymbols[symbol] else: nil

iterator definedSymbolNames*(symbols: StringTableRef): string =
  for key, val in pairs(symbols):
    yield key

proc countDefinedSymbols*(symbols: StringTableRef): int =
  symbols.len

proc initDefines*(symbols: StringTableRef) =
  # for bootstrapping purposes and old code:
  template defineSymbol(s) = symbols.defineSymbol(s)
  defineSymbol("nimhygiene")
  defineSymbol("niminheritable")
  defineSymbol("nimmixin")
  defineSymbol("nimeffects")
  defineSymbol("nimbabel")
  defineSymbol("nimcomputedgoto")
  defineSymbol("nimunion")
  defineSymbol("nimnewshared")
  defineSymbol("nimNewTypedesc")
  defineSymbol("nimrequiresnimframe")
  defineSymbol("nimparsebiggestfloatmagic")
  defineSymbol("nimalias")
  defineSymbol("nimlocks")
  defineSymbol("nimnode")
  defineSymbol("nimvarargstyped")
  defineSymbol("nimtypedescfixed")
  defineSymbol("nimKnowsNimvm")
  defineSymbol("nimArrIdx")
  defineSymbol("nimHasalignOf")
  defineSymbol("nimDistros")
  defineSymbol("nimHasCppDefine")
  defineSymbol("nimGenericInOutFlags")
  when false: defineSymbol("nimHasOpt")
  defineSymbol("nimNoArrayToCstringConversion")
  defineSymbol("nimNewRoof")
  defineSymbol("nimHasRunnableExamples")
  defineSymbol("nimNewDot")
  defineSymbol("nimHasNilChecks")
  defineSymbol("nimSymKind")
  defineSymbol("nimVmEqIdent")
  defineSymbol("nimNoNil")
  defineSymbol("nimNoZeroTerminator")
  defineSymbol("nimNotNil")
  defineSymbol("nimVmExportFixed")
  defineSymbol("nimHasSymOwnerInMacro")
  defineSymbol("nimNewRuntime")
  defineSymbol("nimIncrSeqV3")
  defineSymbol("nimAshr")
  defineSymbol("nimNoNilSeqs")
  defineSymbol("nimNoNilSeqs2")
  defineSymbol("nimHasUserErrors")
  defineSymbol("nimUncheckedArrayTyp")
  defineSymbol("nimHasTypeof")
  defineSymbol("nimErrorProcCanHaveBody")
  defineSymbol("nimHasInstantiationOfInMacro")
  defineSymbol("nimHasHotCodeReloading")
  defineSymbol("nimHasNilSeqs")
  defineSymbol("nimHasSignatureHashInMacro")
  defineSymbol("nimHasDefault")
  defineSymbol("nimMacrosSizealignof")
  defineSymbol("nimNoZeroExtendMagic")
  defineSymbol("nimMacrosGetNodeId")
  for f in low(Feature)..high(Feature):
    defineSymbol("nimHas" & $f)

  for s in WarningsToStr:
    defineSymbol("nimHasWarning" & s)
  for s in HintsToStr:
    defineSymbol("nimHasHint" & s)

  defineSymbol("nimFixedOwned")
  defineSymbol("nimHasStyleChecks")
  defineSymbol("nimToOpenArrayCString")
  defineSymbol("nimHasUsed")
  defineSymbol("nimFixedForwardGeneric")
