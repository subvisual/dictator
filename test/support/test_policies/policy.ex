defmodule Dictator.TestPolicies do
  defmodule OpenDoors do
    use Dictator.Policy

    @impl Dictator.Policy
    def can?(_, _, _), do: true
  end

  defmodule SlightlyOpenDoors do
    use Dictator.Policy

    @impl Dictator.Policy
    def can?(:very, :specific, :thing), do: true
  end
end
