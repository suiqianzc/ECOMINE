<p align="center"><img width=60% src="https://github.com/suiqianzc/ECOMINE/blob/master/figures/ECOMINE_Logo.png"></p>
<h2 align="center">A Computation Tool for Assessing the Environmental Impact of the Mine </a></h2>
<p align="center">
    <a href="https://github.com/suiqianzc/ECOMINE/commits/master">
    <img src="https://img.shields.io/github/last-commit/suiqianzc/ECOMINE.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub last commit">
    <a href="https://github.com/suiqianzc/ECOMINE/issues">
    <img src="https://img.shields.io/github/issues-raw/suiqianzc/ECOMINE.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub issues">
    <a href="https://github.com/suiqianzc/ECOMINE/pulls">
    <img src="https://img.shields.io/github/issues-pr-raw/suiqianzc/ECOMINE.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub pull requests">
</p>
<p align="center">
  <a href="#what-ECOMINE-does">What ECOMINE does</a> •
  <a href="#file-tree">File tree</a> •
  <a href="#operating-procedures">Operating Procedures</a> •
  <a href="#simple-example">Simple example</a> •
  <a href="#credits">Credits</a> •
  <a href="#bring-your-own-scripts">Bring Your Own Scripts</a> •
</p>

---

## What ECOMINE does
ECOMINE is a computational tool that serves strategic mine planning software, providing it with the capability to assess the environmental impact of mining and mineral processing over the life of the mine, with a core computational approach based on the block model and Life cycle assessment (LCA) integration (Muñoz, 2014). The motivation nehind developing ECOMINE stemmed from the need to assess the efficiency of each pitwalls design method in reducing the carbon footprint of a mine over its life cycle. To this, ECOMINE offers (to date) this functionality for the two strategic mine planning software GEOVIA WHITTLE™ and DATAMINE. Moreover, a utility script allows the visualisation of environmental indicators (i.e.,energy consumption and global warming potential (GWP)) within each block of the ultimate pit limit (UPL), which can be used to observe the energy used as well as the carbon dioxide emissions at different depths of the mine. Finally, a new function comparing the environmental impact of the mine under planar profiles and optimal profiles (Utili, 2022） mining rsepectively is proposed. 

## File tree
- __ECOMINE__
  - [LICENSE](LICENSE)
  - [README.md](README.md)
  - __examples__
  - __figures__
  - __functions__
  - __libraries__ (External dependencies)


## Simple example
This example demonstrates different approaches to generate clumps for the same target geometry. The variables below are documented within each function.

```Matlab
addpath(genpath('functions'));	% Load in-house functions
addpath(genpath('lib'));		% Load external functions (dependencies)
addpath(genpath('classes'));	% Load object-oriented architecture

% Generate clumps using the approach of Ferellec and McDowell (2010)
[mesh, clump]=GenerateClump_Ferellec_McDowell( stlFile, dmin, rmin, rstep, pmax, seed, output );

% Generate clumps using the approach proposed in this code, involving the Euclidean transform of 3D images
[mesh, clump]=GenerateClump_Euclidean_3D( stlFile, N, rMin, div, overlap, output );
```

New users are advised to start from running the available examples in the [examples](examples) folder, to get familiarised with the syntax and functionalities of CLUMP.

## Credits
CLUMP uses several external functions available within the Matlab FEX community. We want to acknowledge the following contributions:
  - Qianqian Fang - [Iso2Mesh](https://uk.mathworks.com/matlabcentral/fileexchange/68258-iso2mesh)
  - Luigi Giaccari - [Surface Reconstruction From Scattered Points Cloud](https://www.mathworks.com/matlabcentral/fileexchange/63730-surface-reconstruction-from-scattered-points-cloud)
  - Pau Micó - [stlTools](https://uk.mathworks.com/matlabcentral/fileexchange/51200-stltools)
  - Anton Semechko - [Rigid body parameters of closed surface meshes](https://uk.mathworks.com/matlabcentral/fileexchange/48913-rigid-body-parameters-of-closed-surface-meshes)

These external dependencies are added within the source code of CLUMP, to provide an out-of-the-box implementation. The licensing terms of each external dependency can be found inside the [lib](lib/) folder.

## BYOS (Bring Your Own Scripts)!
If you enjoy using CLUMP, you are welcome to require the implementation of new clump-generation approaches and features or even better contribute and share your implementations. CLUMP was created to provide a comparison of different methods, by collecting them in one place and we share this tool hoping that members of the community will find it useful. So, feel free to expand the code, propose improvements and report issues.

<h4 align="center">2021 © Vasileios Angelidakis, Sadegh Nadimi, Masahide Otsubo, Stefano Utili. <br/> Newcastle University, UK & The University of Tokyo, Japan</a></h4>