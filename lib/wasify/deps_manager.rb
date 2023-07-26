# frozen_string_literal: true

class Wasify
  class DepsManager
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
        if File.exist?(spec_path_str)
          spec_paths.append(spec_path_str)
        else
          puts "#{spec_path_str} doenst exists. Specify gem path or write skip to skip specfile."
          path = $stdin.gets.chomp
          until File.exist?(path) || (path == 'skip')
            puts "#{path} doenst exists. Specify gem path or write skip to skip specfile."
            path = $stdin.gets.chomp
          end
          spec_paths.append(path) unless path == 'skip'
        end
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

    def self.add_entrypoint(entrypoint)
      raise 'Invalid entrypoint! Entrypoint must be a Ruby script' unless entrypoint.include?('.rb')
      raise 'Entrypoint does not exsist! All scripts must be in the src folder.' unless File.exist?("src/#{entrypoint}")

      entrypoint = entrypoint.delete_suffix('.rb')
      <<-HTML
        require "bundler/setup"
        require_relative "/src/#{entrypoint}"
      HTML
    end
  end
end
