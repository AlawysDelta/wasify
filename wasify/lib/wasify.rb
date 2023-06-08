# frozen_string_literal: true

require_relative "wasify/version"
require "depget"

module Wasify
  def self.copy_deps
    deps = Depget.depget
    deps.each do |i|
      status = system("cp -r #{i} ./3_2-wasm32-unknown-wasi-full/usr/local/lib/ruby/gems/3.2.0/gems")
      puts "Gem at #{i} not copied." unless status
    end
  end

  def self.copy_specs
    deps = Depget.depget
    specs = Depget.getSpecs(deps)

    specs.each do |s|
      status = system("cp #{s} ./3_2-wasm32-unknown-wasi-full/usr/local/lib/ruby/gems/3.2.0/specifications")
      puts "Specification at #{s} not copied." unless status
    end
  end

  def self.download_binary
    system("curl -LO https://github.com/ruby/ruby.wasm/releases/latest/download/ruby-3_2-wasm32-unknown-wasi-full.tar.gz")
    system("tar xfz ruby-3_2-wasm32-unknown-wasi-full.tar.gz")
    system("mv 3_2-wasm32-unknown-wasi-full/usr/local/bin/ruby ruby.wasm")
  end

  def self.copy_gemfile
    system("mkdir -p root && cp -r Gemfile root/Gemfile && cp -r Gemfile.lock root/Gemfile.lock")
  end

  def self.pack
    download_binary unless File.exist?("ruby-3_2-wasm32-unknown-wasi-full.tar.gz")
    copy_gemfile
    File.delete("packed_ruby.wasm") if File.exist?("packed_ruby.wasm")
    copy_deps
    copy_specs
    cmd = "wasi-vfs pack ruby.wasm --mapdir /src::./src --mapdir /usr::./3_2-wasm32-unknown-wasi-full/usr --mapdir /root::./root -o packed_ruby.wasm"
    system(cmd, exception: true)
  end
end
