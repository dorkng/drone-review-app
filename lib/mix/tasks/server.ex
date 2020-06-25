defmodule Mix.Tasks.Server do
  use Mix.Task

  alias Mix.Project
  alias Mix.Shell.IO

  @moduledoc """

  """

  @switches [port: :string]

  @spec otp_app() :: atom()
  def otp_app(), do: Keyword.fetch!(Mix.Project.config(), :review_app)

  @doc """
  Raises an exception if the project is an umbrella app.
  """
  @spec no_umbrella!(binary()) :: :ok | no_return
  def no_umbrella!(task) do
    if Project.umbrella?() do
      Mix.raise("mix #{task} can only be run inside an application directory")
    end

    :ok
  end

  @shortdoc "Creates a new OAuth client based on the provided details"
  def run(args) do
    {config, _parsed, _invalid} = parse_options(args, @switches)
    inspect config
    IO.info "custom mix task"
  end

  defp to_map(keyword) do
    callback = fn {key, value}, map ->
      case Map.get(map, key) do
        nil ->
          Map.put(map, key, value)

        existing_value ->
          value = List.wrap(existing_value) ++ [value]
          Map.put(map, key, value)
      end
    end

    Enum.reduce(keyword, %{}, callback)
  end

  @spec parse_options(OptionParser.argv(), Keyword.t(), Keyword.t()) :: {map(), OptionParser.argv(), OptionParser.errors()}
  def parse_options(args, switches, default_opts \\ []) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: switches)
    default_opts            = to_map(default_opts)
    opts                    = to_map(opts)
    config                  =
      default_opts
      |> Map.merge(opts)
      |> context_app_to_atom()

    {config, parsed, invalid}
  end

  defp context_app_to_atom(%{context_app: context_app} = config),
    do: Map.put(config, :context_app, String.to_atom(context_app))
  defp context_app_to_atom(config),
    do: config
end
