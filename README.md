# About

Gobl utilities for dart and flutter project.

# Notes

To prevent conflict between:

-   entity class property name and column magic getter and setter
-   entity class method and column method (getter and setter)

We only use:

-   a prefix with a single `_` for property
-   camelCase method name avoiding prefixing with `get` or `set`

So don't use: `getSomething`, `setSomething` or `our_property`

Use instead: `_getSomething`, `_setSomething`, `doSomething` or `_our_property`
