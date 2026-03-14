# frozen_string_literal: true

module Legion
  module Extensions
    module Salience
      class Client
        include Runners::Salience

        attr_reader :salience_map

        def initialize(salience_map: nil, **)
          @salience_map = salience_map || Helpers::SalienceMap.new
        end
      end
    end
  end
end
