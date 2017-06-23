require 'voltron'
require 'carrierwave'
require 'voltron/config/crop'
require 'voltron/crop/version'
require 'voltron/crop/action_view/field'
require 'voltron/crop/active_record/base'

module Voltron
  module Crop

    # Nothing needed here for now

  end
end

require 'voltron/crop/engine' if defined?(Rails)