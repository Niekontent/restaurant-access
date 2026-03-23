defmodule RestaurantAccessWeb.Access.AccessServiceTest do
  use ExUnit.Case
  use RestaurantAccess.DataCase

  alias RestaurantAccess.Access.AccessService
  alias RestaurantAccess.Locations.Location
  alias RestaurantAccess.Venues.Venue
  alias RestaurantAccess.Repo

  describe "venues_for/1" do
    setup do
      loc_root =
        Repo.insert!(%Location{name: "Root", path: "1", access_level: :single})

      loc_child1 =
        Repo.insert!(%Location{name: "Child1", path: "1.1", access_level: :bi})

      loc_child2 =
        Repo.insert!(%Location{name: "Child2", path: "1.2", access_level: :node})

      loc_grandchild =
        Repo.insert!(%Location{name: "Grandchild", path: "1.1.1"})

      _venue_1 = Repo.insert!(%Venue{name: "V Root", location_id: loc_root.id})
      _venue_2 = Repo.insert!(%Venue{name: "V Child1", location_id: loc_child1.id})
      _venue_3 = Repo.insert!(%Venue{name: "V Child2", location_id: loc_child2.id})
      _venue_4 = Repo.insert!(%Venue{name: "V Grandchild", location_id: loc_grandchild.id})

      {:ok,
       locations: %{
         root: loc_root,
         child1: loc_child1,
         child2: loc_child2,
         grandchild: loc_grandchild
       }}
    end

    test "single mode returns only immediate children", %{
      locations: locations
    } do
      result = AccessService.venues_for(locations.root.id)

      names = Enum.map(result, & &1.name)
      assert Enum.sort(names) == ["V Child1", "V Child2"]
    end

    test "bi mode returns all descendants and ancestors", %{
      locations: locations
    } do
      result = AccessService.venues_for(locations.child1.id)
      names = Enum.map(result, & &1.name)

      assert Enum.sort(names) == ["V Child1", "V Grandchild", "V Root"]
    end

    test "node mode returns same level + their children", %{locations: locations} do
      result = AccessService.venues_for(locations.child2.id)
      names = Enum.map(result, & &1.name)

      assert Enum.sort(names) == ["V Child1", "V Child2", "V Grandchild"]
    end
  end
end
