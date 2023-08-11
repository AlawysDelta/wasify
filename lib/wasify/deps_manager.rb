# frozen_string_literal: true

require "fileutils"

class Wasify
  # methods finding and copying dependecies
  class DepsManager
    def self.get_specs(deps)
      # Bundler internals are annoying to look through. And mostly undocumented.
      # It's amazing what you can find via "bundle exec irb" and then "Bundler.load".
      bundler_specs = Bundler.load.requested_specs.to_a

      # By default, Bundler only "installs" git: gems and path: gems partway.
      # The specification remains dynamic. So if you require "lib/scarpe/version"
      # in the gemspec, it breaks when vendored, because the specification is
      # separated from the gem source (like lib/scarpe/version.rb). When
      # a gem is built and installed, the gemspec is "baked" to a static version,
      # either Ruby or YAML. But git: and path: gems don't do that. So we
      # need to bake them ourselves using spec.to_ruby.
      # (Thanks to Benedikt Deicke, who pointed out to_ruby.)

      spec_contents = {}
      bundler_specs.each do |spec|
        next if ["bundler", "wasify"].include?(spec.name)

        spec_contents["#{spec.full_name}.gemspec"] = spec.to_ruby
      end
      spec_contents
    end

    def self.get_deps
      return @all_gems if @all_gems

      @all_gems = {}

      # We don't want to copy random files (e.g. .git directories, .bundle) in a path: or git: gem dir.
      # But also, Bundler has multiple kinds of specs. Installed baked specs often omit the file list
      # or cut it down to just executables and top-level README-type files. So we have to do things
      # differently for installed and non-installed specs :-(
      specs = Bundler.load.requested_specs.to_a
      specs.each do |spec|
        root_path = File.expand_path spec.full_gem_path # Pretty sure the expand is unneeded

        files = case spec
        when Gem::Specification
          #puts "#{spec.full_name} is a git: or path: gem"
          spec.files
        when Bundler::StubSpecification
          # The specification file is wrong, but there should be only the right files already installed...
          #puts "#{spec.full_name} is locally installed"
          files = :all
        else
          raise "Not implemented! Figure out how to get Bundler data from a #{spec.class}!"
        end

        @all_gems[spec.full_name] = {
          root: root_path,
          files: files,
        }
      end

      @all_gems
    end

    def self.copy_deps
      get_deps.each do |gem_name, dep|
        dest_dir = "./3_2-wasm32-unknown-wasi-full-js/usr/local/lib/ruby/gems/3.2.0/gems/#{gem_name}"
        if dep[:files] == :all
          FileUtils.cp_r dep[:root], dest_dir
        elsif dep[:files].respond_to?(:each)
          dep[:files].each do |file|
            src = "#{dep[:root]}/#{file}"
            dest = "#{dest_dir}/#{file}"
            FileUtils.mkdir_p File.dirname(dest)
            #STDERR.puts "cp: #{src.inspect} #{dest.inspect}"
            FileUtils.cp src, dest
          end
        else
          raise "Unexpected file list object!"
        end
      end
    end

    def self.copy_specs
      deps = get_deps
      specs = get_specs(deps)
      specs.each do |name, contents|
        File.write("./3_2-wasm32-unknown-wasi-full-js/usr/local/lib/ruby/gems/3.2.0/specifications/#{name}", contents)
      end
    end

    def self.add_entrypoint(entrypoint)
      entrypoint = entrypoint[4..-1] if entrypoint.start_with?("src/") && !File.exist?("src/#{entrypoint}")

      raise 'Invalid entrypoint! Entrypoint must be a Ruby script' unless entrypoint.include?('.rb')
      raise 'Entrypoint does not exist! All scripts must be in the src folder.' unless File.exist?("src/#{entrypoint}")

      entrypoint = entrypoint.delete_suffix('.rb')
      <<-HTML
        require "bundler/setup"
        require_relative "/src/#{entrypoint}"
      HTML
    end
  end
end
