# Kamisama

Start, monitor, and observe background worker processes, from Ruby.

# Usage

Kamisama start multiple background processes, and restarts them in case they
die.

``` ruby
def worker
  loop do
    puts "Doing some background work"

    sleep 1
  end
end

Kamisama.run(:instances => 10) { worker }
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

