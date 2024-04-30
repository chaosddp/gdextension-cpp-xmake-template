-- TODO:
-- 1. support other platforms
-- 2. switch optimization level
-- 3. refine the run command, as it currently run the project by default, maybe start a demo scene or a specified scene?

------- basic custom config part -------

-- project name
PROJECT_NAME = "gdexample"

-- project version
VERSION = "0.0.1"

-- godot project folder, this will be used as export name, so be careful to make sure it is a valid name
GODOT_PROJECT_FOLDER = "demo"

-- publish folder, the exported files will be put here
PUBLISH_FOLDER = "publish"


------- project settings -------

-- project name
set_project(PROJECT_NAME)

-- project version
set_version(VERSION)

-- min version of xmake we need to run
-- NOTE: this is the version i used to develop this template, may not 100% correct
set_xmakever("2.9.0")

add_rules("mode.debug", "mode.release")

-- c++17 is required for godot 4.x, we use c++20 here
set_languages("cxx20")

-- we use a private repo here to maintain the godot4 package
add_repositories("my-repo repo")

-- use latest 4.x version by default
add_requires("godot4")


------- custom tasks -------


-- NOTE:
-- xmake cannot accept the global variables in on_xxx functions, so we use a wrapper function to bind it

-- export specified godot project, with the export execution name
-- args:
--  target_platform: the target platform, like "Windows Desktop"
--  name: the export execute name, it will be endswith ".exe" on windows
task("export")
    on_run((function(godot_project_folder, publish_folder) 
        return function(target_platform)
            local name = godot_project_folder
            
            -- different platform may have different execute name
            -- xmake supported platforms:
            -- windows
            -- cross
            -- linux
            -- macosx
            -- android
            -- iphoneos
            -- watchos
            if is_plat("windows") then
                name = name .. ".exe"
            end

            local export_mode = "export-debug"

            if is_mode("release") then
                export_mode = "export-release"
            end

            if not os.isdir(publish_folder) then
                os.mkdir(publish_folder)
            end

            local godot_project_file = path.join(godot_project_folder, "project.godot")

            local export_path = path.absolute(path.join(publish_folder, name))

            os.run("godot %s --headless --%s %s %s", godot_project_file, export_mode, target_platform, export_path)
        end
    
    end)(GODOT_PROJECT_FOLDER, PUBLISH_FOLDER))
task_end()

-- clean the publish folder and build folder
task("clean-publish")
    on_run((function(godot_project_folder, publish_folder)
        return function ()
            -- remove publish folder
            if os.isdir(publish_folder) then
                os.tryrm(publish_folder)
            end

            -- remove build target folder
            local bin_dir = path.join(godot_project_folder, "bin")
            if os.isdir(bin_dir) then
                os.tryrm(path.join(bin_dir, "$(os)"))
            end
        end
    end)(GODOT_PROJECT_FOLDER, PUBLISH_FOLDER))
task_end()


-- tasks that exposed to cli
-- NOTE: for complex tasks, we can use a seprate file to define it

-- generate a class that inherit from godot class
-- args:
--   name: the new class name
--   basename: the base class name to inherit (must under godot_cpp/classes)
--   dir: the directory to save the class (must under src)
--   namespace: the namespace of the new class

task("ext-class")
    on_run(function ()
        -- more on: https://xmake.io/#/manual/plugin_task
        -- we need this module to load options from menu
        import "core.base.option"

        local namespace = option.get("namespace")
        local name = option.get("name")
        local base = option.get("base")
        local dir = option.get("dir")

        -- we calculate these here, in case there is any special case to handle
        local header_guard = string.upper(name) .. "_H"

        import("class_tpl", {rootdir="templates", alias="class_render"})

        -- header and impl text
        local header_text = class_render.render_header(header_guard, namespace, name, base)
        local impl_text = class_render.render_impl(namespace, name)

        -- save
        local output_dir = "src"

        if dir ~= nil then
            output_dir = path.join("src", dir)
        end

        if not os.isdir(output_dir) then
            os.mkdir(output_dir)
        end

        local header_file = path.join(output_dir, string.lower(name) .. ".h")
        local impl_file = path.join(output_dir, string.lower(name) .. ".cpp")

        io.writefile(header_file, header_text)
        io.writefile(impl_file, impl_text)

    end)

    -- options 
    set_menu {
        usage = "xmake ext-class [options]",

        description = "Generate godot class that inherits from a base class under godot_cpp/classes",

        options = {

            -- kv options
            -- (short, long), (kv, default_value), description, [values])
            {"s", "namespace",    "kv", "godot",  "Set the namespace of the new class"},
            {"d", "dir",          "kv", nil,      "Set the directory to save the class"},

            {},

            -- single value options
            {"n", "name",         "v", nil,       "Set the new class name"},
            {"b", "base",         "v", nil,       "Set the base class name to inherit"},
        }
    }
task_end() 


------- output settings -------

-- more on https://xmake.io/#/manual/project_target
target(PROJECT_NAME)
    set_kind("shared")

    add_packages("godot4")

    -- more on https://xmake.io/#/manual/project_target?id=targetadd_files
    add_files("src/*.cpp")

    -- change the output name
    set_basename(PROJECT_NAME .. "_$(mode)_$(arch)")

    -- libraries will saved in os level folder
    set_targetdir(GODOT_PROJECT_FOLDER .. "/bin/$(os)")

    -- where to save .obj files
    -- we use a seprate folder, so that it will not populate the targer folder
    set_objectdir("build/.objs")

    -- where .d files are saved
    set_dependir("build/.deps")

    -- set_optimize("smallest")

    -- handlers

    -- before_run(function (target)  end)
    -- after_run(function (target)  end)
    -- before_build(function (target)  end)
    -- after_build(function (target)  end)
    -- before_clean(function (target)  end)
    -- after_clean(function (target)  end)

    on_run(
        (function(godot_project_folder)
            return function(target)
                os.run("godot --path " .. godot_project_folder)
            end
        end)(GODOT_PROJECT_FOLDER)
    )

    on_package(function(target)
        import("core.base.task")

        target_platform = "\"Windows Desktop\""

        if is_plat() == "macosx" then
            -- target_platform = "Mac OS"
        elseif is_plat() == "linux" then
            -- target_platform = "Linux/X11"
        end

        task.run("export", {}, target_platform)
    end)

    after_clean(function (target) 
        import("core.base.task")
        task.run("clean-publish")
    end)
