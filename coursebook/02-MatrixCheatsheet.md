---
title: Matrix and Vector operations
layout: coursebook
usemathjax: true
---

# Matrix and Vector operations Cheat Sheet

Basic operations

|Math| Comments|
|---|---|
| $$(\mathbf{A}\mathbf{B})^T= \mathbf{B}^T\mathbf{A}^T$$ | Transposing reverses order|
| $$\mathbf{a}^T\mathbf{b} = constant = \mathbf{b}^T\mathbf{a}$$ | For vectors, the result is a scalar, so order can be changed. |
| $$(\mathbf{A} + \mathbf{B}) \mathbf{C}= \mathbf{A}\mathbf{C} + \mathbf{B}\mathbf{C}$$ | Multiplication is distributive |
| $$(\mathbf{a} + \mathbf{b})^T \mathbf{C} = \mathbf{a}^T \mathbf{C} + \mathbf{b}^T \mathbf{C}$$ | vector and transpose operations are distributive |
| $$(\mathbf{A}\mathbf{B})^{-1} = \mathbf{B}^{-1}\mathbf{A}^{-1} $$ | Inverse reverses order (when individual inverses exist) |
| $$(\mathbf{A}^T)^{-1} = (\mathbf{A}^{-1}) ^T $$ | Inverse and transposes commute |


|Math| Comments|
|---|---|
| $$\mathrm{det}(\mathbf{A})= \|\mathbf{A}\| $$ | Definition of determinant |
| $$\|\mathbf{A}\mathbf{B}\| = \|\mathbf{A}\| \|\mathbf{B}\| $$ | Determinant commutes with product |


| |Scalar| | |Vector| |
|$$f(x)$$ | $$\to$$ | $$\frac{df}{dx}$$ | $$f(x)$$ | $$\to$$ | $$\frac{df}{d\mathbf{x}}$$|
|---|---|---|---|---|---|
|$$bx$$ | |$$b$$ |$$\mathbf{x}^T\mathbf{B}$$ | |$$\mathbf{B}$$ |

## Further Reading

* [Matrix Multiplication Cheat Sheet](02-MatrixCheatsheet.md)
  * A complete reference is [The Matrix Cookbook](https://www.math.uwaterloo.ca/~hwolkowi/matrixcookbook.pdf)
* [Sam Roweis' Matrix Identities](http://robotics.caltech.edu/~sam/TechReports/extern_matrixids.pdf)
