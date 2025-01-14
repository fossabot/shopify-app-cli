# frozen_string_literal: true
require "shopify_cli"

module Node
  module Commands
    class Deploy < ShopifyCli::Command
      subcommand :Heroku, "heroku", Project.project_filepath("commands/deploy/heroku")

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message("node.deploy.help", ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message("node.deploy.extended_help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
