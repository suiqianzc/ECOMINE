<p align="center"><img width=50% src="https://github.com/suiqianzc/ECOMINE/blob/master/figures/ECOMINE_Logo.png"></p>
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
  <a href="#ECOMINE-features">ECOMINE features</a> •  
  <a href="#architectural-features">Architectural features</a> •
  <a href="#file-tree">File tree</a> •
  <a href="#how-to-get-started">How to get started</a> •
  <a href="#credits">Credits</a> •
  <a href="#bring-your-own-scripts">Bring Your Own Scripts</a> •
</p>

---

## ECOMINE features
ECOMINE is a computational tool that serves strategic mine planning software, providing it with the capability to assess the environmental impact of mining and mineral processing over the life of the mine, with a core computational approach based on the block model and Life cycle assessment (LCA) integration (Muñoz, 2014). The motivation nehind developing ECOMINE stemmed from the need to assess the efficiency of each pitwalls design method in reducing the carbon footprint of a mine over its life cycle. To this, ECOMINE offers (to date) this functionality for the two strategic mine planning software. Moreover, a utility script allows the visualisation of environmental indicators (i.e.,energy consumption-EC and global warming potential-GWP) within each block of the ultimate pit limit (UPL), which can be used to observe the energy used as well as the carbon dioxide emissions at different depths of the mine. Finally, a new function comparing the environmental impact of the mine under planar pitwalls design and optimal pitwalls design (Utili, 2022） mining rsepectively is proposed. 

## Architectural features
ECOMINE comprises the following modules:

- __Generate and Export ECGWP and NBM__
  - GEOVIA WHITTLE™
  - DATAMINE

- __Visualise NBM__
  - Energy Consumption Model
  - Global Warming Potential Model

- __Compare ECGWP__
  - Planar Profiles vs Optimal Profiles

## File tree
- __ECOMINE__
  - [LICENSE](LICENSE)
  - [README.md](README.md)
  - __examples__
  - __figures__
  - __functions__
  - __libraries__ (External dependencies)
  
## How to get started
- __Take GEOVIA WHITTLE™ as an example__
  - __Module I__ 
  - Run Example_GeoviaWhittle.m
  - Select Options for Rock Type
  - Input BlockModel file and ComputationParameter file
  - Enter Specific Energy Consumption of Drilling
  - Select Options for Mineral/Metal Type
  - Select Options for Unit of Coordinates
  - Export ECGWP and NBM
  
<p align="center"><img width=80% src="https://github.com/suiqianzc/ECOMINE/blob/master/figures/Cumulative_EnergyConsumption_GlobalWarmingPotential.png"></p> 
  
  - __Module II__
  - Run Plot_NBM_of_Mine.m
  - Load NBM
  - Plotting
  
<p align="center"><img width=80% src="https://github.com/suiqianzc/ECOMINE/blob/master/figures/ECGWP_UPL_Model.png"></p>   

  - __Module III__
  - Load ECGWP_Optimal/Planar_GeoviaWhittle.mat
  - Run Example_Compare_Optimal_Planar.m
  - Plotting
  
<p align="center"><img width=80% src="https://github.com/suiqianzc/ECOMINE/blob/master/figures/ECGWP_Compare_Optimal_Planar.png"></p>  

New users are advised to start from running the available examples in the [examples](examples) folder, to get familiarised with the syntax and functionalities of ECOMINE. 

## Credits
ECOMINE uses two external functions available within the Matlab FEX community. We want to acknowledge the following contributions:
  - Pierre Morel - [gramm](https://ch.mathworks.com/matlabcentral/fileexchange/54465-gramm-complete-data-visualization-toolbox-ggplot2-r-like)
  - Stephen Cobeldick - [MatPlotLib Perceptually Uniform Colormaps](https://ch.mathworks.com/matlabcentral/fileexchange/62729-matplotlib-perceptually-uniform-colormaps)

These external dependencies are added within the source code of ECOMINE, to provide an out-of-the-box implementation. The licensing terms of each external dependency can be found inside the [libraries](libraries/) folder.

## Share your own ideas!
If you enjoy using ECOMINE and think it has potentials in the field of asssessing the environmental impact for life of the mine, we are very much looking forward to you coming up with new ideas or even better contributing and sharing your implementations. ECOMINE was created to provide strategic mine planning software with a function to calculate the environmental indicators of mines under different pitwalls design methods, by collecting these scripts in one place and we share this tool in the hope that members of the community or even software developers in companies will find it useful. So please feel free to extend the code, propose improvements and report issues.

<h4 align="center">2022 © Chao Zhang. <br/> Newcastle University, UK</a></h4>