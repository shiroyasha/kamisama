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

## Signal control

You can control your Kamisama process by sending kill signals to the running
process.

- [TERM](#term-signal) - terminates master process and all workers
- [KIL](#kill-signal)  - terminates master process and all workers
- [TTIN](#ttin-signal) - spawns a new worker
- [TTIN](#ttou-signal) - terminates a running worker

#### TERM signal

If you send a term signal to your Kamisama process, it will immediately
shutdown. Following this, every children will be notified by the kernel that the
master process has dies with the TERM signal.

For example, if you have the following processes:

``` bash
2000 - PID of master process
2001 - PID of first worker
2002 - PID of second worker
2003 - PID of third worker
```

Then when you send a "TERM" signal:

``` bash
kill -TERM 2000
```

The master process `2000` will die immediately, and the workers processes
(2001, 2002, 2003) will receive the `TERM` signal.

#### KILL signal

If you send a kill signal to your Kamisama process, it will immediately
shutdown. Following this, every children will be notified by the kernel that the
master process has dies with the TERM signal.

For example, if you have the following processes:

``` bash
2000 - PID of master process
2001 - PID of first worker
2002 - PID of second worker
2003 - PID of third worker
```

Then when you send a "KILL" signal:

``` bash
kill -9 2000
```

The master process `2000` will die immediately, and the workers processes
(2001, 2002, 2003) will receive the `TERM` signal.

#### TTIN signal

If you send a ttin signal to your Kamisama process, it will spawn a new process.

For example, if you have the following processes:

``` bash
2000 - PID of master process
2001 - PID of first worker
2002 - PID of second worker
2003 - PID of third worker
```

Then when you send a "TTIN" signal:

``` bash
kill -TTIN 2000
```

The master process `2000` will spawn a new worker process.

#### TTOU signal

If you send a ttou signal to your Kamisama process, it will kill the oldest
worker.

For example, if you have the following processes:

``` bash
2000 - PID of master process
2001 - PID of first worker
2002 - PID of second worker
2003 - PID of third worker
```

Then when you send a "TTOU" signal:

``` bash
kill -TTOU 2000
```

The master process `2000` will send a `TERM` signal to the process `2001`.

*NOTE*: This will only work if you have more than one running processes.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
