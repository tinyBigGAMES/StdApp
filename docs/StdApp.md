![StdApp](../media/logo.png)


## 1. Overview

StdApp is a standalone Delphi component library providing foundation services for Win64 applications. It is designed to be shared across multiple projects without modification -- every project `uses` StdApp units directly with no project-specific prefixes or renaming.

Design philosophy:

- **Minimal dependencies** -- most units depend only on WinApi and System. StdApp.VMM has zero dependencies (no uses clause at all).
- **Self-contained** -- the library includes its own memory manager, DLL loader, virtual file system, JSON handler, resource compiler, console I/O, and test framework. No third-party packages required.
- **Modern Delphi** -- uses generics, advanced records, anonymous methods (`reference to`), string helpers, and TPath throughout. No legacy Pascal patterns.
- **Win64 only** -- enforced at compile time via StdApp.Defines.inc. No cross-platform abstraction layers.

All classes descend from `TBaseObject` (defined in StdApp.Base.pas), which provides a shared error system (`TErrors`), status callbacks, and virtual configuration hooks.

---

## 2. Unit Reference

### StdApp.Base

Foundation types and base class for the entire library.

Defines `TBaseObject`, the mandatory base class for all StdApp and project classes. Every class inherits a shared error system (`TErrors`) with severity levels, source location tracking, max-error cutoff, and optional raise-on-error behavior. Also provides the generic `TCallback<T>` wrapper for pairing a callback reference with user data, and `TSourceRange` for file/line/column tracking.

Key types: `TBaseObject`, `TErrors`, `TError`, `TErrorSeverity`, `TSourceRange`, `TCallback<T>`, `EStdAppException`.

Dependencies: `StdApp.Resources`

---

### StdApp.Console

ANSI terminal output and input.

Static class providing colored console I/O via ANSI escape sequences. Includes text output (Print/PrintLn), cursor movement and visibility control, terminal size queries, horizontal rules, progress bars, spinners, and raw key input. All output is guarded by `HasConsole()` so GUI applications silently skip console calls.

Key types: `TConsole` (static class), ANSI color/style/background constants (`COLOR_*`, `STYLE_*`, `BG_*`).

Dependencies: none

Notes: Requires Windows Virtual Terminal Processing, which is enabled automatically by `StdApp.Utils.InitConsole()`.

---

### StdApp.Console.Menu

Interactive console menu system.

Fluent-API menu builder for console applications. Supports nested submenus, configurable colors (title, items, numbers, separators, errors, prompt), multi-column layout for long menus, and separator items. Integrates directly with `TTestCase` and `TTestDemo` classes -- `AddTestCase()` creates a submenu with run-all and per-test options automatically.

Key types: `TConsoleMenu`, `TMenuItem`, `TMenuItemKind`.

Dependencies: `StdApp.Base`, `StdApp.Utils`, `StdApp.Console`, `StdApp.TestCase`, `StdApp.TestDemo`

---

### StdApp.CImporter

C Header to Delphi Unit Converter.

Converts C headers into Delphi unit source code. Uses libtcc (via `StdApp.LibTCC`) for preprocessing -- expanding macros and includes -- then parses the result to generate Delphi declarations including structs, unions, enums, typedefs, function pointers, and external function bindings. Configuration is loaded/saved via JSON (`StdApp.JSON`). Resource compilation for static binding mode uses `TResourceCompiler` (`StdApp.ResCompiler`). Supports multiple binding modes: static (embedded RCDATA via `StdApp.DllLoader`), dynamic, delayed, custom handle management, and VPK-based loading via `StdApp.VFS`.

Key types: `TCImporter`, `TCLexer`, `TBindingMode`.

Dependencies: `StdApp.Base`, `StdApp.Utils`, `StdApp.JSON`, `StdApp.ResCompiler`, `StdApp.LibTCC`

Notes: Generated output units may reference `StdApp.DllLoader` and/or `StdApp.VFS` depending on the selected binding mode.

---

### StdApp.Defines.inc

