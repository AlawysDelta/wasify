# frozen_string_literal: true

class Wasify
  class CMDRunner
    def self.download_binary
      system('curl -LO https://github.com/ruby/ruby.wasm/releases/latest/download/ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
    end

    def self.unzip_binary
      system('tar xfz ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
    end

    def self.move_binary
      system('mv 3_2-wasm32-unknown-wasi-full-js/usr/local/bin/ruby ruby.wasm')
    end

    def self.copy_gemfile
      system('mkdir -p root && cp -r Gemfile root/Gemfile && cp -r Gemfile.lock root/Gemfile.lock')
    end

    def self.fix_lockfile
      system('bundle lock --add-platform wasm32-unknown')
    end

    def self.run_vfs
      system('wasi-vfs pack ruby.wasm --mapdir /src::./src --mapdir /usr::./3_2-wasm32-unknown-wasi-full-js/usr --mapdir /root::./root -o packed_ruby.wasm')
    end
  end
end
