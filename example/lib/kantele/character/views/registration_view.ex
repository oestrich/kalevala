defmodule Kantele.Character.RegistrationView do
  use Kalevala.Character.View

  alias Kalevala.Character.Conn.EventText

  def render("password", _assigns) do
    %EventText{
      topic: "Registration.PromptPassword",
      data: %{},
      text: "Password: "
    }
  end
end
