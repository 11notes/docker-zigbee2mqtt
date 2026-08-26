#ifndef BUILDING_NODE_EXTENSION
#define BUILDING_NODE_EXTENSION 1
#endif

#ifndef NODE_WANT_INTERNALS
#define NODE_WANT_INTERNALS 1
#endif

#ifndef NODE_ADDON_API_ENABLE_CPP_EXCEPTIONS
#define NODE_ADDON_API_ENABLE_CPP_EXCEPTIONS 1
#endif

#include "serialport.h"

#include "v8.h"
#include "node.h"
#include "node_binding.h"
#include "node_internals.h"
#include "node_api.h"
#include <napi.h>

Napi::Object init(Napi::Env env, Napi::Object exports);

static void InitStaticSerialport(v8::Local<v8::Object> exports,
                                 v8::Local<v8::Value> module,
                                 v8::Local<v8::Context> context,
                                 void* priv) {
  static napi_module _module = {
    NAPI_MODULE_VERSION,
    0,
    __FILE__,
    [](napi_env env, napi_value exports_val) -> napi_value {
      Napi::Env napiEnv(env);
      Napi::Object napiExports(napiEnv, exports_val);
      return init(napiEnv, napiExports);
    },
    "serialport_bindings",
    priv,
    {0},
  };

  napi_module_register(&_module);
}

static node::node_module _static_serialport_module = {
  NODE_MODULE_VERSION,
  NM_F_LINKED,
  nullptr,
  __FILE__,
  nullptr,
  InitStaticSerialport,
  "serialport_bindings",
  nullptr,
  nullptr
};

static void __attribute__((constructor)) RegisterSerialportModule() {
  node::node_module_register(&_static_serialport_module);
}
