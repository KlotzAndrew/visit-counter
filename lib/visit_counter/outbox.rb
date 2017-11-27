# frozen_string_literal: true

module VisitCounter
  module Outbox
    module_function

    GIL_SLEEP = 1

    @queue  = Queue.new
    @thread = nil

    def start!
      @thread = Thread.new do
        dequeue_all
      end
    end

    def kill!
      @thread.kill
    end

    def enqueue(url)
      @queue.push(url)
    end

    def dequeue_all
      loop do
        if @queue.empty?
          sleep GIL_SLEEP
        else
          url = @queue.pop
          Visit.new(url: url).save
        end
      end
    end
  end
end
