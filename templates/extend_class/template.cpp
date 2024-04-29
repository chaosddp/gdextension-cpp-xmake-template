
#include "{ClassName.lower()}.h"

using namespace godot;

void {ClassName}::_bind_methods() {
    // bind your own methods here, like
    // ClassDB::bind_method(D_METHOD("my_foo", "delta"), &{ClassName}::my_foo);
}

{ClassName}::{ClassName}()
{
    // initialize here
}

{ClassName}::~{ClassName}() {}

void {ClassName}::_process(float delta)
{
    // do update here
}