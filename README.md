# Kamisama

Start, monitor, and observe background worker processes, from Ruby.

# Usage

Kamisama start multiple background processes, and restarts them in case they
die.

``` ruby
Kamisama.run(:instances => 10) do |worker_index|
  loop do
    puts "Worker #{worker_index}: Crunching data."

    sleep 1
  end
end
```

Each worker is a forked process.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

