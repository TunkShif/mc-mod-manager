defmodule McModManager.Helper do
  @doc """
  Write content to a file, create the folder first if it doesn't exist
  """
  @spec file_write(String.t(), String.t()) :: :ok | {:error, any()}
  def file_write(path, content) do
    dirname = path |> Path.expand() |> Path.dirname()

    unless File.dir?(dirname) do
      File.mkdir(dirname)
    end

    File.write(Path.expand(path), content)
  end
end
