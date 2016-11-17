module Voltron
  class Config

    def crop
      @crop ||= Crop.new
    end

    class Crop

      attr_accessor :min_width, :min_height

      def initialize
        @min_width ||= 300
        @min_height ||= 300
      end
    end
  end
end