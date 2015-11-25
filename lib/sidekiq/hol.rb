require 'sidekiq'
require 'sidekiq/util'
require 'sidekiq/api'

require_relative 'hol/client'
require_relative 'hol/worker'

module Sidekiq
  module Hol
  end
end
