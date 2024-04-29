#ifndef {ClassName.upper()}_H
#define {ClassName.upper()}_H

#include <godot_cpp/classes/{BaseClass.lower()}.hpp>

namespace godot
{
    class {ClassName.lower()} : public {BaseClass}
    {
        GDCLASS({ClassName}, {BaseClass})

    protected:
        static void _bind_methods();

    public:
        {ClassName}();
        ~{ClassName}();

        void _process(float delta);
    };
}
#endif