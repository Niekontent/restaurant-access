# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RestaurantAccess.Repo.insert!(%RestaurantAccess.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias RestaurantAccess.Repo
alias RestaurantAccess.Locations.Location
alias RestaurantAccess.Venues.Venue

# LEVEL 1 (root)
root =
  Repo.insert!(%Location{
    name: "World",
    access_level: :bi
  })

# LEVEL 2
europe =
  Repo.insert!(%Location{
    name: "Europe",
    parent_id: root.id,
    access_level: :node
  })

asia =
  Repo.insert!(%Location{
    name: "Asia",
    parent_id: root.id,
    access_level: :single
  })

# LEVEL 3
poland =
  Repo.insert!(%Location{
    name: "Poland",
    parent_id: europe.id,
    access_level: :bi
  })

germany =
  Repo.insert!(%Location{
    name: "Germany",
    parent_id: europe.id,
    access_level: :single
  })

japan =
  Repo.insert!(%Location{
    name: "Japan",
    parent_id: asia.id,
    access_level: :node
  })

# LEVEL 4
warsaw =
  Repo.insert!(%Location{
    name: "Warsaw",
    parent_id: poland.id,
    access_level: :single
  })

torun =
  Repo.insert!(%Location{
    name: "Torun",
    parent_id: poland.id,
    access_level: :node
  })

berlin =
  Repo.insert!(%Location{
    name: "Berlin",
    parent_id: germany.id,
    access_level: :bi
  })

tokyo =
  Repo.insert!(%Location{
    name: "Tokyo",
    parent_id: japan.id,
    access_level: :single
  })

# LEVEL 5
district_warsaw =
  Repo.insert!(%Location{
    name: "Warsaw Center",
    parent_id: warsaw.id,
    access_level: :bi
  })

# VENUES

Repo.insert!(%Venue{name: "Global Venue", location_id: root.id})

Repo.insert!(%Venue{name: "Europe Venue", location_id: europe.id})
Repo.insert!(%Venue{name: "Asia Venue", location_id: asia.id})

Repo.insert!(%Venue{name: "Poland Venue", location_id: poland.id})
Repo.insert!(%Venue{name: "Germany Venue", location_id: germany.id})
Repo.insert!(%Venue{name: "Japan Venue", location_id: japan.id})

Repo.insert!(%Venue{name: "Warsaw Venue", location_id: warsaw.id})
Repo.insert!(%Venue{name: "Torun Venue", location_id: torun.id})
Repo.insert!(%Venue{name: "Berlin Venue", location_id: berlin.id})
Repo.insert!(%Venue{name: "Tokyo Venue", location_id: tokyo.id})

Repo.insert!(%Venue{name: "District Venue", location_id: district_warsaw.id})
