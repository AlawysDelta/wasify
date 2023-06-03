# frozen_string_literal: true

require_relative "wasify/version"
require "depget"

module Wasify
  def self.pack
    deps = Depget.depget
    deps.each do |i|
      status = system("cp -r #{i} ./3_2-wasm32-unknown-wasi-full/usr/local/lib/ruby/gems/3.2.0/gems/")
      puts "Gem at #{i} not copied." unless status
    end
    cmd = "wasi-vfs pack ruby.wasm --mapdir /src::./src --mapdir /usr::./3_2-wasm32-unknown-wasi-full/usr -o packed_ruby.wasm"
    good = system(cmd, exception: true)
    return unless good

    puts "All went well"
  end
end
