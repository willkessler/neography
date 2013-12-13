module Deja
  class Boolean

    TRUE_VALUES  = Set.new([true,  't', 'true',  1, '1', 'yes', 'y'])
    FALSE_VALUES = Set.new([false, 'f', 'false', 0, '0', 'no',  'n'])

    class << self
      def true?(value)
        TRUE_VALUES.include? value
      end

      def false?(value)
        FALSE_VALUES.include? value
      end

      def boolean?(value)
        true?(value) || false?(value)
      end
    end

  end
end
