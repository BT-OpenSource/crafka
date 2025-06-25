require "spec"
require "json"
require "../src/*"

def timeout(time : Time::Span, &blk)
  done = Channel(Nil).new

  spawn do
    blk.call
    done.send(nil)
  end

  select
  when done.receive
    return
  when timeout(time)
    raise "Timeout"
  end
end
