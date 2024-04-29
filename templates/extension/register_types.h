#ifndef {ClassName.upper()}_REGISTER_TYPES_H
#define {ClassName.upper()}_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void initialize_{ClassName.lower()}_module(ModuleInitializationLevel p_level);
void uninitialize_{ClassName.lower()}_module(ModuleInitializationLevel p_level);

#endif