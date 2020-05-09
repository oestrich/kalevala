alias Kalevala.Output

import Kalevala.Character.View.Macro

output_processors = [
  Output.Tags,
  Output.Tables,
  Output.TagColors,
  Output.StripTags
]

vitals = %{
  health_points: 50,
  max_health_points: 50,
  skill_points: 50,
  max_skill_points: 50,
  endurance_points: 50,
  max_endurance_points: 50,
}

tables = fn ->
  text = ~i"""
  {table}
    {row}
      {cell}Eric The Alchemist{/cell}
    {/row}
    {row}
      {cell}HP{/cell}
      {cell}{hp}#{vitals.health_points}/#{vitals.max_health_points}{/hp}{/cell}
    {/row}
    {row}
      {cell}SP{/cell}
      {cell}{sp}#{vitals.skill_points}/#{vitals.max_skill_points}{/sp}{/cell}
    {/row}
    {row}
      {cell}EP{/cell}
      {cell}{ep}#{vitals.endurance_points}/#{vitals.max_endurance_points}{/ep}{/cell}
    {/row}
  {/table}
  """

  Enum.reduce(output_processors, text, fn processor, text ->
    Output.process(text, processor)
  end)
end

coloring = fn ->
  text = ~i"""
  {color foregorund="red"}#{vitals.health_points}/#{vitals.max_health_points}{/color}
  {color foregorund="blue"}#{vitals.skill_points}/#{vitals.max_skill_points}{/color}
  {color foregorund="purple"}#{vitals.endurance_points}/#{vitals.max_endurance_points}{/color}
  """

  Enum.reduce(output_processors, text, fn processor, text ->
    Output.process(text, processor)
  end)
end

Benchee.run(%{
  "colors" => coloring,
  "tables" => tables
})
