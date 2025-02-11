module TestHelpers
  class FakeScriptProject < FakeProject
    property :extension_point_type
    property :script_name
    property :language
    property :config_ui_file
    property :env

    def api_key
      env[:api_key]
    end
  end
end
