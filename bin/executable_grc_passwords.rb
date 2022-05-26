#!/usr/bin/env ruby
require 'open-uri'
require 'cgi'

def get_grc_page
  uri = 'https://www.grc.com/passwords.htm'
  #uri = '/tmp/tst'  # For testing:  curl https://www.grc.com/passwords.htm > /tmp/tst
  page = ''
  open(uri) { |www| page = www.read }
  CGI.unescapeHTML(page)
end

def extract_data page=nil
  page = get_grc_page unless page

  # Init the structure, make sure we have blank arrays
  parts = {hex:[], ascii:[], alpha:[], size:[]}

  # 64 random hexadecimal characters
  m = page.scan /([0-9a-f]{64})/i
  add_type_if_match :hex, parts, m

  # 63 random printable ASCII characters
  m = page.scan />([0-9a-z\-\-`!@#$\%^&*_+={}\[\];':"\\|,\.\/\?<>]{63,})<\/font>/i
  add_type_if_match :ascii, parts, m

  # 63 random alpha-numeric characters
  m = page.scan />([0-9a-z]{63})<\/font>/i
  add_type_if_match :alpha, parts, m

  # Remove dups from ASCII (the other sections match this)
  parts[:ascii].reject! { |v| parts[:hex].include?(v) || parts[:alpha].include?(v)}

  # Add sizing header
  parts[:size][0] = "         1         2         3         4         5         6         7"
  parts[:size][1] = "1234567890123456789012345678901234567890123456789012345678901234567890"

  # Return
  parts
end

def add_type_if_match key, parts, match
  return unless match
  parts[key] = match.to_a.flatten
  nil
end

def print_parts parts=nil, print_size_header=true
  parts = extract_data unless parts
  puts %Q{
==============================================================================
GRC's Ultra High Security Password Generator
==============================================================================

}

  if print_size_header
    print_part "LNGTH", parts[:size]
  end

  print_part   "  HEX", parts[:hex]
  print_part   "ALPHA", parts[:alpha]

  # ASCII is broke and I don't care ATM
  #print_part "ASCII", parts[:ascii]
end

def print_part name, vals
  #prefix = ' ' * (name.size / 2).floor
  prefix = ' ' * name.size
  size = "123456789-123456789-123456789-123456789-123456789-123456789-123456789-" unless name=='LNGTH'
  puts "  #{name} #{size}"
  vals.each { |val| puts "  #{prefix} #{val}"}
  puts ''
end

if __FILE__ == $0
  puts "Getting passwords from https://www.grc.com/passwords.htm"
  print_parts
end