defmodule RestaurantAccess.Repo.Migrations.CreateLocationsAndVenues do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS ltree;"

    create table(:locations) do
      add :name, :string
      add :path, :ltree

      timestamps()
    end

    create index(:locations, [:path], using: :gist)

    create table(:venues) do
      add :name, :string
      add :location_id, references(:locations)

      timestamps()
    end
  end

  def down do
    drop table(:venues)
    drop table(:locations)
    execute "DROP EXTENSION IF EXISTS ltree;"
  end
end
