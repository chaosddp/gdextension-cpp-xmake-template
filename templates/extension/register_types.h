#ifndef {ProjectName.upper()}_REGISTER_TYPES_H
#define {ProjectName.upper()}_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void initialize_{ProjectName.lower()}_module(ModuleInitializationLevel p_level);
void uninitialize_{ProjectName.lower()}_module(ModuleInitializationLevel p_level);

#endif