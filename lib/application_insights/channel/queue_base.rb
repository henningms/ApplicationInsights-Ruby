require 'thread'

module ApplicationInsights
  module Channel
    # The base class for all types of queues for use in conjunction with an implementation of {SenderBase}. The queue
    # will notify the sender that it needs to pick up items when it reaches {#max_queue_length}, or when the consumer
    # calls {#flush}.
    class QueueBase
      # Initializes a new instance of the class.
      # @param [SenderBase] sender the sender object that will be used in conjunction with this queue.
      def initialize(sender)
        @queue = Queue.new
        @max_queue_length = 500
        @sender = sender
        @sender.queue = self if sender
      end

      # The maximum number of items that will be held by the queue before the queue will call the {#flush} method.
      # @return [Fixnum] the maximum queue size. (defaults to: 500)
      attr_accessor :max_queue_length

      # The sender that is associated with this queue that this queue will use to send data to the service.
      # @return [SenderBase] the sender object.
      attr_reader :sender

      # Adds the passed in item object to the queue and calls {#flush} if the size of the queue is larger
      # than {#max_queue_length}. This method does nothing if the passed in item is nil.
      # @param [Contracts::Envelope] item the telemetry envelope object to send to the service.
      def push(item)
        unless item
          return
        end

        @queue.push(item)
        if @queue.length >= @max_queue_length
          flush
        end
      end

      # Pops a single item from the queue and returns it. If the queue is empty, this method will return nil.
      # @return [Contracts::Envelope] a telemetry envelope object or nil if the queue is empty.
      def pop
        begin
          return @queue.pop(TRUE)
        rescue ThreadError => _
          return nil
        end
      end

      # Flushes the current queue by notifying the {#sender}. This method needs to be overridden by a concrete
      # implementations of the queue class.
      def flush
      end
    end
  end
end