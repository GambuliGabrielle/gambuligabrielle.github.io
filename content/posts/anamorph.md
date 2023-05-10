+++
title = "France in Motion: High-Speed Rails Distorting Distances"
date = 2023-04-06
description = """
Anamorphic maps
"""
[extra]
year = 2023
+++

<div style="display: flex; flex-wrap: wrap;">
  <img src="/image/anamorph/anamorph1980.png" style="width: 20%; height: auto;">
  <img src="/image/anamorph/anamorph1990.png" style="width: 20%; height: auto;">
  <img src="/image/anamorph/anamorph2000.png" style="width: 20%; height: auto;">
  <img src="/image/anamorph/anamorph2010.png" style="width: 20%; height: auto;">
  <img src="/image/anamorph/anamorph2010.png" style="width: 20%; height: auto;">
</div>

Anamorphic maps are a unique way of visualizing spatial data. They distort the shape of locations to reflect a specific variable, such as population density or economic activity. This approach can provide a fresh perspective on familiar geographic features and reveal new patterns and insights.
As part of my research, I study the evolution of train travel times in France, which have substantially decreased with introduction of high-speed railways. High-speed networks distort the relationship between space and time. Hence, it impacts our perception of distance. To illustrate those changes, I've used anamorphic techniques that distorts the distances between french cities.

To create an anamorphic map that takes into account changes in distances based on changes in travel time, we need to identify a fixed point, *in my case it is Paris*, and other points, *other big cities*, within the spatial polygon of France. We also need to define a reference year, *1980, before the first high-speed rail roll-out*, with the shape of France and location of cities normalized to the travel time of the reference year. This serve as the basis for comparison with travel times in other years.

Next, we need to compute the ratio of travel time in year *t* with respect to year 1980. This is done by dividing the travel time in year *t* by the travel time in 1980. The resulting ratio will serve as a scaling factor for the distances between Paris and other cities. 
We also need to compute the bearing of Paris and the other cities. The bearing is the direction from Paris to each city, expressed as an angle from the north. This is important because we use it to adjust the distance between Paris and each city based on the change in travel time.

Finally, to make the cities closer to Paris, we use the ratio of travel time and the bearing to compute a new set of coordinates for each city. We do this by multiplying the original distance between Paris and each city by the ratio of travel time and adjusting the bearing accordingly.
Then, what is left to do is to plot the distorted map of France using the new set of coordinates for each city and all the points drawing the national borders.

To put it in a nutshell, this process involves using travel time data to compute ratios, as well as bearings, that we can use to distort the map of France. The resulting maps show the spatial relationships between different locations in France based on changes in travel time over time, allowing us to visualize how the perceived distances have changed between different cities of the country.

Discover below how the French high-speed railway has improved travel time from Paris to other cities between 1980 and 2020, and see cities that have become more accessible.

<p align="center" width="100%">
	<b>Train Travel Time from Paris</b>
	<img src="/image/anamorph/anamorphparis.gif" alt="Example GIF">
</p>

Below, you will find as well maps from the point of view of Lyon and Bordeaux.

<p align="center" width="100%">
	<b>Train Travel Time from Lyon</b>
	<img src="/image/anamorph/anamorphlyon.gif" alt="Example GIF">
</p>

<p align="center" width="100%">
	<b>Train Travel Time from Bordeaux</b>
	<img src="/image/anamorph/anamorphbordeaux.gif" alt="Example GIF">
</p>





![](/image/signature.png)