// Hammerspoon Lua extension for moving windows between macOS Spaces.
//
// SkyLight is a private framework, so load it at runtime. The bridged window
// management operation works for foreign windows without disabling SIP on
// macOS Tahoe. Its completion is asynchronous, so verify the destination
// before reporting success to Lua.

#import <Foundation/Foundation.h>

#include <dlfcn.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <unistd.h>

#include "lua.h"
#include "lauxlib.h"

typedef int CGSConnectionID;
typedef uint64_t CGSSpaceID;

static int (*p_SLSMainConnectionID)(void);
static CFArrayRef (*p_SLSCopySpacesForWindows)(
    CGSConnectionID, int, CFArrayRef);
static int (*p_SLSProcessAssignToSpace)(
    CGSConnectionID, pid_t, CGSSpaceID);

static int load_symbols(lua_State *L) {
    if (p_SLSMainConnectionID && p_SLSCopySpacesForWindows) return 0;

    void *handle = dlopen(
        "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight",
        RTLD_LAZY);
    if (!handle) {
        return luaL_error(L, "dlopen SkyLight failed: %s", dlerror());
    }

    p_SLSMainConnectionID = dlsym(handle, "SLSMainConnectionID");
    p_SLSCopySpacesForWindows =
        dlsym(handle, "SLSCopySpacesForWindows");
    p_SLSProcessAssignToSpace =
        dlsym(handle, "SLSProcessAssignToSpace");

    if (!p_SLSMainConnectionID || !p_SLSCopySpacesForWindows) {
        return luaL_error(L, "dlsym failed: missing SkyLight symbol");
    }
    return 0;
}

static CFArrayRef array_with_window_id(uint32_t window_id) {
    CFNumberRef number = CFNumberCreate(
        NULL, kCFNumberSInt32Type, &window_id);
    const void *values[] = {number};
    CFArrayRef result = CFArrayCreate(
        NULL, values, 1, &kCFTypeArrayCallBacks);
    CFRelease(number);
    return result;
}

static bool window_is_on_space(
    CGSConnectionID connection, uint32_t window_id, CGSSpaceID space_id) {
    CFArrayRef windows = array_with_window_id(window_id);
    CFArrayRef spaces =
        p_SLSCopySpacesForWindows(connection, 0x7, windows);
    CFRelease(windows);
    if (!spaces) return false;

    bool found = false;
    CFIndex count = CFArrayGetCount(spaces);
    for (CFIndex index = 0; index < count; ++index) {
        CFNumberRef number = CFArrayGetValueAtIndex(spaces, index);
        CGSSpaceID candidate = 0;
        if (CFNumberGetValue(
                number, kCFNumberSInt64Type, &candidate) &&
            candidate == space_id) {
            found = true;
            break;
        }
    }
    CFRelease(spaces);
    return found;
}

static int l_move_window_to_space(lua_State *L) {
    uint32_t window_id = (uint32_t)luaL_checkinteger(L, 1);
    CGSSpaceID space_id = (CGSSpaceID)luaL_checkinteger(L, 2);
    load_symbols(L);

    CGSConnectionID connection = p_SLSMainConnectionID();
    if (window_is_on_space(connection, window_id, space_id)) {
        lua_pushboolean(L, true);
        return 1;
    }

    Class operation_class =
        objc_getClass("SLSBridgedMoveWindowsToManagedSpaceOperation");
    SEL initializer = sel_registerName("initWithWindows:spaceID:");
    SEL performer = sel_registerName("performWithWMBridgeDelegate");
    if (!operation_class ||
        !class_getInstanceMethod(operation_class, initializer) ||
        !class_getInstanceMethod(operation_class, performer)) {
        lua_pushboolean(L, false);
        lua_pushliteral(
            L, "bridged window-to-Space API is unavailable on this macOS");
        return 2;
    }

    CFArrayRef windows = array_with_window_id(window_id);
    id operation = ((id (*)(id, SEL, id, uint64_t))objc_msgSend)(
        [operation_class alloc],
        initializer,
        (id)windows,
        space_id);
    if (!operation) {
        CFRelease(windows);
        lua_pushboolean(L, false);
        lua_pushliteral(L, "could not create bridged window operation");
        return 2;
    }

    ((void (*)(id, SEL))objc_msgSend)(operation, performer);
    [operation release];
    CFRelease(windows);

    // WindowServer normally finishes in a few milliseconds. Poll for up to
    // one second because the bridge has no public completion callback.
    for (int attempt = 0; attempt < 20; ++attempt) {
        usleep(50000);
        if (window_is_on_space(connection, window_id, space_id)) {
            lua_pushboolean(L, true);
            return 1;
        }
    }

    char error[160];
    snprintf(
        error,
        sizeof(error),
        "WindowServer did not move window %u to Space %llu",
        window_id,
        (unsigned long long)space_id);
    lua_pushboolean(L, false);
    lua_pushstring(L, error);
    return 2;
}

// Retained for compatibility with older config, but not used by the hotkeys.
static int l_move_process_to_space(lua_State *L) {
    pid_t pid = (pid_t)luaL_checkinteger(L, 1);
    CGSSpaceID space_id = (CGSSpaceID)luaL_checkinteger(L, 2);
    load_symbols(L);
    if (!p_SLSProcessAssignToSpace) {
        return luaL_error(
            L, "dlsym failed: missing SLSProcessAssignToSpace");
    }

    int result =
        p_SLSProcessAssignToSpace(p_SLSMainConnectionID(), pid, space_id);
    lua_pushinteger(L, result);
    return 1;
}

static const luaL_Reg functions[] = {
    {"moveWindowToSpace", l_move_window_to_space},
    {"moveProcessToSpace", l_move_process_to_space},
    {NULL, NULL},
};

int luaopen_hackmac_hs(lua_State *L) {
    luaL_newlib(L, functions);
    return 1;
}
