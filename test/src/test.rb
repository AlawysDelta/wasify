# frozen_string_literal: true

require 'bundler/setup'
require 'sha3-pure-ruby'

str = 'Hello WasmTime!'

puts str
puts Digest::SHA3.hexdigest(str)
