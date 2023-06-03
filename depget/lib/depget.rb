# frozen_string_literal: true

require_relative "depget/version"
require "bundler"

module Depget
  def self.depget
    deps = Bundler.load.specs.map(&:full_gem_path)
    modded_string_deps = []
    deps.each do |i|
      continue if i.include?("wasify") || i.include?("depget")
      modded_string_deps.append(i)
    end
    modded_string_deps
  end
end
