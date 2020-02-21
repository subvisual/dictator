defmodule Dictator.Test.StandardWithDifferentKeys do
  defmodule Struct do
    defstruct [:id, :organization_id]
  end

  defmodule Repo do
    def get_by(Struct, id: id), do: %Struct{id: id, organization_id: id}
  end

  defmodule Policy do
    alias Dictator.Test.StandardWithDifferentKeys.{Repo, Struct}

    use Dictator.Policies.Standard,
      for: Struct,
      repo: Repo,
      foreign_key: :organization_id,
      owner_key: :slug
  end
end
