defmodule RestaurantAccess.Access.Queries do
  @moduledoc """
  Provides Ecto query builders for resolving venue access based on location hierarchy.

  This module implements hierarchical access using recursive CTEs (`WITH RECURSIVE`)
  in order to traverse the location tree stored as an adjacency list (`parent_id`).

  Supported access modes:

    * `:single` – returns venues assigned to direct children of a given location
    * `:bi` – returns venues for the given location, all its ancestors, and all descendants
    * `:node` – returns venues for locations on the same level as the given node and their children

  The functions in this module return `Ecto.Query` structs and do not execute database calls directly.
  Execution is delegated to the service layer.

  This module focuses purely on query composition and does not contain business logic.
  """
  import Ecto.Query

  alias RestaurantAccess.Locations.Location
  alias RestaurantAccess.Venues.Venue

  @spec query_for_access_level(%Location{:access_level => :bi | :node | :single}) ::
          Ecto.Query.t()
  def query_for_access_level(%Location{access_level: :single} = loc) do
    from v in Venue,
      join: l in Location,
      on: v.location_id == l.id,
      where: l.parent_id == ^loc.id
  end

  def query_for_access_level(%Location{access_level: :bi} = loc) do
    descendants = descendants_cte(loc.id)
    ancestors = ancestors_cte(loc.id)

    query =
      Location
      |> recursive_ctes(true)
      |> with_cte("descendants", as: ^descendants)
      |> with_cte("ancestors", as: ^ancestors)
      |> join(:inner, [l], d in "descendants", on: l.id == d.id)
      |> union_all(
        ^from(l in Location,
          join: a in "ancestors",
          on: l.id == a.id
        )
      )

    from v in Venue,
      join: l in subquery(query),
      on: v.location_id == l.id,
      distinct: true,
      select: v
  end

  def query_for_access_level(%Location{access_level: :node} = loc) do
    ancestors = ancestors_with_depth(loc.id)

    query =
      Location
      |> recursive_ctes(true)
      |> with_cte("ancestors_depth", as: ^ancestors)
      |> with_cte("target_depth",
        as:
          ^from(a in "ancestors_depth",
            order_by: [desc: a.depth],
            limit: 1,
            select: %{depth: a.depth}
          )
      )
      |> join(:inner, [l], td in "target_depth", on: true)
      |> where(
        [l, td],
        fragment(
          "(SELECT COUNT(*) FROM locations p WHERE p.id = ?)",
          l.parent_id
        ) == td.depth
      )

    children =
      from l in Location,
        join: p in subquery(query),
        on: l.parent_id == p.id

    locations =
      query
      |> union_all(^children)

    from v in Venue,
      join: l in subquery(locations),
      on: v.location_id == l.id,
      distinct: true,
      select: v
  end

  defp descendants_cte(location_id) do
    base =
      from l in Location,
        where: l.id == ^location_id,
        select: %{id: l.id, parent_id: l.parent_id}

    recursive =
      from l in Location,
        join: d in "descendants",
        on: l.parent_id == d.id,
        select: %{id: l.id, parent_id: l.parent_id}

    base |> union_all(^recursive)
  end

  defp ancestors_cte(location_id) do
    base =
      from l in Location,
        where: l.id == ^location_id,
        select: %{id: l.id, parent_id: l.parent_id}

    recursive =
      from l in Location,
        join: a in "ancestors",
        on: l.id == a.parent_id,
        select: %{id: l.id, parent_id: l.parent_id}

    base |> union_all(^recursive)
  end

  defp ancestors_with_depth(location_id) do
    base =
      from l in Location,
        where: l.id == ^location_id,
        select: %{id: l.id, parent_id: l.parent_id, depth: 0}

    recursive =
      from l in Location,
        join: a in "ancestors_depth",
        on: l.id == a.parent_id,
        select: %{
          id: l.id,
          parent_id: l.parent_id,
          depth: a.depth + 1
        }

    base |> union_all(^recursive)
  end
end
