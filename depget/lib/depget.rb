# frozen_string_literal: true

require_relative "depget/version"
require "bundler"

module Depget
  def Depget.depGet()
    deps = Bundler.load.specs.map(&:full_gem_path)
    modded_string_deps = []
    deps.each do |i|
      modded_string_deps.append(i + "::./3_2-wasm32-unknown-wasi-full/#{i.split("/", -1)[-1]}")
    end
    return modded_string_deps
  end
end
