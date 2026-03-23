defmodule RestaurantAccess.Venues.Venue do
  use Ecto.Schema

  alias RestaurantAccess.Locations.Location

  schema "venues" do
    field :name, :string
    belongs_to :location, Location
  end
end
