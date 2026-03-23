defmodule RestaurantAccess.Locations.Location do
  use Ecto.Schema

  import Ecto.Changeset

  alias RestaurantAccess.Venues.Venue

  @access_levels [:single, :node, :bi]

  schema "locations" do
    field :name, :string
    field :path, :string

    field :access_level, Ecto.Enum, values: @access_levels, default: :bi

    has_many :venues, Venue

    timestamps()
  end

  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :path, :access_level])
    |> validate_required([:name, :path, :access_level])
    |> validate_format(:path, ~r/^[a-z0-9_]+(\.[a-z0-9_]+)*$/)
    |> unique_constraint(:path)
  end
end
