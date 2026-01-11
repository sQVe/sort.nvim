--- @class Config
--- @field public delimiters string[]
--- @field public keymap string
--- @field public mappings table
--- @field public natural_sort boolean
--- @field public ignore_case boolean
--- @field public unique boolean

--- @class SelectionFragment
--- @field public row integer
--- @field public column integer

--- @class Selection
--- @field public from SelectionFragment
--- @field public to SelectionFragment

--- @class SortOptions
--- @field public delimiter? string
--- @field public ignore_case boolean
--- @field public numerical? integer
--- @field public reverse boolean
--- @field public unique boolean
--- @field public natural boolean
