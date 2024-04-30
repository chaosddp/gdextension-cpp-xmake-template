--[[
    #ifndef $(HEADER_GUARD)
    #define $(HEADER_GUARD)

    #include <godot_cpp/classes/$(BASECLASS_HEADER_NAME).hpp>

    namespace $(NAMESPACE)
    {
        class $(CLASS_NAME) : public godot::$(BASE_CLASS)
        {
            GDCLASS($(CLASS_NAME), godot::$(BASE_CLASS)
            
        protected:
            static void _bind_methods();

        public:
            $(CLASS_NAME)();
            ~$(CLASS_NAME)();

            void _process(float delta);
        };
    }
    #endif

]]

function render_header(header_guard, namespace, class_name, base_class)
    local template = {
        string.format("#ifndef %s", header_guard),
        string.format("#define %s", header_guard),
        string.format("#include <godot_cpp/classes/%s.hpp>", string.lower(base_class)),
        string.format("namespace %s", namespace),
        "{",
        string.format("    class %s : public godot::%s", class_name, base_class),
        "    {",
        string.format("        GDCLASS(%s, godot::%s)", class_name, base_class),
        "    protected:",
        string.format("        static void _bind_methods();"),
        string.format("    public:"),
        string.format("        %s();", class_name),
        string.format("        ~%s();", class_name),
        string.format("        void _process(float delta);"),
        "    };",
        "}",
        "#endif",
    }

    return table.concat(template, "\n")
end

--[[
    
#include "{% echo(" " .. string.lower(ClassName)) %}.h"

using namespace {*Namespace*};

void {*ClassName*}::_bind_methods() {
    // bind your own methods here, like
    // ClassDB::bind_method(D_METHOD("my_foo", "delta"), &{ClassName}::my_foo);
}

{*ClassName*}::{*ClassName*}()
{
    // initialize here
}

{*ClassName*}::~{*ClassName*}() {}

void {*ClassName*}::_process(float delta)
{
    // do update here
}
]]

function render_impl(namespace, classname)
    local template = {
        string.format("#include \"%s.h\"", string.lower(classname)),
        string.format("using namespace %s;", namespace),
        "",
        string.format("void %s::_bind_methods()", classname),
        "{",
        "    // bind your own methods here, like",
        string.format("    // ClassDB::bind_method(D_METHOD(\"my_foo\", \"delta\"), &%s::my_foo);", classname),
        "}",
        "",
        string.format("%s::%s()", classname, classname),
        "{",
        "    // initialize here",
        "}",
        "",
        string.format("%s::~%s()", classname, classname),
        "{",
        "    // do clean up here",
        "}",
        "",
        string.format("void %s::_process(float delta)", classname),
        "{",
        "    // do update here",
        "}"
    }

    return table.concat(template, "\n")
end