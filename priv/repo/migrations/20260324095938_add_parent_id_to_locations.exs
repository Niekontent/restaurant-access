defmodule RestaurantAccess.Repo.Migrations.AddParentIdToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :parent_id, references(:locations, on_delete: :nilify_all)
    end

    create index(:locations, [:parent_id])
  end
end