Compiler directives and platform guard.

Shared include file for all StdApp units. Sets enum size to 4 bytes (`{$Z4}`), record alignment to 8 bytes (`{$A8}`), suppresses platform and deprecation warnings, enables automatic inlining (`{$INLINE AUTO}`), and enforces Win64-only compilation with a compile-time error on other platforms.

Include via `{$I StdApp.Defines.inc}` at the top of every unit.

Dependencies: none

---

### StdApp.DllLoader

In-memory PE/DLL loader.

Loads DLL images directly from memory buffers or embedded resources without writing temporary files to disk. Hooks the Windows NT loader (ntdll) to map a PE image from a memory buffer, producing a fully functional module handle with resolved imports and relocations. Supports deferred loading via `RegisterDllData()` for batch initialization with `LoadAll()`.

Key routines: `LoadLibrary(AData, ASize)`, `RegisterDllData(AModuleName, ...)`, `LoadAll()`.

Dependencies: none (WinApi and System units only)

Notes: Uses NT Native API hooking internally. Compatible with Windows 10/11 including 24H2. Supports `LOAD_FLAGS` for header erasure, PEB unlisting, and thread-call suppression.

---

### StdApp.IATHook

Import Address Table hooking.

Provides functionality to intercept Windows API calls made by a loaded DLL by patching its Import Address Table (IAT). This allows redirection of file I/O operations to serve content from embedded resources or custom handlers. Hooks are tracked in a global list and can be removed individually or all at once.

Key types: `TIATHook` (static class), `TIATHookEntry`.

Dependencies: none (WinApi and System units only)

---

### StdApp.JSON

Fluent JSON builder, reader, and writer.

Full-featured JSON manipulation class with a fluent API for building, navigating, and serializing JSON structures. Supports factory loading from files, strings, and streams. Navigation uses dot-path syntax (`Get('data.items[0].name')`). Building uses chained calls (`Add`, `BeginObject`/`EndObject`, `BeginArray`/`EndArray`). View-based design avoids deep copies during navigation -- views are lightweight wrappers over the underlying `System.JSON` tree.

Key types: `TJSON`, `TJSONEnumerator`, `TJSONPair`.

Dependencies: none (System.JSON only)

---

### StdApp.LibTCC

Self-contained TCC (Tiny C Compiler) wrapper.

Wraps libtcc.dll for runtime C compilation. The DLL is loaded from an embedded resource via `StdApp.DllLoader`, and TCC's include/lib files are served from an embedded ZIP archive via `StdApp.ZipVFS` with IAT hooking. This allows the host application to compile C code at runtime as a single self-contained executable. Enforces a strict workflow state machine (New, Configured, Compiled, Relocated, Finalized) to prevent out-of-order API calls.

Key types: `TLibTCC`, `TLibTCCOutput`, `TLibTCCSubsystem`.

Dependencies: `StdApp.Base`, `StdApp.Utils`, `StdApp.Console`

Notes: Requires `LIBTCC_DLL` and `TCC_FILES` resources embedded as `RT_RCDATA`.

---

### StdApp.ResCompiler

Windows resource (.res) compiler and reader.

Creates and parses standard Windows .res files from in-memory data. Used to embed DLLs, icons, manifests, version info, and other binary resources into executables at build time without requiring the Windows SDK resource compiler (rc.exe). The reader can parse .res files back into structured records for inspection or manipulation.

Key types: `TResourceCompiler`, `TResourceReader`, `TResourceEntry`.

Dependencies: `StdApp.Base`

---

### StdApp.Resources

Shared resource strings.

Central repository of all user-facing message strings used across StdApp units. All error messages, warning text, and format strings are declared as `resourcestring` constants for localization readiness and clean separation from logic. Organized by category: severity names, error formats, fatal/IO, VFS messages, and VirtualMemory messages.

Dependencies: none

Notes: Error code constants are defined in the unit of their concern, not here. This unit holds only the message text.

---

### StdApp.TestCase

Lightweight test framework with Section/Check pattern.

