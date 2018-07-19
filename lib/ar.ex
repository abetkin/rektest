defmodule HelloCmd do
  use Artificery

  command :hello, "Says hello" do
    argument :name, :string, "The name of the person to greet", required: true
  end

  def hello(_args, %{name: name}) do
    Artificery.Console.notice "Hello #{name}!"
  end
end
