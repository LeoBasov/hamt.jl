# HAMPT

This solves the equation
$$
\begin{equation}
    \Delta u = f
\end{equation}
$$
in cartesian and cylinder coordinates.
With the boundary conditions
$$
\begin{align}
    u(\vec{x}) &= a(\vec{x})\\
    \frac{\partial u}{\partial \vec{n}}(\vec{x}) &= b(\vec{x})
\end{align}
$$
for $\forall \vec{x} \in \partial \Omega$ where $\frac{\partial u}{\partial \vec{n}}$ is the normal derevative.


## Heat equation

Given as


## Incompressible Euler equation

For an incopressible, invicid flow we assume the flow being irrotational.
Being irrotational, there must exist a velocity potential $\phi$ such
$$
\begin{equation}
    \nabla \phi = \vec{v}
\end{equation}
$$
where $\vec{v}$ is the flow velocity where $\phi$ sattisfied the Laplace's equation
$$
\begin{equation}
    \Delta \phi = 0.
\end{equation}
$$
Pressure can be calculated directly from the velocity field using Bernoulli's equation as
$$
\begin{equation}
    p = \frac{1}{2} \rho \left(\|\vec{v}_{\infty}\|^2 - \|\vec{v}\|^2 \right) + p_{\infty}.
\end{equation}
$$
The pressure coefficient defined as
$$
\begin{equation}
    C_p = \frac{p - p_{\infty}}{\frac{1}{2} \rho \|\vec{v}_{\infty}\|^2}
\end{equation}
$$
can be wrotten simplified for Bernoulli's equation as
$$
\begin{equation}
    C_p = 1 - \left(\frac{\|\vec{v}\|}{\|\vec{v}_{\infty}\|}\right)^2.
\end{equation}
$$