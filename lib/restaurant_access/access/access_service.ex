defmodule RestaurantAccess.Access.AccessService do
  @moduledoc """
  Provides the public API for resolving venue access based on location.

  This module acts as a service layer responsible for:
    * fetching the location entity
    * delegating query construction to the query layer
    * executing queries via the repository

  The underlying access logic is implemented using recursive CTEs
  to traverse the location hierarchy.

  This module does not define query logic itself, but orchestrates
  the flow between the domain and the database layer.
  """

  alias RestaurantAccess.Access.Queries
  alias RestaurantAccess.Locations.Location
  alias RestaurantAccess.Repo

  @spec venues_for(integer()) :: list()
  def venues_for(location_id) do
    location = Repo.get!(Location, location_id)

    location
    |> Queries.query_for_access_level()
    |> Repo.all()
  end
end
