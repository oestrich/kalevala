defmodule Mix.Tasks.Kalevala.Gen.Command do
  @moduledoc """
  Generate files for a new command (command / event / views)
  """

  use Mix.Task

  alias Mix.Generator

  def run([command]) do
    otp_app = Keyword.fetch!(Mix.Project.config(), :app)
    main_module = String.capitalize(to_string(otp_app))
    module = String.capitalize(command)

    generate_file(["commands", "#{command}_command.ex"], command_template(main_module, module))
    generate_file(["events", "#{command}_event.ex"], event_template(main_module, module))
    generate_file(["views", "#{command}_view.ex"], view_template(main_module, module))
  end

  def generate_file(file, template) do
    otp_app = Keyword.fetch!(Mix.Project.config(), :app)

    file = Path.join(["lib", to_string(otp_app), "character" | file])

    Generator.create_file(file, template)
  end

  def command_template(main_module, command) do
    """
    defmodule #{main_module}.Character.#{command}Command do
      use Kalevala.Character.Command

      def run(conn, params) do
        conn
      end
    end
    """
  end

  def event_template(main_module, command) do
    """
    defmodule #{main_module}.Character.#{command}Event do
      use Kalevala.Character.Event
    end
    """
  end

  def view_template(main_module, command) do
    """
    defmodule #{main_module}.Character.#{command}View do
      use Kalevala.Character.View
    end
    """
  end
end
