# frozen_string_literal: true

class Wasify
  # methods finding and copying dependecies
  class DepsManager
    def self.get_specs(deps)
      bundler_specs = Bundler.load.specs
      lf = bundler_specs.map(&:loaded_from)
      lf.select! { |item| !item.include?("/bundler-") && !item.include?("/wasify-") }

      spec_paths = []
      lf.each do |spec_path_str|
        if File.exist?(spec_path_str)
          spec_paths.append(spec_path_str)
        else
          loop do
            puts "#{spec_path_str} doesn't exist. Specify gemspec path or write 'skip' to skip specfile."
            path = $stdin.gets.chomp
            break if File.exist?(path) || (path == 'skip')
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
