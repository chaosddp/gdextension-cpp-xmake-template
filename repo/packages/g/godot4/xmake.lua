package("godot4")

    set_homepage("https://godotengine.org/")
    set_description("C++ bindings for the Godot 4 script API")

    set_urls("https://github.com/godotengine/godot-cpp.git")

    add_versions("4.2.2", "98c143a48365f3f3bf5f99d6289a2cb25e6472d1")
    add_versions("4.1.4", "4b0ee133274d67687b6003b8d5fdaf7b79cf4921")
    add_versions("4.0.4", "2fdac1c9a9d2ea14a6be4785ec7e79762d94bb3f")

    add_deps("scons")
    add_includedirs("gen/include", "include")

    on_load(function(package)
        assert(not package:is_arch(
                "mips",
                "mip64",
                "mips64",
                "mipsel",
                "mips64el",
                "s390x",
                "sh4"),
                "architecture " .. package:arch() .. " is not supported")

        if package:is_plat("windows") then
            package:add("defines", "TYPED_METHOD_BIND", "NOMINMAX")
        end
        if package:is_debug() then
            package:add("defines", "DEBUG_ENABLED", "DEBUG_METHODS_ENABLED")
        end
    end)

    on_install("linux", "windows|x64", "windows|x86", "macosx", "iphoneos", "android", function(package)
        if package:is_plat("windows") then
            if package:version() < "4.1.0" then 
                io.replace("tools/targets.py", "/MD", "/" .. package:config("vs_runtime"), {plain = true})
            else
                io.replace("tools/common_compiler_flags.py", "/MD", "/" .. package:config("vs_runtime"), {plain = true})
            end
        end

        local platform = package:plat()
        if package:is_plat("mingw") then
            platform = "windows"
        elseif package:is_plat("macosx") then
            platform = "macos"
        elseif package:is_plat("iphoneos") then
            platform = "ios"
        end

        local arch = package:arch()
        if package:is_arch("x86", "i386") then
            arch = "x86_32"
        elseif package:is_arch("arm64-v8a") then
            arch = "arm64"
        elseif package:is_arch("arm", "armeabi", "armeabi-v7a", "armv7s", "armv7k") then
            arch = "arm32"
        end

        local configs = {
            "target=" .. (package:is_debug() and "template_debug" or "template_release"),
            "platform=" .. platform,
            "arch=" .. arch,
            "debug_symbols=" .. (package:is_debug() and "yes" or "no")
        }

        import("package.tools.scons").build(package, configs)
        os.cp("bin/*." .. (package:is_plat("windows") and "lib" or "a"), package:installdir("lib"))
        os.cp("include/godot_cpp", package:installdir("include"))
        os.cp("gen/include/godot_cpp", path.join(package:installdir("gen"), "include", "godot_cpp"))
        os.cp("gdextension/gdextension_interface.h", package:installdir("include"))
    end)

    on_test(function (package)
        -- test for different version
    end)
