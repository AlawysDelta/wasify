# frozen_string_literal: true

class Wasify
  # methods interacting with the command line
  class CMDRunner
    def self.run_or_fail(cmd)
      system(cmd) || raise("Failed with #{$?.exitstatus} running cmd: #{cmd.inspect} in dir #{Dir.pwd.inspect}")
    end

    def self.download_binary
      version = Wasify.wasi_version
      url = "https://github.com/ruby/ruby.wasm/releases/download/#{version}/#{Wasify.download_filename}.tar.gz"
      run_or_fail("curl -LO #{url}")
    end

    def self.unzip_binary
      run_or_fail("tar xfz #{Wasify.download_filename}.tar.gz")
      run_or_fail("chmod -R u+rw #{Wasify.dir_filename}")
    end

    def self.move_binary
      run_or_fail("mv #{Wasify.dir_filename}/usr/local/bin/ruby ruby.wasm")
    end

    def self.copy_gemfile
      run_or_fail('mkdir -p deps && cp -r Gemfile deps/Gemfile && cp -r Gemfile.lock deps/Gemfile.lock')
    end

    def self.fix_lockfile
      run_or_fail('bundle lock --add-platform wasm32-unknown')
    end

    def self.run_vfs
      run_or_fail("wasi-vfs pack ruby.wasm --mapdir /src::./src --mapdir /usr::./#{Wasify.dir_filename}/usr --mapdir /deps::./deps -o packed_ruby.wasm")
    end

    def self.cleanup
      run_or_fail("rm -rf #{Wasify.dir_filename}")
      run_or_fail("rm #{Wasify.download_filename}.tar.gz")
      run_or_fail('rm ruby.wasm')
      run_or_fail('rm -rf deps')
    end
  end
end
