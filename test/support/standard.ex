defmodule Dictator.Test.Standard do
  defmodule Struct do
    defstruct [:id, :user_id]
  end

  defmodule Repo do
    def get_by(Struct, id: id), do: %Struct{id: id, user_id: id}
  end

  defmodule Policy do
    alias Dictator.Test.Standard.{Repo, Struct}

    use Dictator.Policies.CRUD, for: Struct, repo: Repo
  end
end
