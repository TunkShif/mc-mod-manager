defmodule McModManager.Config do
  alias McModManager.Helper

  @config_file "~/.config/mmm/config.json"
  @spec init(String.t(), String.t()) :: :ok | {:error, any()}
  def init(path, game_version) do
    config = %{
      "game_folder" => path,
      "game_version" => game_version
    }

    with {:ok, json} <- Jason.encode(config, pretty: true) do
      Helper.file_write(@config_file, json)
      Helper.file_write("#{Path.expand(path)}/mods.json", "[]")
    end
  end

  @spec load :: :error | {:error, atom | Jason.DecodeError.t()} | {:ok, pid}
  def load() do
    with {:ok, content} <- File.read(Path.expand(@config_file)),
         {:ok, config} <- Jason.decode(content),
         {:ok, game_folder} <- Map.fetch(config, "game_folder"),
         {:ok, mods} <- File.read("#{game_folder}/mods.json"),
         {:ok, mod_list} <- Jason.decode(mods) do
      state = config |> Map.put("mod_list", mod_list)
      {:ok, _agent} = Agent.start_link(fn -> state end, name: __MODULE__)
    end
  end

  @spec game_folder :: String.t()
  def game_folder, do: Agent.get(__MODULE__, &Map.get(&1, "game_folder"))

  @spec game_version :: String.t()
  def game_version, do: Agent.get(__MODULE__, &Map.get(&1, "game_version"))

  @spec mod_list :: list(map)
  def mod_list, do: Agent.get(__MODULE__, &Map.get(&1, "mod_list"))

  @spec add_mod(map) :: :ok
  def add_mod(mod),
    do:
      Agent.update(__MODULE__, fn state ->
        mod_list = Map.get(state, "mod_list")
        %{state | "mod_list" => mod_list ++ [mod]}
      end)

  @spec find_mod(String.t()) :: map
  def find_mod(project_id), do: Enum.find(mod_list(), &(Map.get(&1, "project_id") == project_id))

  @spec remove_mod(map) :: :ok
  def remove_mod(mod),
    do:
      Agent.update(__MODULE__, fn state ->
        mod_list = Map.get(state, "mod_list") |> List.delete(mod)
        %{state | "mod_list" => mod_list}
      end)

  @spec save :: :ok | {:error, atom}
  def save() do
    %{"game_folder" => game_folder, "mod_list" => mod_list} = Agent.get(__MODULE__, & &1)
    Helper.file_write("#{game_folder}/mods.json", Jason.encode!(mod_list, pretty: true))
  end
end
