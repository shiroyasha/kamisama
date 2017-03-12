# Kamisama

[![Build Status](https://semaphoreci.com/api/v1/shiroyasha/kamisama/branches/master/badge.svg)](https://semaphoreci.com/shiroyasha/kamisama)

Start, monitor, and observe background worker processes, from Ruby.

Based on [Unicorn](), [God](), and [Sidekiq]().

# Usage

Kamisama is useful for starting multiple background workers. For example, let's
say that you have a background worker that crunches some data with periodic
intervals.

``` ruby
def worker
  loop do
    puts "Crunching data..."

    sleep 60
  end
end
```

A usual way to run this task is to wrap it in a Rake task, and an upstart script
to keep it running forever. This is pretty well until you have one process that
you want to execute. However, if you want to run multiple processes, you need to
introduce and manage multiple upstart configurations. One upstart script that
acts like the master who manages your workers, and upstart scripts that describe
your workers.

This setup is cumbersome, hard to test, and managing different configurations
for different environments (production, staging, development) can be outright
frustrating.

Kamisama is here to help, by abstracting away the issue of running and monitor
multiple background workers.

Let's run 17 instances of the above worker with Kamisama:

``` ruby
def worker(worker_index)
  loop do
    puts "WORKER #{worker_index}: Crunching data..."

    sleep 60
  end
end

Kamisama.run(:instances => 17) { |index| worker(index) }
```

That's all! The above will start(fork) 17 processes on your machine, and restart
them in case of failure.

Keep in mind that you will still need to wrap Kamisama itself in a rake task
and an Upstart script.

### Respawn limits

Respawning workers is desirable in most cases, but we would still like to avoid
rapid restarts of your workers in a short amount of time. Such rapid restarts
can harm your system, and usually indicate that a serious issue is killing
your workers.

If the job is respawned more than `respawn_limit` times in `respawn_interval`
seconds, Kamisama will considered this to be a deeper problem and will die.

``` ruby
def worker(worker_index)
  loop do
    puts "WORKER #{worker_index}: Crunching data..."

    sleep 60
  end
end

config = {
  :instances => 17,
  :respawn_limit => 10,
  :respawn_interval => 60
}

Kamisama.run(config) { |index| worker(index) }
```

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
