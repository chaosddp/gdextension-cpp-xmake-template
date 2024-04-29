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

-- export specified godot project, with the export execution name
-- args:
--  target_platform: the target platform, like "Windows Desktop"
--  name: the export execute name, it will be endswith ".exe" on windows
task("export")
    on_run((function(godot_project_folder, publish_folder) 
        return function(target_platform)
            local name = godot_project_folder

            if is_plat() == "windows" then
                name = name .. ".exe"
            end

            if not os.isdir(publish_folder) then
                os.mkdir(publish_folder)
            end

            local godot_project_file = path.join(godot_project_folder, "project.godot")

            local export_path = path.absolute(path.join(publish_folder, name))

            os.run("godot %s --headless --export-debug %s %s", godot_project_file, target_platform, export_path)
        end
    
    end)(GODOT_PROJECT_FOLDER, PUBLISH_FOLDER))
task_end()

task("clean-publish")
    on_run((function(godot_project_folder, publish_folder)
        return function ()
            if os.isdir(publish_folder) then
                os.tryrm(publish_folder)
            end

            local bin_dir = path.join(godot_project_folder, "bin")
            if os.isdir(bin_dir) then
                os.tryrm(path.join(bin_dir, "$(os)"))
            end
        end
    end)(GODOT_PROJECT_FOLDER, PUBLISH_FOLDER))
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

    -- NOTE:
    -- xmake cannot accept the global variables, so we use a wrapper function to provide it
    on_run(
        (function(godot_project_folder)
            return function(target)
                os.run("godot --path " .. godot_project_folder)
            end
        end)(GODOT_PROJECT_FOLDER)
    )

    on_package(function(target)
        import("core.base.task")

        -- TODO: support other platform
        -- TODO: support --export-release on release
        if  not os.isdir("publish") then
          os.mkdir("publish")
        end 

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
        task.run("clean-publish", {})
    end)
