# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"
require "project_types/script/layers/infrastructure/fake_push_package_repository"
require "project_types/script/layers/infrastructure/fake_config_ui_repository"

describe Script::Layers::Application::PushScript do
  include TestHelpers::FakeFS

  let(:compiled_type) { "wasm" }
  let(:language) { "AssemblyScript" }
  let(:api_key) { "api_key" }
  let(:force) { true }
  let(:use_msgpack) { true }
  let(:extension_point_type) { "discount" }
  let(:metadata) { Script::Layers::Domain::Metadata.new("1", "0", use_msgpack) }
  let(:schema_minor_version) { "0" }
  let(:script_name) { "name" }
  let(:config_ui_filename) { "filename" }
  let(:config_ui_contents) { "---" }
  let(:project) do
    TestHelpers::FakeScriptProject.new(
      language: language,
      extension_point_type: extension_point_type,
      script_name: script_name,
      config_ui_file: config_ui_filename,
      env: { api_key: api_key }
    )
  end
  let(:push_package_repository) { Script::Layers::Infrastructure::FakePushPackageRepository.new }
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:config_ui_repository) { Script::Layers::Infrastructure::FakeConfigUiRepository.new }
  let(:task_runner) { stub(compiled_type: "wasm", metadata: metadata) }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:config_ui) { config_ui_repository.get_config_ui(config_ui_filename) }

  before do
    Script::Layers::Infrastructure::PushPackageRepository.stubs(:new).returns(push_package_repository)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    Script::Layers::Infrastructure::ConfigUiRepository.stubs(:new).returns(config_ui_repository)
    Script::Layers::Infrastructure::TaskRunner
      .stubs(:for)
      .with(@context, language, script_name)
      .returns(task_runner)
    Script::ScriptProject.stubs(:current).returns(project)
    extension_point_repository.create_extension_point(extension_point_type)
    config_ui_repository.create_config_ui(config_ui_filename, config_ui_contents)
    push_package_repository.create_push_package(
      script_project: project,
      script_content: "content",
      compiled_type: compiled_type,
      metadata: metadata,
      config_ui: config_ui
    )
  end

  describe ".call" do
    subject { Script::Layers::Application::PushScript.call(ctx: @context, force: force) }

    it "should prepare and push script" do
      script_service_instance = Script::Layers::Infrastructure::ScriptService.new(ctx: @context)
      Script::Layers::Application::ProjectDependencies
        .expects(:install).with(ctx: @context, task_runner: task_runner)
      Script::Layers::Application::BuildScript.expects(:call).with(
        ctx: @context,
        task_runner: task_runner,
        script_project: project,
        config_ui: config_ui
      )
      Script::Layers::Infrastructure::ScriptService
        .expects(:new).returns(script_service_instance)
      Script::Layers::Domain::PushPackage
        .any_instance.expects(:push).with(script_service_instance, api_key, force)
      capture_io { subject }
    end
  end
end
