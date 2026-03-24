defmodule RestaurantAccess.Access.AccessServiceTest do
  use ExUnit.Case
  use RestaurantAccess.DataCase

  alias RestaurantAccess.Access.AccessService
  alias RestaurantAccess.Locations.Location
  alias RestaurantAccess.Venues.Venue
  alias RestaurantAccess.Repo

  describe "venues_for/1" do
    setup do
      root =
        Repo.insert!(%Location{name: "root", access_level: :single})

      child1 =
        Repo.insert!(%Location{name: "child1", parent_id: root.id, access_level: :bi})

      child2 =
        Repo.insert!(%Location{name: "child2", parent_id: root.id, access_level: :node})

      grandchild =
        Repo.insert!(%Location{name: "grandchild", parent_id: child1.id})

      _v_root = Repo.insert!(%Venue{name: "v_root", location_id: root.id})
      _v_child1 = Repo.insert!(%Venue{name: "v_child1", location_id: child1.id})
      _v_child2 = Repo.insert!(%Venue{name: "v_child2", location_id: child2.id})
      _v_grandchild = Repo.insert!(%Venue{name: "v_grandchild", location_id: grandchild.id})

      {:ok,
       locations: %{
         root: root,
         child1: child1,
         child2: child2,
         grandchild: grandchild
       }}
    end

    test "single returns only direct children", %{locations: locations} do
      result = AccessService.venues_for(locations.root.id)
      names = Enum.map(result, & &1.name) |> Enum.sort()

      assert names == ["v_child1", "v_child2"]
    end

    test "bi returns ancestors + descendants + self", %{locations: locations} do
      result = AccessService.venues_for(locations.child1.id)
      names = Enum.map(result, & &1.name) |> Enum.sort()

      assert names == ["v_child1", "v_grandchild", "v_root"]
    end

    test "node returns same level + their children", %{locations: locations} do
      result = AccessService.venues_for(locations.child2.id)
      names = Enum.map(result, & &1.name) |> Enum.sort()

      assert names == ["v_child1", "v_child2", "v_grandchild"]
    end
  end
end
