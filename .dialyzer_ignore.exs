[
  # Suppressions for known Dialyzer warnings.
  # Format per entry:
  #   {"path/to/file.ex"}                    — all warnings in file
  #   {"path/to/file.ex", :warning_category} — specific category in file
  #   {"path/to/file.ex", :category, line}   — specific line + category
  #   ~r/regex/                              — regex match on warning text
  #
  # Run `mix dialyzer` to see current warnings; `list_unused_filters: true`
  # in mix.exs will flag entries here that no longer match anything.
]
