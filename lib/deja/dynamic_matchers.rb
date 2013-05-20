module Deja
  module DynamicMatchers
    def method_missing(method_name, *args, *block)
      if method_name.to_s =~ /^find_by_(.+)$/
        # do stuffs
      else
        super
      end
    end
  end
end