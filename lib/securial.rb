require "securial/version"
require "securial/engine"

require "jbuilder"

module Securial
  class << self
    delegate :protected_namespace, to: Securial::Helpers::RolesHelper
  end
end
