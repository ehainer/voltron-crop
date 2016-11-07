module Voltron
  class Config

    def crop
      @crop ||= Crop.new
    end

    class Crop

      attr_accessor :min_width, :min_height, :raise_on_error

      def initialize
        @min_width ||= 300
        @min_height ||= 300
        @raise_on_error ||= false
      end
    end
  end
end