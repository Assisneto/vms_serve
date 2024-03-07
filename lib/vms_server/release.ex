defmodule VmsServer.Release do
  @doc """
  Migrate the database. Defaults to migrating to the latest, `[all: true]`
  Also accepts `[step: 1]`, or `[to: 20200118045751]`
  """

  @app :vms_server

  def migrate(opts \\ [all: true]) do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, opts))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  @doc """
  Print the migration status for configured Repos' migrations.
  """
  def migration_status do
    for repo <- repos(), do: print_migrations_for(repo)
  end

  defp print_migrations_for(repo) do
    paths = repo_migrations_path(repo)

    {:ok, repo_status, _} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.migrations(&1, paths), mode: :temporary)

    IO.puts(
      """
      Repo: #{inspect(repo)}
        Status    Migration ID    Migration Name
      --------------------------------------------------
      """ <>
        Enum.map_join(repo_status, "\n", fn {status, number, description} ->
          "  #{pad(status, 10)}#{pad(number, 16)}#{description}"
        end) <> "\n"
    )
  end

  defp repo_migrations_path(repo) do
    config = repo.config()
    priv = config[:priv] || "priv/#{repo |> Module.split() |> List.last() |> Macro.underscore()}"
    config |> Keyword.fetch!(:otp_app) |> Application.app_dir() |> Path.join(priv)
  end

  defp pad(content, pad) do
    content
    |> to_string
    |> String.pad_trailing(pad)
  end

  def migrate_data(opts \\ [all: true]) do
    for repo <- repos() do
      path = Ecto.Migrator.migrations_path(repo, "data_migrations")
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, path, :up, opts))
    end
  end

  def seed do
    load_app()

    path = Application.app_dir(@app, "priv/repo/seeds.exs")

    IO.puts("Running seeds script: #{path}")
    Code.eval_file(path)
  end

  defp load_app do
    Application.load(@app)

    case Application.ensure_all_started(@app) do
      {:ok, _} ->
        :ok

      {:error, {app, reason}} ->
        IO.puts("Failed to start application #{inspect(app)}: #{inspect(reason)}")
    end
  end
end
