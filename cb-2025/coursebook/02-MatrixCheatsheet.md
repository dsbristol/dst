---
title: Matrix and Vector operations
layout: coursebook
usemathjax: true
---

# Matrix and Vector operations Cheat Sheet

## Basic operations

|Math| Comments|
|---|---|
| $$(\mathbf{A}\mathbf{B})^T= \mathbf{B}^T\mathbf{A}^T$$ | Transposing reverses order|
| $$\mathbf{a}^T\mathbf{b} = constant = \mathbf{b}^T\mathbf{a}$$ | For vectors, the result is a scalar, so order can be changed. |
| $$(\mathbf{A} + \mathbf{B}) \mathbf{C}= \mathbf{A}\mathbf{C} + \mathbf{B}\mathbf{C}$$ | Multiplication is distributive |
| $$(\mathbf{a} + \mathbf{b})^T \mathbf{C} = \mathbf{a}^T \mathbf{C} + \mathbf{b}^T \mathbf{C}$$ | vector and transpose operations are distributive |
| $$(\mathbf{A}\mathbf{B})^{-1} = \mathbf{B}^{-1}\mathbf{A}^{-1} $$ | Inverse reverses order (when individual inverses exist) |
| $$(\mathbf{A}^T)^{-1} = (\mathbf{A}^{-1}) ^T $$ | Inverse and transposes commute |

## Determinant, Rank, Trace

|Math| Comments|
|---|---|
| $$\mathrm{det}(\mathbf{A})= \|\mathbf{A}\| $$ | Definition of determinant |
| $$\|\mathbf{A}\mathbf{B}\| = \|\mathbf{A}\| \|\mathbf{B}\| $$ | Determinant commutes with product |
| $$\mathrm{rank}(\mathbf{A})= \mathrm{rank}(\mathbf{A}^T\mathbf{A}) = \mathrm{rank}(\mathbf{A}\mathbf{A}^T) $$ | Rank of non-square matrices |
| $$\mathrm{Tr}(\mathbf{A})= \sum_{i=1}^d \lambda_d$$ | Trace is sum of eigenvalues |
| $$\mathrm{Tr}(\mathbf{A}\mathbf{B}\mathbf{C})= \mathrm{Tr}(\mathbf{C}\mathbf{A}\mathbf{B})$$ | Trace is cyclic (where defined) |

	
## Matrix derivatives

Using the convention that $$\nabla_x f(\mathbf{X}) = \frac{df(\mathbf{X})}{d\mathbf{x}}$$:

| |Scalar| | |Vector| (Description) |
|$$f(x)$$ | $$\to$$ | $$\frac{df}{dx}$$ | $$f(x)$$ | $$\to$$ | $$\frac{df}{d\mathbf{x}}$$|
|---|---|---|---|---|---|
||||||Derivative of linear function:|
|$$bx$$ | |$$b$$ |$$\mathbf{x}^T\mathbf{B}$$ | |$$\mathbf{B}$$ | 
||||||Derivative of quadratic function:|
|$$bx^2$$ | |$$2bx$$ |$$\mathbf{x}^T\mathbf{B}\mathbf{x}$$ | |$$ \mathbf{B}\mathbf{x} + \mathbf{B}^T\mathbf{x}$$ |
||||||Product rule for vector/matrix valued functions:|
|$$g(x)h(x)$$ | |$$g^\prime h + g h^\prime$$ |$$\mathbf{g}(\mathbf{x})\mathbf{h}(\mathbf{x})$$ | |$$\nabla_x (\mathbf{g}(\mathbf{x})) \mathbf{h}(\mathbf{x}) + \mathbf{g}(\mathbf{x}) \nabla_x (\mathbf{h}(\mathbf{x}))$$ |

## Further Reading

  * A complete reference is [The Matrix Cookbook](https://www.math.uwaterloo.ca/~hwolkowi/matrixcookbook.pdf)
* [Sam Roweis' Matrix Identities](http://robotics.caltech.edu/~sam/TechReports/extern_matrixids.pdf)
