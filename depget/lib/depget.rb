# frozen_string_literal: true

require_relative "depget/version"
require "bundler"

module Depget
  def self.getSpecs(deps)
    spec_paths = []
    deps.each do |i|
      spec_path_str = ""
      spec_path = i.split("/", -1)
      spec_path.each_with_index do |s, index|
        spec_path_str += "/#{s}" if index < spec_path.length - 2
      end
      spec_path_str += "/specifications/#{i.split("/", -1)[-1]}.gemspec"
      spec_path_str[0] = ""
      spec_paths.append(spec_path_str)
    end
    spec_paths
  end

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
