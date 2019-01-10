#!/usr/bin/env ruby
# genie.rb: encode/decode game genie codes
# nes:  handy documentation at http://tuxnes.sourceforge.net/gamegenie.html on the code format 

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

def valid_code?(code)
  code_manip = code.strip.upcase
  unless code_manip.length == 6 || code_manip.length == 8 then return false end
  code_manip.split('').each { |ch|
    unless Charmap.const_defined?("#{ch}") then return false end
  }
  return true
end

def test_valid_code?()
  unless valid_code?("AAEAULPA") then return false end
  if valid_code?("BABABA") then return false end
end

def decode(gg_code)
  unless valid_code?(gg_code) then raise ArgumentError end
  code = gg_code.strip.upcase
  n ||= []
  code.split('').each { |ch|
    n.push(Charmap.const_get(ch))
  }
  address = 0x8000 + (((n[3] & 7) << 12) | ((n[5] & 7) << 8) | 
                     ((n[4] & 8) << 8)  | ((n[2] & 7) << 4) |
                     ((n[1] & 8) << 4)  | (n[4] & 7) |
                     (n[3] & 8))
  if code.length == 6 then
    value   = ((n[1] & 7) << 4) | ((n[0] & 8) << 4) |
               (n[0] & 7) | (n[5] & 8)
    compare = nil
  else
    value   = ((n[1] & 7) << 4) | ((n[0] & 8) << 4) |
               (n[0] & 7)       | (n[7] & 8)
    compare = ((n[7] & 7) << 4) | ((n[6] & 8) << 4) |
               (n[6] & 7)       | (n[5] & 8)
  end
  return address, value, compare
end

def encode(address, value, compare)
  raise NoMethodError
end

#unless test_valid_code? then return -1 end
decode("GOSSIP").each { |st|
  unless st == nil then puts st.to_s(16) end
}
