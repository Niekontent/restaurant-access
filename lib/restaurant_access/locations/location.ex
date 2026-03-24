defmodule RestaurantAccess.Locations.Location do
  @moduledoc """
  Represents a node in the hierarchical location tree.

  Locations are organized using an adjacency list pattern via `parent_id`,
  which enables traversal using recursive CTE queries.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias RestaurantAccess.Venues.Venue

  @access_levels [:single, :node, :bi]

  schema "locations" do
    field :name, :string
    field :path, :string

    field :access_level, Ecto.Enum, values: @access_levels, default: :bi

    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    has_many :venues, Venue

    timestamps()
  end

  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :path, :access_level, :parent_id])
    |> validate_required([:name, :access_level])
    |> validate_format(:path, ~r/^[a-z0-9_]+(\.[a-z0-9_]+)*$/)
    |> unique_constraint(:path)
  end
end
