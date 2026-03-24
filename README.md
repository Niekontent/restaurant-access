# Restaurant Access System

## Overview

This project implements a system for retrieving venues based on hierarchical location access rules.

Locations are organized in a tree structure, and access to venues depends on the **access level** assigned to a given location.

The solution is implemented using **Elixir**, **Ecto**, and **PostgreSQL**.

---

## Requirements

The system supports three access modes:

* **`:single`**
  Access only to venues assigned to **direct children** of a given location.

* **`:bi`**
  Access to venues in:

  * the given location
  * all its **ancestors**
  * all its **descendants**

* **`:node`**
  Access to venues in:

  * locations on the **same level**
  * and their **direct children**

---

## Data Model

### Location

Locations are stored using an **adjacency list pattern**:

* `id`
* `name`
* `parent_id` (self-referencing)
* `access_level` (`Ecto.Enum`: `:single | :bi | :node`)

This structure allows traversal using recursive queries.

---

### Venue

Each venue belongs to a single location:

* `id`
* `name`
* `location_id`

---

## Approach

### Primary Solution (Required): Recursive CTE

The main implementation uses **recursive Common Table Expressions (CTE)** via Ecto:

* `WITH RECURSIVE`
* `recursive_ctes(true)`
* tree traversal using `parent_id`

This approach was chosen because the task explicitly requires recursion.

---

### Query Layer

All query logic is encapsulated in:

```elixir
RestaurantAccess.Access.Queries
```

Responsibilities:

* build Ecto queries
* implement traversal logic for each access mode
* return `Ecto.Query` structs (no DB execution)

---

### Service Layer

Public API:

```elixir
RestaurantAccess.Access.AccessService
```

Responsibilities:

* fetch location
* delegate query building
* execute query via `Repo`

Example:

```elixir
AccessService.venues_for(location_id)
```

---

## Handling Duplicates

Due to the use of `UNION ALL` and joins, duplicate rows may occur.

This is resolved using:

```elixir
distinct: true
```

at the query level.

---

## Alternative Approach (Bonus): PostgreSQL `ltree`

An alternative implementation using PostgreSQL's **`ltree`** extension is included.

Advantages:

* simpler queries
* better performance for hierarchical lookups

However, it was not used as the primary solution because:

> the task explicitly requires recursion.

The `ltree` implementation is available in a separate module for comparison.

---

## Seed Data

The project includes seed data with:

* at least **4 levels of hierarchy**
* multiple branches
* all access levels (`:single`, `:bi`, `:node`)

To load seed data:

```bash
mix run priv/repo/seeds.exs
```

---

## Running the Project

### Setup

```bash
mix deps.get
mix ecto.setup
```

### Run tests

```bash
mix test
```

---

## Example Structure

```
World (:bi)
├── Europe (:node)
│   ├── Poland (:bi)
│   │   ├── Warsaw (:single)
│   │   │   └── District (:bi)
│   │   └── Torun (:node)
│   └── Germany (:single)
│       └── Berlin (:bi)
└── Asia (:single)
    └── Japan (:node)
        └── Tokyo (:single)
```

---

## Design Considerations

* Clear separation of concerns:

  * schema
  * query layer
  * service layer

* Use of recursive SQL for hierarchical traversal

* Extensible access model

* Alternative optimized approach (`ltree`) documented but not enforced

---

## Summary

This solution demonstrates:

* recursive querying in Ecto
* hierarchical data modeling
* clean architecture (separation of layers)
* awareness of alternative database strategies

---
