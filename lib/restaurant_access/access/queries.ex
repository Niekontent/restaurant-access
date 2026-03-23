defmodule RestaurantAccess.Access.Queries do
  import Ecto.Query

  alias RestaurantAccess.Locations.Location
  alias RestaurantAccess.Venues.Venue

  def query_for_access_level(%Location{access_level: :single} = loc) do
    from(r in Venue,
      join: l in Location,
      on: r.location_id == l.id,
      where:
        fragment("? <@ ?", l.path, ^loc.path) and
          fragment("nlevel(?) = nlevel(?) + 1", l.path, ^loc.path),
      select: r
    )
  end

  def query_for_access_level(%Location{access_level: :bi} = loc) do
    from(r in Venue,
      join: l in Location,
      on: r.location_id == l.id,
      where:
        fragment("? <@ ?", l.path, ^loc.path) or
          fragment("? @> ?", l.path, ^loc.path),
      select: r
    )
  end

  def query_for_access_level(%Location{access_level: :node} = loc) do
    same_level =
      from l in Location,
        where: fragment("nlevel(?) = nlevel(?)", l.path, ^loc.path)

    children =
      from l in Location,
        join: p in subquery(same_level),
        on:
          fragment("? <@ ?", l.path, p.path) and
            fragment("nlevel(?) = nlevel(?) + 1", l.path, p.path)

    locations =
      same_level
      |> union_all(^children)

    from(r in Venue,
      join: l in subquery(locations),
      on: r.location_id == l.id,
      select: r
    )
  end
end
