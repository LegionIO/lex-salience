# frozen_string_literal: true

require 'legion/extensions/salience/version'
require 'legion/extensions/salience/helpers/constants'
require 'legion/extensions/salience/helpers/signal_integrator'
require 'legion/extensions/salience/helpers/salience_map'
require 'legion/extensions/salience/runners/salience'
require 'legion/extensions/salience/client'

module Legion
  module Extensions
    module Salience
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
