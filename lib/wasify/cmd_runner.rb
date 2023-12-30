# frozen_string_literal: true

class Wasify
  # methods interacting with the command line
  class CMDRunner
    def self.download_binary
      version = ENV["WASIFY_VERSION"] || "2.3.0"
      system("curl -LO https://github.com/ruby/ruby.wasm/releases/download/#{version}/ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz")
    end

    def self.unzip_binary
      system('tar xfz ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
      system('chmod -R u+rw 3_2-wasm32-unknown-wasi-full-js')
    end

    def self.move_binary
      system('mv 3_2-wasm32-unknown-wasi-full-js/usr/local/bin/ruby ruby.wasm')
    end

    def self.copy_gemfile
      system('mkdir -p deps && cp -r Gemfile deps/Gemfile && cp -r Gemfile.lock deps/Gemfile.lock')
    end

    def self.fix_lockfile
      system('bundle lock --add-platform wasm32-unknown')
    end

    def self.run_vfs
      system('wasi-vfs pack ruby.wasm --mapdir /src::./src --mapdir /usr::./3_2-wasm32-unknown-wasi-full-js/usr --mapdir /deps::./deps -o packed_ruby.wasm')
    end

    def self.cleanup
      system('rm -rf 3_2-wasm32-unknown-wasi-full-js')
      system('rm ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
      system('rm ruby.wasm')
      system('rm -rf deps')
    end
  end
end
