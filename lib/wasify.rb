# frozen_string_literal: true

require_relative 'wasify/version'
require 'bundler'
require 'erb'
require_relative 'wasify/cmd_runner'
require_relative 'wasify/deps_manager'

# wrapper for Wasify
class Wasify
  DEFAULT_WASM_VERSION = "2.5.0"
  DEFAULT_RUBY_VERSION = "3.3"

  # Anything before 2.1.0 doesn't have a browser.umd.js in CDN
  #RUBY_WASM_VERSIONS = [ "2.1.0", "2.2.0", "2.3.0", "2.4.0", "2.4.1" ]

  def self.download_filename
    return @ruby_wasm_filename if @ruby_wasm_filename

    wasm_version = ENV["WS_RUBY_WASM_VERSION"] ? ENV["WS_RUBY_WASM_VERSION"] : DEFAULT_WASM_VERSION

    sep = "."
    if wasm_version[0..2] < "2.4"
      # Before 2.4, used an underscore separator.
      sep = "_"
    end

    # Grab the Ruby version (3.2 or 3.3) and parse out the major and minor numbers
    rv = gems_ruby_version
    maj = gems_ruby_version[0]
    min = gems_ruby_version[2]

    @ruby_wasm_filename = "ruby-#{maj}#{sep}#{min}-wasm32-unknown-wasi-full-js-debug"
  end

  def self.dir_filename
    return @ruby_dir_filename if @ruby_dir_filename

    wasm_version = ENV["WS_RUBY_WASM_VERSION"] ? ENV["WS_RUBY_WASM_VERSION"] : DEFAULT_WASM_VERSION
    if wasm_version[0..2] < "2.4"
      @ruby_dir_filename = download_filename
    else
      @ruby_dir_filename = download_filename.delete_prefix("ruby-")
    end
  end

  def self.gems_ruby_version
    return @ruby_version if @ruby_version

    ruby_short_version = ENV["WS_RUBY_VERSION"] ? ENV["WS_RUBY_VERSION"] : DEFAULT_RUBY_VERSION

    if ruby_short_version == "3.3"
      @ruby_version = "3.3.0"
    elsif ruby_short_version == "3.2"
      @ruby_version = "3.2.0"
    else
      raise "Unrecognized ENV WS_RUBY_VERSION value: should be 3.2 or 3.3!"
    end
  end

  # This is the version of ruby/ruby.wasm being used
  def self.wasi_version
    return @wasi_version if @wasi_version

    @wasi_version = ENV["WS_RUBY_WASM_VERSION"] || DEFAULT_WASM_VERSION

    @wasi_version
  end

  # TODO: control the wasi-vfs version in the same way

  def self.prepack
    CMDRunner.download_binary unless File.exist?(self.download_filename + '.tar.gz')
    CMDRunner.unzip_binary unless Dir.exist?(self.dir_filename)
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
    wasm_wasi_version = wasi_version
    template = 'wasify/template.erb'
    html = ERB.new(File.read(File.join(__dir__, template))).result(binding)
    File.rename('index.html', 'index.html.bak') if File.exist?('index.html')
    File.open('index.html', 'w+') do |f|
      f.write html
    end
  end
end
