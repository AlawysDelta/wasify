# frozen_string_literal: true

require "sha3-pure-ruby"
require "depget"

sha3 = Digest::SHA3.hexdigest("Hello SHA3!")
puts sha3

puts Depget::depGet()