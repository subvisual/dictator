defmodule Dictator.TestPolicy do
  defmodule Repo do
    alias Dictator.TestPolicy
    alias Dictator.TestPolicy.Struct

    def get_by(Struct, [{"id", 1}]), do: {:ok, TestPolicy}
    def get_by(Struct, id: 1), do: {:ok, TestPolicy}
    def get_by(Struct, [{"other", _}]), do: {:ok, TestPolicy.WithOtherKey}
    def get_by(_, _), do: {:ok, false}
  end

  defmodule Struct do
    defstruct [:id]
  end

  use Dictator.Policies.EctoSchema, for: Struct, repo: Repo

  defmodule WithOtherKey do
    use Dictator.Policies.EctoSchema, for: Struct, repo: Repo, key: "other"
  end
end