Base class for registering and running named test cases with colored console output. Tests register individual checks via `RegisterTest()`, run via `Execute()`, and report per-assertion pass/fail with automatic section numbering. Supports test filtering by name and single-test execution via class method `RunTest()`.

Key types: `TTestCase`, `TTestCaseClass`.

Dependencies: `StdApp.Base`, `StdApp.Utils`, `StdApp.Console`

Notes: Integrates with `TConsoleMenu` via `AddTestCase()` for automatic menu generation with per-test and run-all options.

---

### StdApp.TestDemo

Interactive demo framework with game-loop lifecycle.

Base class for demos and interactive examples that run a continuous update/render loop with high-resolution delta-time tracking. Subclasses override `OnSetup`/`OnShutdown`/`OnUpdate`/`OnRender` hooks. The loop runs until `Terminate()` is called.

Key types: `TTestDemo`, `TTestDemoClass`.

Dependencies: `StdApp.Base`, `StdApp.Utils`, `StdApp.Console`

Notes: Integrates with `TConsoleMenu` via `AddTestDemo()` for automatic menu registration.

---

### StdApp.Utils

General-purpose utility routines.

Static utility class covering string encoding (UTF-8, ANSI), process launching with output capture (including PTY-based capture for zig), PE file validation, version info extraction, resource manipulation (icons, manifests, version stamps, RCDATA), file encoding detection, path normalization, environment variables, and line counting. Also provides raw pointer array types for typed memory access and a fluent `TCommandBuilder` for assembling command-line strings.

Key types: `TUtils` (static class), `TCommandBuilder`, `TVersionInfo`, `TAppType`.

Dependencies: `StdApp.Base`, `StdApp.Resources`

Notes: `InitConsole()` enables Windows Virtual Terminal Processing for ANSI escape sequences and is called automatically on first console output.

---

### StdApp.VFS

Virtual file system with custom VPK archive format.

Memory-mapped virtual file system using a custom packed archive format (VPK0). Built entirely on `TVirtualMemory<Byte>` -- all memory mapping, file I/O, and buffer management are delegated to TVirtualMemory, eliminating raw OS handle management. The packer uses sparse-file-backed allocation for the archive buffer, allowing large archives with no commit charge limits. Archive reading uses file-backed read-only mapping for transparent OS paging. Entry lookup uses a dictionary for O(1) path resolution. `OpenFile` returns a `TVirtualMemoryView<Byte>` for bounds-checked, typed access.

Key types: `TVFS`, `TVFSHeader`, `TVFSEntry`.

Dependencies: `StdApp.Base`, `StdApp.Utils`, `StdApp.Resources`, `StdApp.VirtualMemory`

---

### StdApp.VirtualMemory

Virtual memory management with mapped I/O.

Provides file-backed virtual memory regions via Windows `CreateFileMapping`/`MapViewOfFile`. Anonymous allocations use sparse temp files as backing store, eliminating commit charge limits -- the OS handles paging transparently with no upfront cost. File-backed mappings support read-only, read-write, and copy-on-write modes. Includes typed generic views for structured access, a `TStream` adapter, and runtime growth for anonymous regions.

Key types: `TVirtualMemory<T>`, `TVirtualMemoryView<T>`, `TVirtualMemoryStream`, `TVirtualMemoryMode`.

Dependencies: `StdApp.Base`, `StdApp.Utils`

---

### StdApp.VMM

Zero-dependency size-class free list memory manager.

Fully self-contained Delphi memory manager replacement with absolutely no `uses` clause -- all WinAPI functions are declared directly to avoid finalization-order dependencies. Reserves a 64 GB address space via `CreateFileMapping` with `SEC_RESERVE` (no commit charge upfront), commits pages on demand in 1 MB chunks via `VirtualAlloc`, and uses 26 size classes from 16 to 65536 bytes with singly-linked free lists. Oversized allocations (> 64K) are kept whole on a separate free list for reuse. See Section 5 for detailed architecture.

Dependencies: none (fully self-contained)

