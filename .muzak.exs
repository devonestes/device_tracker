# Muzak uses different configuration profiles to allow you to use it in different ways (like
# in CI versus run locally by a developer). The `default` and `ci` profiles below should be
# a good starting point for most applications.
#
%{
  default: [
    # You can run your mutation tests in parallel in multiple independent BEAM nodes if you
    # like. This can offer some decrease in runtime, but the need for most applications this
    # will offer at most a 20% decrease in runtime and will be very difficult to set up
    # properly.
    #
    nodes: 1,

    # To speed things up, you have the option of controlling which files, and which lines in
    # those files, will be mutated in any given run.
    #
    # The files passed to this function are the files in the `elixirc_paths` field in your
    # application configuration.
    #
    # This function must return a list of tuples, where the first element in the tuple is the
    # path to the file, and the second element is `nil` or a list of integers representing line
    # numbers.
    #
    #   - `{"path/to/file.ex", nil}` will make all possible mutations on all lines in the file.
    #   - `{"path/to/file.ex", [1, 2, 3]}` will make all possible mutations but only on lines
    #     1, 2 and 3 in the file.
    #
    mutation_filter: fn all_files ->
      all_files
      |> Enum.reject(&String.starts_with?(&1, "test/"))
      |> Enum.filter(&String.ends_with?(&1, ".ex"))
      |> Enum.map(&{&1, nil})
    end,

    # If you would like to run fewer tests for each run, or run them in a certain order, you
    # can filter and order your test files here. Ordering your test files can lead to a
    # decrease in runtime, as each run ends at the first test failure.
    #
    test_file_filter: fn files ->
      files
    end
  ],
  ci: [
    nodes: 1,

    # This will only mutate the lines that have changed since the last commit by a different
    # author. This will be an effective way to speed up execution and gradually introduce
    # mutation testing to the team's workflow, regardless of if the team is using merge
    # commits or not.
    #
    # This depends on `git` being available as a command on whichever system this task is
    # being run.
    #
    mutation_filter: fn _ ->
      split_pattern = ";;;"

      {commits_and_authors, 0} =
        System.cmd("git", [
          "log",
          "--pretty=format:%C(auto)%h#{split_pattern}%an",
          "--date-order",
          "-20"
        ])

      last_commit_by_a_different_author =
        commits_and_authors
        |> String.split("\n")
        |> Enum.map(&String.split(&1, split_pattern))
        |> Enum.reduce_while(nil, fn
          [_, author], nil -> {:cont, author}
          [_, author], author -> {:cont, author}
          [commit, _], _ -> {:halt, commit}
        end)

      {diff, 0} = System.cmd("git", ["diff", "-U0", last_commit_by_a_different_author])

      # All of this is to parse the git diff output to get the correct files and line numbers
      # that have changed in the given diff since the last commit by a different author.
      first = ~r|---\ (a/)?.*|
      second = ~r|\+\+\+\ (b\/)?(.*)|
      third = ~r|@@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.*|
      fourth = ~r|^(\[[0-9;]+m)*([\ +-])|

      diff
      |> String.split("\n")
      |> Enum.reduce({nil, nil, %{}}, fn line, {current_file, current_line, acc} ->
        cond do
          String.match?(line, first) ->
            {current_file, current_line, acc}

          String.match?(line, second) ->
            current_file = second |> Regex.run(line) |> Enum.at(2)
            {current_file, nil, acc}

          String.match?(line, third) ->
            current_line = third |> Regex.run(line) |> Enum.at(2) |> String.to_integer()
            {current_file, current_line, acc}

          current_file == nil ->
            {current_file, current_line, acc}

          match?([_, _, "+"], Regex.run(fourth, line)) ->
            acc = Map.update(acc, current_file, [current_line], &[current_line | &1])
            {current_file, current_line + 1, acc}

          true ->
            {current_file, current_line, acc}
        end
      end)
      |> elem(2)
      |> Enum.reject(fn {file, _} -> String.starts_with?(file, "test/") end)
      |> Enum.filter(fn {file, _} -> String.ends_with?(file, ".ex") end)
    end,
    test_file_filter: fn files ->
      files
    end
  ]
}
