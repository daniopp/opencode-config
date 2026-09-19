---
name: csharp-tests
description: Create and audit C# tests following EVODOC conventions (XUnit + FluentAssertions, AAA pattern, naming rules). Use when writing new tests, scaffolding a test project, reviewing test quality, or fixing failing tests in EVODOC .NET projects. Do not use for non-C# projects or when the user asks for a different test framework.
compatibility: "requires: .NET SDK (dotnet)"
---

# C# Test Conventions (XUnit + FluentAssertions)

You help write and review tests for EVODOC .NET projects. These conventions
are binding rules; they also align with the C# code rules (`List<T>` over
`Collection<T>`, Allman braces, `var`, LINQ, Italian exception messages).

## Project Setup

- test project name: `<NomeProgetto>.Tests`;
- reference the project under test; use the **XUnit** framework with
  **FluentAssertions** for assertions;
- keep production code and test code in separate projects.

## Naming

Test method naming: `Metodo_StateUnderTest_ExpectedBehavior`.

Examples:

- `Add_EmptyString_ReturnsZero`
- `Parse_InvalidDate_ThrowsFormatException`

## Structure: AAA with Explicit Comments

Every test follows Arrange – Act – Assert with the three comments written
explicitly:

```csharp
[Fact]
public void Add_EmptyString_ReturnsZero()
{
    // Arrange
    var calculator = new Calculator();

    // Act
    var result = calculator.Add("");

    // Assert
    result.Should().Be(0);
}
```

## Facts vs Theories

- `[Fact]` for single-case tests;
- `[Theory]` with `[InlineData]` or `[MemberData]` for parametric tests:

```csharp
[Theory]
[InlineData("1,2", 3)]
[InlineData("4,5", 9)]
public void Add_CommaSeparatedNumbers_ReturnsSum(string input, int expected)
{
    // Arrange
    var calculator = new Calculator();

    // Act
    var result = calculator.Add(input);

    // Assert
    result.Should().Be(expected);
}
```

## Exception Testing

Assert specific exception types (never a bare `Exception`), mirroring the
production rule of throwing/catching specific exceptions:

```csharp
[Fact]
public void Add_NullInput_ThrowsArgumentNullException()
{
    // Arrange
    var calculator = new Calculator();

    // Act
    var act = () => calculator.Add(null);

    // Assert
    act.Should().Throw<ArgumentNullException>();
}
```

## Test Quality Rules

Every test must be:

- **isolated** — use mocks/stubs/DI; no shared mutable state between tests;
- **deterministic** — no reliance on current date/time, random data, ordering,
  or network; freeze time or inject it when behavior depends on it;
- **fast** — no sleeps, no heavy I/O;
- **logic-free** — do not replicate production logic inside the test; assert
  expected values directly.

## Coverage Checklist

When writing tests for a unit, cover:

- [ ] happy path (expected behavior for valid input);
- [ ] error and edge cases (empty, null, boundary values);
- [ ] exceptional behavior (specific exception types thrown);
- [ ] state transitions or side effects when the unit manages state.

## Workflow

1. **Read the unit under test** (method, class, or service) and identify its
   behaviors, edge cases, and error paths.
2. **Enumerate behaviors** as a list; one test per behavior.
3. **Scaffold or extend** the test class following the rules above.
4. **Verify** by running `dotnet test` on the test project; report results with
   the evidence path (which tests cover which behaviors).
5. **Audit mode**: when reviewing existing tests, check naming, AAA comments,
   isolation, determinism, and coverage; report violations as a list before
   proposing fixes.