Notes: Must be the FIRST unit in the .dpr `uses` clause.

---

### StdApp.ZipVFS

Virtual file system for embedded ZIP resources.

Intercepts file I/O calls from a loaded DLL (e.g., libtcc.dll) and redirects them to serve content from an embedded ZIP archive. Uses IAT hooking (`StdApp.IATHook`) to transparently replace `CreateFileW`, `ReadFile`, `CloseHandle`, `SetFilePointerEx`, `GetFileSizeEx`, `GetFileType`, and `GetFileAttributesExW` so the DLL reads from the ZIP without any source modifications.

Key types: `TZipVFS` (static class), `TZipManager`.

Dependencies: `StdApp.IATHook`

---

## 3. Dependency Graph

```
StdApp.VMM              (no dependencies -- standalone memory manager)
StdApp.Defines.inc      (no dependencies -- compiler directives)
StdApp.Resources        (no dependencies -- resource strings only)

StdApp.Console          (no StdApp dependencies)
StdApp.DllLoader        (no StdApp dependencies)
StdApp.IATHook          (no StdApp dependencies)
StdApp.JSON             (no StdApp dependencies)

StdApp.Base             --> StdApp.Resources
                            StdApp.Utils (impl only)
                            StdApp.Console (impl only)

StdApp.Utils            --> StdApp.Base
                            StdApp.Resources

StdApp.ResCompiler      --> StdApp.Base

StdApp.VirtualMemory    --> StdApp.Base
                            StdApp.Utils

StdApp.VFS              --> StdApp.Base
                            StdApp.Utils
                            StdApp.Resources
                            StdApp.VirtualMemory

StdApp.TestCase         --> StdApp.Base
                            StdApp.Utils
                            StdApp.Console

StdApp.TestDemo         --> StdApp.Base
                            StdApp.Utils
                            StdApp.Console

StdApp.LibTCC           --> StdApp.Base
                            StdApp.Utils
                            StdApp.Console

StdApp.ZipVFS           --> StdApp.IATHook

StdApp.Console.Menu     --> StdApp.Base
                            StdApp.Utils
                            StdApp.Console
                            StdApp.TestCase
                            StdApp.TestDemo

StdApp.CImporter        --> StdApp.Base
                            StdApp.Utils
                            StdApp.JSON
                            StdApp.ResCompiler
                            StdApp.LibTCC
```

Leaf units (no StdApp dependencies): VMM, Defines.inc, Resources, Console, DllLoader, IATHook, JSON.

---

## 4. Integration Guide

### DPR Uses Clause Ordering

`StdApp.VMM` **must be the first unit** in the .dpr `uses` clause. It installs a custom memory manager in its initialization section, and proper ordering ensures all subsequent unit initialization and finalization uses the custom allocator.

```delphi
uses
  StdApp.VMM,          // MUST be first -- installs memory manager
  StdApp.Base,
  StdApp.Console,
  StdApp.Utils,
  // ... remaining units in any order
```

### Minimal Integration

For a minimal console application, only these units are required:

- `StdApp.VMM` -- memory manager (optional but recommended)
- `StdApp.Defines.inc` -- included automatically by all units
- `StdApp.Base` -- TBaseObject and TErrors
- `StdApp.Resources` -- error message strings
- `StdApp.Console` -- console I/O
- `StdApp.Utils` -- general utilities

### Optional Units

Add as needed:

- `StdApp.JSON` -- if you need JSON parsing/building
- `StdApp.TestCase` + `StdApp.TestDemo` -- for test infrastructure
- `StdApp.Console.Menu` -- for interactive menu UIs
- `StdApp.DllLoader` + `StdApp.IATHook` + `StdApp.ZipVFS` -- for embedded DLL loading
- `StdApp.LibTCC` -- for runtime C compilation
- `StdApp.VFS` -- for VPK archive support
- `StdApp.VirtualMemory` -- for memory-mapped I/O
- `StdApp.ResCompiler` -- for .res file creation
- `StdApp.CImporter` -- for C header to Delphi conversion

