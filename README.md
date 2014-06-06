# Sshkit::Custom::Dsl

Exchanges original sshkit dsl against a custom dsl. This DSL does not change the scope of the blocks.
Furthor more it uses `Rake::Threadpool`, to handle parallel requests. Keep in mind `Runner::Parallel` 
 and `Runner::Group` execute all blocks in *parallel threads*, so do it thread save.

## Installation

Add this line to your application's Gemfile:

    gem 'sshkit-custom-dsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sshkit-custom-dsl

## Usage

```ruby

require 'sshkit/custom/dsl'

extend SSHKit::Custom::DSL

SSHKit.configure do |sshkit|
  sshkit.format = :pretty
  sshkit.output_verbosity = :debug
  sshkit.default_env = {}
  sshkit.backend = SSHKit::Backend::Netssh
  sshkit.backend.configure do |backend|
    backend.pty =false
    backend.connection_timeout = 5
    backend.ssh_options = {user: 'deploy'}
  end
end

on %w{localhost 127.0.0.1}, in: :sequence, wait: 0 do
  within "/tmp" do
    with rails_env: :production do
      execute "echo", "12345"
    end
  end
end

on %w{localhost 127.0.0.1} do
  within "/tmp" do
    with rails_env: :production do
      execute "env", "|sort"
    end
  end
end

on %w{localhost 127.0.0.1} do
  within "/tmp" do
    with rails_env: :production do
      execute do |backend|
        puts backend.inspect
        ["env", "|sort"]
      end
    end
  end
end

```

It should work like the original one, I hope.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sshkit-custom-dsl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
