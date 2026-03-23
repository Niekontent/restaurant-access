defmodule RestaurantAccess.Access.AccessService do
  @moduledoc """
  Handles access logic for venues based on location.
  """

  alias RestaurantAccess.Access.Queries
  alias RestaurantAccess.Locations.Location
  alias RestaurantAccess.Repo

  def venues_for(location_id) do
    location = Repo.get!(Location, location_id)

    location
    |> Queries.query_for_access_level()
    |> Repo.all()
  end
end
