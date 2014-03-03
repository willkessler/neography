module Deja
  class Batch
    class << self
      def commit
        begin
          Deja.batch = []
          yield if block_given?
          begin
            tries ||= 5
            Deja.neo.batch(*Deja.batch)
          rescue Exception => e
            sleep_time = (2..5).to_a.sample # from: http://stackoverflow.com/questions/4395095/how-to-generate-a-random-number-between-a-and-b-in-ruby
            puts "Deja batch exception detected!! Sleeping #{sleep_time} seconds and retrying."
            puts e.inspect
            sleep sleep_time
            retry unless (tries -= 1).zero?
          end
        ensure
          Deja.batch = nil
        end
      end
    end
  end
end
