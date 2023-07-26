# Wasify

Wasify is a CLI made to make running Ruby on your browser thanks to WASM, including gems without native extensions, easy! Wasify packs a new WASM binary based on the ones released by [ruby.wasm](https://github.com/ruby/ruby.wasm) thanks to [wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs), to include your code and any dependency without native extensions in a single binary ready to run on your browser with the generated HTML code.
## Installation

Wasify needs [wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs#installation) installed in your system in order to work, so be sure to get it before using it!

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

After installing the gem and the required dependencies, your project needs to get ready to be wasified.
Move all your Ruby script files into a *src* folder, and then call Wasify from the command line:

```bash
wasify entrypoint.rb
```
where *entrypoint.rb* is the entrypoint of your Ruby project.

Wasify will generate an *index.html* file and a *packed_ruby.wasm* file. To run on your browser locally, host them on a local HTTP server (check paths and ports in the index.html file if you need to change names or if you use a different port than 8080 on your local server).
## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/wasify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/AlawysDelta/wasify/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wasify project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/AlawysDelta/wasify/blob/master/CODE_OF_CONDUCT.md).
