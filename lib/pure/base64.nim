#
#
#            Nim's Runtime Library
#        (c) Copyright 2010 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements a base64 encoder and decoder.
##
## Unstable API.
##
## Base64 is an encoding and decoding technique used to convert binary
## data to an ASCII string format.
## Each Base64 digit represents exactly 6 bits of data. Three 8-bit
## bytes (i.e., a total of 24 bits) can therefore be represented by
## four 6-bit Base64 digits.
##
## Basic usage
## ===========
##
## Encoding data
## -------------
##
## .. code-block::nim
##    import base64
##    let encoded = encode("Hello World")
##    assert encoded == "SGVsbG8gV29ybGQ="
##
## Apart from strings you can also encode lists of integers or characters:
##
## .. code-block::nim
##    import base64
##    let encodedInts = encode([1,2,3])
##    assert encodedInts == "AQID"
##    let encodedChars = encode(['h','e','y'])
##    assert encodedChars == "aGV5"
##
##
## Decoding data
## -------------
##
## .. code-block::nim
##    import base64
##    let decoded = decode("SGVsbG8gV29ybGQ=")
##    assert decoded == "Hello World"
##
##
## See also
## ========
##
## * `hashes module<hashes.html>`_ for efficient computations of hash values for diverse Nim types
## * `md5 module<md5.html>`_ implements the MD5 checksum algorithm
## * `sha1 module<sha1.html>`_ implements a sha1 encoder and decoder

const
  cb64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  invalidChar = 255

template encodeInternal(s: typed): untyped =
  ## encodes `s` into base64 representation.
  proc encodeSize(size: int): int =
    return (size * 4 div 3) + 6

  result.setLen(encodeSize(s.len))

  var
    inputIndex = 0
    outputIndex = 0
    inputEnds = s.len - s.len mod 3
    n: uint32
    b: uint32

  template inputByte(exp: untyped) =
    b = uint32(s[inputIndex])
    n = exp
    inc inputIndex

  template outputChar(x: untyped) =
    result[outputIndex] = cb64[x and 63]
    inc outputIndex

  template outputChar(c: char) =
    result[outputIndex] = c
    inc outputIndex

  while inputIndex != inputEnds:
    inputByte(b shl 16)
    inputByte(n or b shl 8)
    inputByte(n or b shl 0)
    outputChar(n shr 18)
    outputChar(n shr 12)
    outputChar(n shr 6)
    outputChar(n shr 0)

  var padding = s.len mod 3
  if padding == 1:
    inputByte(b shl 16)
    outputChar(n shr 18)
    outputChar(n shr 12)
    outputChar('=')
    outputChar('=')

  elif padding == 2:
    inputByte(b shl 16)
    inputByte(n or b shl 8)
    outputChar(n shr 18)
    outputChar(n shr 12)
    outputChar(n shr 6)
    outputChar('=')

  result.setLen(outputIndex)

proc encode*[T: SomeInteger|char](s: openarray[T]): string =
  ## Encodes `s` into base64 representation.
  ##
  ## This procedure encodes an openarray (array or sequence) of either integers
  ## or characters.
  ##
  ## **See also:**
  ## * `encode proc<#encode,string>`_ for encoding a string
  ## * `decode proc<#decode,string>`_ for decoding a string
  runnableExamples:
    assert encode(['n', 'i', 'm']) == "bmlt"
    assert encode(@['n', 'i', 'm']) == "bmlt"
    assert encode([1, 2, 3, 4, 5]) == "AQIDBAU="
  encodeInternal(s)

proc encode*(s: string): string =
  ## Encodes ``s`` into base64 representation.
  ##
  ## This procedure encodes a string.
  ##
  ## **See also:**
  ## * `encode proc<#encode,openArray[T]>`_ for encoding an openarray
  ## * `decode proc<#decode,string>`_ for decoding a string
  runnableExamples:
    assert encode("Hello World") == "SGVsbG8gV29ybGQ="
  encodeInternal(s)

proc encodeMIME*(s: string, lineLen = 75, newLine = "\r\n"): string =
  ## Encodes ``s`` into base64 representation as lines.
  ## Used in email MIME forma, use ``lineLen`` and ``newline``.
  ##
  ## This procedure encodes a string according to MIME spec.
  ##
  ## **See also:**
  ## * `encode proc<#encode,string>`_ for encoding a string
  ## * `decode proc<#decode,string>`_ for decoding a string
  runnableExamples:
    assert encodeMIME("Hello World", 4, "\n") == "SGVs\nbG8g\nV29y\nbGQ="
  for i, c in encode(s):
    if i != 0 and (i mod lineLen == 0):
      result.add(newLine)
    result.add(c)

proc initDecodeTable*(): array[256, char] =
  # computes a decode table at compile time
  for i in 0 ..< 256:
    let ch = char(i)
    var code = invalidChar
    if ch >= 'A' and ch <= 'Z': code = i - 0x00000041
    if ch >= 'a' and ch <= 'z': code = i - 0x00000047
    if ch >= '0' and ch <= '9': code = i + 0x00000004
    if ch == '+' or ch == '-': code = 0x0000003E
    if ch == '/' or ch == '_': code = 0x0000003F
    result[i] = char(code)

const
  decodeTable = initDecodeTable()

proc decode*(s: string): string =
  ## Decodes string ``s`` in base64 representation back into its original form.
  ## The initial whitespace is skipped.
  ##
  ## **See also:**
  ## * `encode proc<#encode,openArray[T],int,string>`_ for encoding an openarray
  ## * `encode proc<#encode,string,int,string>`_ for encoding a string
  runnableExamples:
    assert decode("SGVsbG8gV29ybGQ=") == "Hello World"
    assert decode("  SGVsbG8gV29ybGQ=") == "Hello World"
  if s.len == 0: return

  proc decodeSize(size: int): int =
    return (size * 3 div 4) + 6

  template inputChar(x: untyped) =
    let x = int decode_table[ord(s[inputIndex])]
    inc inputIndex
    if x == invalidChar:
      raise newException(ValueError,
        "Invalid base64 format character " & repr(s[inputIndex]) &
        " at location " & $inputIndex & ".")

  template outputChar(x: untyped) =
    result[outputIndex] = char(x and 255)
    inc outputIndex

  # pre allocate output string once
  result.setLen(decodeSize(s.len))
  var
    inputIndex = 0
    outputIndex = 0
    inputLen = s.len
    inputEnds = 0
  # strip trailing characters
  while s[inputLen - 1] in {'\n', '\r', ' ', '='}:
    dec inputLen
  # hot loop: read 4 characters at at time
  inputEnds = inputLen - 4
  while inputIndex <= inputEnds:
    while s[inputIndex] in {'\n', '\r', ' '}:
      inc inputIndex
    inputChar(a)
    inputChar(b)
    inputChar(c)
    inputChar(d)
    outputChar(a shl 2 or b shr 4)
    outputChar(b shl 4 or c shr 2)
    outputChar(c shl 6 or d shr 0)
  # do the last 2 or 3 characters
  var leftLen = abs((inputIndex - inputLen) mod 4)
  if leftLen == 2:
    inputChar(a)
    inputChar(b)
    outputChar(a shl 2 or b shr 4)
  elif leftLen == 3:
    inputChar(a)
    inputChar(b)
    inputChar(c)
    outputChar(a shl 2 or b shr 4)
    outputChar(b shl 4 or c shr 2)
  result.setLen(outputIndex)



