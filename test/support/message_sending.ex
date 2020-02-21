defmodule Dictator.Test.MessageSending do
  defmodule Struct do
    defstruct [:id, :user_id]
  end

  defmodule Repo do
    def get_by(Struct, id: id) do
      send(self(), {:get_by, Struct, [id: id]})
      %Struct{id: id, user_id: id}
    end
  end

  defmodule SampleController do
  end
end

defmodule Dictator.Policies.Test.MessageSending.Sample do
  alias Dictator.Test.MessageSending.{Repo, Struct}

  use Dictator.Policy, for: Struct, repo: Repo

  @impl true
  def can?(user, action, resource) do
    send(self(), {:can?, user, action, resource})

    do_can?(user, action, resource)
  end

  defp do_can?(_, action, _) when action in [:index, :new, :create], do: true

  defp do_can?(%{id: user_id}, action, %Struct{user_id: user_id})
       when action in [:edit, :update, :delete, :show],
       do: true

  defp do_can?(_, _, _), do: false
end
