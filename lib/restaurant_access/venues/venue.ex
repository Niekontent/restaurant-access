defmodule RestaurantAccess.Venues.Venue do
  @moduledoc """
  Represents a venue assigned to a specific location.

  Venue access is determined indirectly through the location hierarchy.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias RestaurantAccess.Locations.Location

  schema "venues" do
    field :name, :string
    belongs_to :location, Location

    timestamps()
  end

  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :location_id])
    |> validate_required([:name, :location_id])
  end
end
