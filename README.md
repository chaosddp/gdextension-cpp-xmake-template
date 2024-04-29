# godotcpp4-xmake-template

This project is used to compile a GDExtension, and try to use xmake to manage the project.

It is mainly for learning purpose.

## Install xmake

Install xmake from [here](https://xmake.io/#/zh-cn/guide/installation).

## How to use

First modify the *xmake.lua* to change the project name, and other configurations as needed.

```lua

-- project name, this will be the output shared library name
PROJECT_NAME = "gdexample"

-- project version
VERSION = "0.0.1"

-- where is the godot project saved, default is "demo"
GODOT_PROJECT_FOLDER = "demo"

-- where to save the export project, default is "publish"
PUBLISH_FOLDER = "publish"

```

After change the configurations, you can run the following commands to build, run and export.

```sh

# 1. build the project
xmake build

# 2. run the demo
xmake run

# 3. export the project
xmake pack

# 4. clean the build and publish
xmake clean


```