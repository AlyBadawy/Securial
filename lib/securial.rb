require "securial/version"
require "securial/engine"

require "jbuilder"

module Securial
  extend self

  delegate :protected_namespace, to: Securial::Helpers::RolesHelper
  delegate :titleized_admin_role, to: Securial::Helpers::RolesHelper
end
