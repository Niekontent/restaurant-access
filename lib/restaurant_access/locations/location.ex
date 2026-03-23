defmodule RestaurantAccess.Locations.Location do
  use Ecto.Schema

  alias RestaurantAccess.Venues.Venue

  schema "locations" do
    field :name, :string
    field :path, :string   # ltree

    has_many :venues, Venue
  end
end
