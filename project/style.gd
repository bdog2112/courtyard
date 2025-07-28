extends Node

# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#code-order
# We suggest to organize GDScript code this way:
#
# 01. @tool
# 02. class_name
# 03. extends
# 04. # docstring
#
# 05. signals
# 06. enums
# 07. constants
# 08. @export variables
# 09. public variables
# 10. private variables
# 11. @onready variables
#
# 12. optional built-in virtual _init method
# 13. optional built-in virtual _enter_tree() method
# 14. built-in virtual _ready method
# 15. remaining built-in virtual methods
# 16. public methods
# 17. private methods
# 18. subclasses
#
# We optimized the order to make it easy to read the code from top to bottom, to
# help developers reading the code for the first time understand how it works,
# and to avoid errors linked to the order of variable declarations.
#
# This code order follows four rules of thumb:
# 1 Properties and signals come first, followed by methods.
# 2 Public comes before private.
# 3 Virtual callbacks come before the class's interface.
# 4 The object's construction and initialization functions, _init and _ready,
#   come before functions that modify the object at runtime.
