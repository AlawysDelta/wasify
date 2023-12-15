# frozen_string_literal: true

require_relative 'wasify/version'
require 'bundler'
require 'erb'
require_relative 'wasify/cmd_runner'
require_relative 'wasify/deps_manager'
# wrapper for Wasify
class Wasify
  def self.prepack
    CMDRunner.download_binary unless File.exist?('ruby-3.2-wasm32-unknown-wasi-full-js.tar.gz')
    CMDRunner.unzip_binary unless Dir.exist?('ruby-3.2-wasm32-unknown-wasi-full-js')
    CMDRunner.move_binary unless File.exist?('ruby.wasm')
    CMDRunner.fix_lockfile
    CMDRunner.copy_gemfile
    File.delete('packed_ruby.wasm') if File.exist?('packed_ruby.wasm')
    DepsManager.copy_deps
    DepsManager.copy_specs
  end

  def self.build_wasm
    CMDRunner.run_vfs
  end

  def self.cleanup
    CMDRunner.cleanup
  end

  def self.pack
    prepack
    build_wasm
    cleanup
  end

  def self.generate_html(entrypoint)
    entrypoint_txt = DepsManager.add_entrypoint(entrypoint)
    template = 'wasify/template.erb'
    html = ERB.new(File.read(File.join(__dir__, template))).result(binding)
    File.rename('index.html', 'index.html.bak') if File.exist?('index.html')
    File.open('index.html', 'w+') do |f|
      f.write html
    end
  end
end
