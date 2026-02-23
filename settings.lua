data:extend({
  {
    type = "bool-setting",
    name = "sbhli-balanced-unlock",
    setting_type = "startup",
    default_value = false,
    order = "a"
  },
  {
    type = "int-setting",
    name = "sbhli-stack-size-offset",
    setting_type = "startup",
    default_value = 4,
    minimum_value = 0,
    maximum_value = 50,
    order = "b"
  }
})
