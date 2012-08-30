module EY
  module Serverside
    class Adapter
      VERSION = "2.0.4.pre"
      # For backwards compatibility, the serverside version default will be maintained until 2.1
      # It is recommended that you supply a serverside_version to engineyard-serverside-adapter
      # rather than relying on the default version here. This default will go away soon.
      ENGINEYARD_SERVERSIDE_VERSION = ENV['ENGINEYARD_SERVERSIDE_VERSION'] || "2.0.1"
    end
  end
end
