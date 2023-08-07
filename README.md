# Wasify

Wasify is a CLI made to make running Ruby on your browser thanks to WASM, including gems without native extensions, easy! Wasify packs a new WASM binary based on those released by [ruby.wasm](https://github.com/ruby/ruby.wasm), leveraging [wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs) to include your code and any dependencies without native extensions. This creates a single binary ready to run in your browser with the generated HTML code.
## Installation

In order for Wasify to work, you need to install the same version of [wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs#installation) used by the original [ruby.wasm](https://github.com/ruby/ruby.wasm) binary, so be sure to get it before using it! At the time of writing this readme, you need to install **wasi-vfs v0.1.1**

Install the gem and add to the application's Gemfile by executing:

    $ bundle add wasify

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install wasify

## Usage

After installing the gem and the required dependencies, your project needs to get ready to be wasified.
Your project's folder should include the following:
    - The project's Gemfile
    - a *src* folder, where all the Ruby code you need to run will be. Wasify works with multi-file projects, so you can add as many files as you want.

When your project folder is ready, open it with your favourite terminal and call

    $ wasify entrypoint.rb

where *entrypoint.rb* is the entrypoint of your Ruby project. If you're working with a single-file project, *entrypoint.rb* will be that single file, if you're working with a multi-file project it will be the Ruby script to be run to make your project work.

Wasify will generate two files: an 'index.html' file and a 'packed_ruby.wasm' file. The HTML file is needed to run the code on browser, while the packed_ruby.wasm is the new Ruby WASM binary that includes the dependencies specified in the Gemfile. To run on your browser locally, host them on a local HTTP server (check paths and ports in the index.html file if you need to change names or if you use a different port than 8080 on your local server).
## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AlawysDelta/wasify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/AlawysDelta/wasify/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wasify project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/AlawysDelta/wasify/blob/master/CODE_OF_CONDUCT.md).
