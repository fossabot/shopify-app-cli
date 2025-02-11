require "test_helper"

module Extension
  module Forms
    module Questions
      class AskNameTest < MiniTest::Test
        include TestHelpers
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
        end

        def test_accepts_a_valid_name_as_property
          AskName.new(ctx: context, name: "Valid Name").call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            assert_equal("Valid Name", result.value.name)
          end
        end

        def test_prompts_for_name_if_none_given
          AskName.new(ctx: context, prompt: ->(_msg) { "Valid Name" }).call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            assert_equal("Valid Name", result.value.name)
          end
        end

        def test_reprompt_until_valid_name
          retries = (1..5).to_a.sample
          reprompter = Reprompt.new(retries)

          AskName.new(ctx: context, prompt: reprompter).call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            assert_equal("Valid Name", result.value.name)
          end

          assert_equal retries, reprompter.counter
        end

        def test_ctx_is_the_only_required_configuration_option
          assert_nothing_raised { AskName.new(ctx: FakeContext.new) }
        end

        def test_strips_whitespace_from_beginning_and_end_of_name
          AskName.new(ctx: context, prompt: ->(_) { "  Valid Name  " }).call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            assert_equal("Valid Name", result.value.name)
          end
        end

        class Reprompt
          attr_accessor :counter, :retries

          def initialize(retries)
            @counter = 0
            @retries = retries
          end

          def call(_message)
            self.counter += 1
            counter < retries ? "" : "Valid Name"
          end
        end

        private

        def context
          FakeContext.new
        end
      end
    end
  end
end
