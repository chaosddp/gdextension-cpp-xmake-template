-- TODO:
-- 1. support other platforms
-- 2. switch optimization level
-- 3. refine the run command, as it currently run the project by default, maybe start a demo scene or a specified scene?

-- project name
PROJECT_NAME = "gdexample"
-- project version
VERSION = "0.0.1"
-- godot project folder, this will be used as export name, so be careful to make sure it is a valid name
GODOT_PROJECT_FOLDER = "demo"
PUBLISH_FOLDER = "publish"

-- os.setenv("PROJECT_NAME", PROJECT_NAME)
-- os.setenv("VERSION", VERSION)
-- os.setenv("GODOT_PROJECT_FOLDER", GODOT_PROJECT_FOLDER)

-- project name
set_project(PROJECT_NAME)

-- project version
set_version(VERSION)

-- set_config("buildir", GODOT_PROJECT_FOLDER .. "/bin/")

-- min version of xmake we need to run
set_xmakever("2.9.0")

add_rules("mode.debug", "mode.release")

-- c++17 is required for godot 4.x, we use c++20 here
set_languages("cxx20")

-- we use a private repo here
add_repositories("my-repo repo")

-- use latest 4.x version
add_requires("godot4")

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

-- generate godot class or extension entrypoint
-- args:
--   name: the new class name
--   basename: the base class name to inherit (must under godot_cpp/classes)
--   dir: the directory to save the class (must under src)
task("gen-class")
    on_run(function (name, basename, dir)
        -- TODO: generate the class here
    end)
task_end() 

task("gen-entry")
    on_run(function () 
        -- TODO: generate the entrypoint here (register_types.h/cpp)
        local project_name = PROJECT_NAME
    end)
task_end()

-- what we want to export
target(PROJECT_NAME)
    set_kind("shared")

    add_packages("godot4")

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
