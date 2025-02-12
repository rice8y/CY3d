# CY3d

This LaTeX package provides a command `\CalabiYau`, which can display Calabi-Yau manifold. This package utilizes PGFplots for drawing Calabi-Yau manifold.

<p align="center" width="100%">
    <img src="tests/cy_jet.png" style="display: block; margin: auto; width: 60%; height: auto;">
</p>

## Requirements

This package requires `pgfplots` and `luacode`. Additionally, since Lua is used for coordinate calculations, LuaLaTeX must be used.

## Installation

To install this package, you can clone the repository from GitHub:

```bash
git clone https://github.com/rice8y/cy3d
```

### Windows

On Windows, you can simply run the following command to install the package:

```bash
install
```

### Linux/macOS

For Linux and macOS, you can use the provided shell script to install the package:

```bash
./install.sh
```

## Usage

```tex
\CalabiYau[colormap]{power}{angle}{mesh size}
```

**Parameters:**

 - power: The degree (or exponent) of the Calabi-Yau equation $z_{1}^{n} + z_{2}^{n}=1$.
 - angle: The angle parameter to adjust the rotation or perspective of the surface.
 - mesh size: Defines the resolution of the mesh for plotting the surface.
 - colormap (option): Specifies the color scheme used for rendering the surface. This is based on the TikZ colormap. The default colormap is jet.

## License

This package is distributed under the BSD 2-Clause License. See [LICENSE](LICENSE).