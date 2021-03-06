defmodule McModManager.CLI do
  def main(args) do
    Optimus.new!(
      name: "mmm",
      description: "Minecraft Mod Manager",
      version: "0.1.1",
      author: "TunkShif tunkshif@foxmail.com",
      about: "package manager for minecraft mods",
      parse_double_dash: true,
      subcommands: [
        init: [
          name: "init",
          about: "Initiate a minecraft folder for mmm",
          args: [
            version: [
              value_name: "GAME_VERSION",
              help: "The version of Minecraft game",
              required: true,
              parser: :string
            ]
          ]
        ],
        add: [
          name: "add",
          about: "Add a new mod",
          args: [
            project_id: [
              value_name: "PROJECT_ID",
              help: "Curseforge project id of the mod",
              required: true,
              parser: :string
            ]
          ]
        ],
        remove: [
          name: "remove",
          about: "Remove a installed mod",
          args: [
            project_id: [
              value_name: "PROJECT_ID",
              help: "Curseforge project id of the mod",
              required: true,
              parser: :string
            ]
          ]
        ],
        list: [
          name: "list",
          about: "List all installed mods"
        ],
        update: [
          name: "update",
          about: "Check update for installed mods"
        ]
      ]
    )
    |> Optimus.parse!(args)
    |> load_config_if_needed()
    # |> IO.inspect()
    |> run()
  end

  @spec load_config_if_needed(tuple()) :: tuple()
  def load_config_if_needed(parse_result) do
    case parse_result do
      {[:init], _} ->
        parse_result

      _ ->
        McModManager.Config.load()
        parse_result
    end
  end

  def run({[:init], %Optimus.ParseResult{args: %{version: version}}}) do
    path = Path.expand(".")

    case McModManager.Config.init(path, version) do
      :ok ->
        ~s"""
        * minecraft folder: #{path}
        * minecraft version: #{version}
        """
        |> IO.puts()

      {:error, reason} ->
        "!ERROR: #{IO.inspect(reason)}" |> IO.puts()
    end
  end

  def run({[:add], %Optimus.ParseResult{args: %{project_id: project_id}}}) do
    with {:ok, mod} <- McModManager.Download.get_project_info(project_id),
         IO.puts("Find #{Map.get(mod, "file_name")}, start downloading..."),
         {:ok, _} <- McModManager.Download.download_mod(mod) do
      McModManager.Config.add_mod(mod)
      McModManager.Config.save()
      IO.puts("Done!")
    else
      {:error, :not_found} -> IO.puts("Cannot find the given mod")
      {:error, reason} -> IO.puts("!ERROR: #{IO.inspect(reason)}")
    end
  end

  def run({[:list], %Optimus.ParseResult{}}) do
    case McModManager.Config.mod_list() do
      [] ->
        IO.puts("You haven't installed any mod yet.")

      mods ->
        IO.puts("Project ID :: File Name")

        mods
        |> Enum.each(fn mod ->
          %{"project_id" => project_id, "file_name" => file_name} = mod
          IO.puts("#{project_id} :: #{file_name}")
        end)
    end
  end

  def run({[:update], %Optimus.ParseResult{}}) do
    IO.puts("Not implemented yet")
  end

  def run({[:remove], %Optimus.ParseResult{args: %{project_id: project_id}}}) do
    mod = McModManager.Config.find_mod(project_id)

    if mod do
      %{"file_name" => file_name} = mod
      McModManager.Config.remove_mod(mod)

      case File.rm("#{McModManager.Config.game_folder()}/mods/#{file_name}") do
        :ok -> IO.puts("#{file_name} removed!")
        {:error, :enoent} -> IO.puts("!ERROR: #{file_name} doesn't exist\n")
      end
    else
      IO.puts("!ERROR: mod not found")
    end

    McModManager.Config.save()
  end

  def run(_parse_result), do: IO.puts("Unknown command\nCheck `mmm --help` for help")
end
