defmodule McModManager.Download do
  alias McModManager.Config

  @api_url "https://api.cfwidget.com/minecraft/mc-mods"
  @spec get_project_info(String.t()) :: {:ok, map} | {:error, any}
  def get_project_info(project_id) do
    url = "#{@api_url}/#{project_id}?version=#{Config.game_version()}"

    with {:ok, response} <- HTTPoison.get(url),
         {:ok, body} <- handle_redirection(response),
         {:ok, json} <- Jason.decode(body) do
      %{"id" => file_id, "name" => file_name, "version" => version} = Map.get(json, "download")

      {:ok,
       %{
         "project_id" => project_id,
         "file_name" => file_name,
         "version" => version,
         "file_id" => file_id
       }}
    end
  end

  @spec download_mod(map) :: {:error, atom | Downstream.Error.t()} | {:ok, map}
  def download_mod(mod) do
    %{"file_name" => file_name} = mod

    with {:ok, file} <- File.open("#{Config.game_folder()}/mods/#{file_name}", [:write]),
         {:ok, _response} <- Downstream.get(get_download_url(mod), file) do
      File.close(file)
      {:ok, mod}
    end
  end

  @type body() :: String.t()
  @spec handle_redirection(HTTPoison.Response.t()) :: {:ok, body()} | {:error, any()}
  defp handle_redirection(response) do
    case Map.get(response, :status_code) do
      301 ->
        with {:ok, headers} <- Map.fetch(response, :headers),
             {"Location", redirected_url} <- List.keyfind(headers, "Location", 0),
             {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(redirected_url),
             do: {:ok, body}

      200 ->
        {:ok, Map.get(response, :body)}

      _ ->
        {:error, :not_found}
    end
  end

  @download_url "https://media.forgecdn.net/files"
  defp get_download_url(%{"file_id" => file_id, "file_name" => file_name}) do
    import String, only: [slice: 2]

    "#{@download_url}/#{slice(to_string(file_id), 0..3)}/#{slice(to_string(file_id), 4..6)}/#{
      file_name
    }"
  end
end