### Compiler Defines

`StdApp.Defines.inc` sets the following:

| Directive | Value | Purpose |
|-----------|-------|---------|
| `{$Z4}` | 4-byte enums | Consistent enum sizes across units |
| `{$A8}` | 8-byte alignment | Proper struct alignment for Win64 |
| `{$INLINE AUTO}` | Auto-inlining | Compiler decides inlining |
| Win64 guard | Error on non-Win64 | Platform enforcement |

---

## 5. Memory Manager (VMM)

StdApp.VMM is a high-performance memory manager replacement designed for zero external dependencies. It has no `uses` clause at all -- every WinAPI function it needs is declared directly with `external 'kernel32.dll'` to eliminate finalization-order issues that plague Delphi's default memory manager.

### Pool Architecture

The manager reserves a 64 GB virtual address range via `CreateFileMapping` with `SEC_RESERVE`. This reserves address space only -- no commit charge is consumed upfront. Pages are committed on demand in 1 MB chunks via `VirtualAlloc(MEM_COMMIT)` as the allocator advances into new regions. Committed pages stay committed for reuse; they are never decommitted during the lifetime of the process.

The pool size can be configured via the `--mm-pool <MB>` command-line option (default: 65536 MB = 64 GB).

### Size Classes

26 size classes handle allocations from 16 to 65536 bytes:

```
16, 32, 48, 64, 80, 96, 112, 128,
192, 256, 384, 512,
768, 1024, 1536, 2048,
3072, 4096, 6144, 8192,
12288, 16384, 24576, 32768, 49152, 65536
```

Each size class maintains a singly-linked free list stored directly in freed blocks (no separate metadata structures). The free list pointer occupies the first 8 bytes of each freed block.

### Allocation Strategy

- **GetMem**: Finds the smallest size class that fits the request. Tries the free list first (O(1) pop). If the free list is empty, bump-allocates from the pool and commits pages as needed.
- **FreeMem**: Pushes the block onto its size class free list (O(1) push). The committed memory stays committed and is immediately available for reuse by future allocations of the same size class.
- **ReallocMem**: If the new size fits in the same size class, returns the same pointer (no-op). Otherwise, allocates in the new class, copies data, and frees the old block.
- **Oversized (> 64K)**: Allocates contiguous 64K slices. Freed oversized blocks are kept whole on a separate oversized free list and reused by future oversized requests with matching or smaller slice counts, avoiding unnecessary new commits.

### Edge Cases

- `GetMem(0)` returns nil
- `FreeMem(nil)` is a no-op
- `ReallocMem(nil, N)` acts as `GetMem(N)`
- `ReallocMem(P, 0)` acts as `FreeMem(P)`

### Pre-VMM Pointer Handling

Pointers allocated by the old (Delphi default) memory manager before VMM was installed are detected by range checking against the pool boundaries. `FreeMem` and `ReallocMem` forward these pointers to the saved old memory manager functions, preventing crashes from mixed allocator usage during startup.

### Lifecycle

1. **Initialization**: The `initialization` section reserves the pool via `CreateFileMapping` with `SEC_RESERVE`, maps the view, sets up size class tables, saves the old memory manager, and installs VMM via `SetMemoryManager`.
2. **Finalization**: The `finalization` section restores the old memory manager, unmaps the pool view, and closes the mapping handle.
3. **Stats output**: Uses `ExitProcessProc` (not `finalization`) to print allocation statistics. This ensures stats are printed after all unit finalization has completed, giving accurate final numbers.

### Command-Line Options

| Option | Description |
|--------|-------------|
| `--mm-pool <MB>` | Set pool size in megabytes (default: 65536) |
| `--mm-stats` | Print allocation statistics on exit |

### Stats Output

In debug builds, VMM always prints a summary on exit. In release builds, pass `--mm-stats` to enable. The summary shows: pool reserved/committed, current/peak live usage, allocation/free/reuse counts, total bytes allocated and freed, leak count, and free list depth.
