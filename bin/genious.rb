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

  # TODO:  There has got to be a more efficient way to do this
  # than searching the class constant list every single time;
  # I'm wondering if I can somehow build a module-level singleton pattern
  # that calculates it once a la "if nil then build map else return from map"
  def Charmap.letter(num)
    Charmap.constants.each { |con|
      if Charmap.const_get(con) == num then return con.to_s end
    }
    raise ArgumentError
  end
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
  bytes = Array.new
  bytes[0] = 7 & value
  bytes[0] |= 8 & (value >> 4)

  bytes[1] = 8 & (address >> 4)
  bytes[1] |= 7 & (value >> 4)

  bytes[2] = 7 & (address >> 4)
  bytes[2] |= 8

  bytes[3] = 7 & (address >> 12)
  bytes[3] |= 8 & address

  bytes[4] = 7 & address
  bytes[4] |= 8 & (address >> 8)

  if compare == nil then
    bytes[5] = 7 & (address >> 8)
    bytes[5] |= 8 & value
  else
    bytes[5] = 7 & (address >> 8)
    bytes[5] |= 8 & compare

    bytes[6] = 7 & compare
    bytes[6] |= 8 & (compare >> 4)

    bytes[7] = 7 & (compare >> 4)
    bytes[7] |= 8 & value
  end

  return bytes.map { |by| Charmap.letter(by) }.join
end

def encode_decode_debug_test(code)
  addr, value, compare = decode(code)
  puts "addr: #{addr.to_s(16)}, value: #{value.to_s(16)}, compare: #{if compare == nil then 'nil' else compare.to_s(16) end}"
  puts encode(addr, value, compare)
end

encode_decode_debug_test("GOSSIP")
encode_decode_debug_test("AAEAULPA")
