# frozen_string_literal: true

require_relative 'wasify/version'
require 'bundler'
require 'erb'

module Wasify
  def self.get_specs(deps)
    spec_paths = []
    deps.each do |i|
      spec_path_str = ''
      spec_path = i.split('/', -1)
      spec_path.each_with_index do |s, index|
        spec_path_str += "/#{s}" if index < spec_path.length - 2
      end
      spec_path_str += "/specifications/#{i.split('/', -1)[-1]}.gemspec"
      spec_path_str[0] = ''
      spec_paths.append(spec_path_str)
    end
    spec_paths
  end

  def self.get_deps
    deps = Bundler.load.specs.map(&:full_gem_path)
    modded_string_deps = []
    deps.each do |i|
      modded_string_deps.append(i)
    end
    modded_string_deps
  end

  def self.copy_deps
    deps = get_deps
    deps.each do |i|
      status = system("cp -r #{i} ./3_2-wasm32-unknown-wasi-full-js/usr/local/lib/ruby/gems/3.2.0/gems")
      puts "Gem at #{i} not copied." unless status
    end
  end

  def self.copy_specs
    deps = get_deps
    specs = get_specs(deps)
    specs.each do |s|
      status = system("cp #{s} ./3_2-wasm32-unknown-wasi-full-js/usr/local/lib/ruby/gems/3.2.0/specifications")
      puts "Specification at #{s} not copied." unless status
    end
  end

  def self.download_binary
    system('curl -LO https://github.com/ruby/ruby.wasm/releases/latest/download/ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
    system('tar xfz ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
    system('mv 3_2-wasm32-unknown-wasi-full-js/usr/local/bin/ruby ruby.wasm')
  end

  def self.copy_gemfile
    system('mkdir -p root && cp -r Gemfile root/Gemfile && cp -r Gemfile.lock root/Gemfile.lock')
  end

  def self.fix_lockfile
    system('bundle lock --add-platform wasm32-unknown')
  end

  def self.pack
    download_binary unless File.exist?('ruby-3_2-wasm32-unknown-wasi-full-js.tar.gz')
    fix_lockfile
    copy_gemfile
    File.delete('packed_ruby.wasm') if File.exist?('packed_ruby.wasm')
    copy_deps
    copy_specs
    cmd = 'wasi-vfs pack ruby.wasm --mapdir /src::./src --mapdir /usr::./3_2-wasm32-unknown-wasi-full-js/usr --mapdir /root::./root -o packed_ruby.wasm'
    system(cmd, exception: true)
  end

  def self.generate_html(scripts)
    scripts_txt = []
    scripts.each do |script|
      unless script.include? '.rb'
        puts 'Invalid args! Not generating HTML file'
        return
      end
      unless File.exist?("src/#{script}")
        puts "#{script} not found! Not generating HTML file"
        return
      end
      scripts_txt.push(File.read("src/#{script}"))
    end

    template = %(
      <html>
      <script src="https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@latest/dist/browser.umd.js"></script>
      <script>
        const { DefaultRubyVM } = window["ruby-wasm-wasi"];
        const main = async () => {
          const response = await fetch(
            "http://localhost:8080/packed_ruby.wasm");
          const buffer = await response.arrayBuffer();
          const module = await WebAssembly.compile(buffer);
          const { vm } = await DefaultRubyVM(module);

          vm.printVersion();
          vm.eval(`
          <%  scripts_txt.each do |script| %>
                 <%= script %>
          <% end %>`);
        };

      main();
      </script>

      <body></body>

      </html>)
    html = ERB.new(template).result(binding)
    File.rename('index.html', 'index.html.bak') if File.exist?('index.html')
    File.open('index.html', 'w+') do |f|
      f.write html
    end
  end
end
