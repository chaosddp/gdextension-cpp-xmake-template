#include "register_types.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_{ProjectName.lower()}_module(ModuleInitializationLevel p_level)
{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
    {
        return;
    }

    // register more class here, like below:
    // ClassDB::register_class<MyClass>();
}

void uninitialize_{ProjectName.lower()}_module(ModuleInitializationLevel p_level)
{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
    {
        return;
    }
}

extern "C"
{
    GDExtensionBool GDE_EXPORT {ProjectName.lower()}_library_init(
        GDExtensionInterfaceGetProcAddress p_get_proc,
        const GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization *r_initialization)
    {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc, p_library, r_initialization);

        init_obj.register_initializer(initialize_{ProjectName.lower()}_module);
        init_obj.register_terminator(uninitialize_{ProjectName.lower()}_module);
        init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

        return init_obj.init();
    }
}