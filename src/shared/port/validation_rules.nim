import std/strformat

type ValidationMessage* = ref object

template required*(){.pragma.}
func required*(field: string): bool = field.len > 0
func required*(_: type ValidationMessage,
    field: string): string = &"{field} is required"

template email*(){.pragma.}
func email*(field: string): bool = field.len > 0
func email*(_: type ValidationMessage, field: string): string = &"{field} is invalid email format"

template between*(a, b: int){.pragma.}
func between*(field: int, a, b: int): bool = field > a and field < b
func between*(_: type ValidationMessage, field: string, a,
    b: int): string = &"{field} must be between {a} and {b}"

template between*(a, b: uint32){.pragma.}
func between*(field: uint32, a, b: uint32): bool = field >= a and field <= b
func between*(_: type ValidationMessage, field: string, a,
    b: uint32): string = &"{field} must be between {a} and {b}"

template minmax*(a, b: int){.pragma.}
func minmax*(field: string, a, b: int): bool = field.len > a and field.len < b
func minmax*(_: type ValidationMessage, field: string, a,
    b: int): string = &"{field}'s len must be between {a} and {b}"


template max*(a: int){.pragma.}
func max*(field: string, a: int): bool = field.len < a
func max*(_: type ValidationMessage, field: string, a: int): string = &"{field}'s len must be within {a}"
