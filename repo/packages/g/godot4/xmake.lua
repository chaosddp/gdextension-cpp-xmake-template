package("godot4")
    set_homepage("https://github.com/godotengine/godot")
    set_description("The godot4 package")

    add_urls("https://github.com/godotengine/godot/archive/refs/tags/4.2.2-stable.tar.gz")
    add_versions("4.2.2", "990b7b716656122364b1672508c516c898497c50216d7c00c60eeaf507685c0e")

    on_install(function (package)
        -- local configs = {}
        -- if package:config("shared") then
        --     configs.kind = "shared"
        -- end
        -- import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)
