# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ExtensionPoint
        attr_reader :type, :beta, :deprecated, :sdks, :domain

        def initialize(type, config)
          @type = type
          @beta = config["beta"] || false
          @deprecated = config["deprecated"] || false
          @domain = config["domain"] || nil
          @sdks = ExtensionPointSDKs.new(config)
        end

        def beta?
          @beta
        end

        def deprecated?
          @deprecated
        end

        def dasherize_type
          @type.gsub("_", "-")
        end
      end

      class ExtensionPointSDKs
        def initialize(config)
          @config = config
        end

        def all
          [assemblyscript, rust].compact
        end

        def assemblyscript
          @assemblyscript ||= new_sdk(ExtensionPointAssemblyScriptSDK)
        end

        def rust
          @rust ||= new_sdk(ExtensionPointRustSDK)
        end

        private

        def new_sdk(klass)
          config = @config[klass.language]
          return nil if config.nil?
          klass.new(config)
        end
      end

      class ExtensionPointSDK
        attr_reader :version, :beta, :package

        def initialize(config)
          @beta = config["beta"] || false
          @package = config["package"]
          @version = config["package-version"]
        end

        def beta?
          @beta
        end

        def versioned?
          @version
        end

        def self.language
          raise NotImplementedError
        end
      end

      class ExtensionPointAssemblyScriptSDK < ExtensionPointSDK
        attr_reader :sdk_version, :toolchain_version

        def initialize(config)
          super
          @sdk_version = config["sdk-version"]
          @toolchain_version = config["toolchain-version"]
        end

        def self.language
          "assemblyscript"
        end
      end

      class ExtensionPointRustSDK < ExtensionPointSDK
        def self.language
          "rust"
        end
      end
    end
  end
end
