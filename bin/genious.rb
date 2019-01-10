#!/usr/bin/env ruby
# genie.rb: encode/decode game genie codes
# nes:  handy documentation at http://tuxnes.sourceforge.net/gamegenie.html on the format of game genie codes.

module Charmap
  A = 0x0
  P = 0x1
  Z = 0x2
  L = 0x3
  G = 0x4
  I = 0x5
  T = 0x6
  Y = 0x7
  E = 0x8
  O = 0x9
  X = 0xA
  U = 0xB
  K = 0xC
  S = 0xD
  V = 0xE
  N = 0xF
end

def validate_code(code)
  code_manip = code.strip.upcase
  unless code_manip.length == 6 || code_manip.length == 8 then return false end
  code_manip.split('').each { |ch|
    unless Charmap.const_defined?("#{ch}") then return false end
  }
  return true
end

def test_validate_code()
  unless validate_code "AAEAULPA" then return false end
  if validate_code "BABABA" then return false end
end

def decode(gg_code)
  raise NoMethodError
end

def encode(address, value)
  raise NoMethodError
end

if test_validate_code then return 0 else return -1 end
