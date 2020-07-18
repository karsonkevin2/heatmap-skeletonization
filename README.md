# heatmap-skeletonization

---

This MATLAB library provides functions to skeletonize traversal heatmaps. This approach utilizes many variables which the user can optimize for their specific use-case. Traversal heatmaps are generated from overlaid GPX tracks from people on foot, cycling, or driving. Many heatmaps are available online via appropriate licensing. This library also provides functionality to download full resolution areas from tile servers into MATLAB without requiring the Mapping Toolbox.

---

## Table of Contents

- [Example](#Example)
- [Dependencies](#Dependencies)
- [FAQ](#FAQ)
- [Generation of roads and paths for OpenStreetMap](#Generation_of_roads_and_paths_for_OpenStreetMap)
- [Related Projects](#Related_Projects)

---

## Example
Start by identifying a tile server to use, for example, OpenStreetMap tiles can be accessed at `https://a.tile.openstreetmap.org/{zoom}/{x}/{y}.png`. Let's load a region around downtown Iowa City at the coordinates, `latitude = 41.661` and `longitude = -91.536`. We will use `zoom = 15` and `pad = 2` to query a 5x5 grid. Call `readWebTiles.m` using these parameters

```MATLAB
[imgArray, scale] = readWebTiles(41.661, -91.536, 15, 2, 'https://a.tile.openstreetmap.org/{zoom}/{x}/{y}.png');
```

We now have `imgArray` which is the image. Suppose we had instead queryed a heatmap and pulled the image `imgArray = imread('stravabig.png')`; We can call `skelAdvanced.m` using default parameters.

img here

```MATLAB
skel = skelAdvanced(imgArray);
```

img here

If we instead play around with our parameters to optimize to our specific case, we can instead call

```MATLAB
skel = skelAdvanced(imgArray, ...);
```

img here


---

## Dependencies
[Image Processing Toolbox](https://www.mathworks.com/products/image.html)

---

## FAQ

- **What makes this solution unique?**

  - Heatmaps exhibit regular behaviour. Each line presents itself as an intense region in the center with a fall off to either side. By utilizing the gradient of the image, we can locate the central regions of these lines. Using other variables we can optimize our approach.

- **What variables can be used?**

  - Supported variables include padsize, blur, recurse, theta, thresh, minSize, and render.

- **How fast are the functions?**

  - Very fast. The program will run in roughly O(n^2) time.
  

---

## Generation_of_roads_and_paths_for_OpenStreetMap

This library was designed for the purpose of automatically generating paths not visible from satellite imagery using Strava Heatmap and then uploading to OpenStreetMap. The methodology is as follows:

1. Locate your Strava authentication tokens, `CloudFront-Key-Pair-Id`, `CloudFront-Signature`, and `CloudFront_Policy` by logging into Strava, navigate to https://www.strava.com/heatmap, and open developer tools to view cookies. 

2. Use the `readWebTiles.m` function, replacing `MYVALUE` with your tokens, with the URL: `a.strava.com/tiles-auth/both/bluered/{zoom}/{x}/{y}.png?Key-Pair-Id=MYVALUE&Signature=MYVALUE&Policy=MYVALUE`

3. Call the `skelAdvanced.m` function with the `imgArray` and play with the parameters until you are satisfied with your results.

4. Utilize the https://github.com/karsonkevin2/line-drawing-to-svg library. Call the `vectorizeLineDense.m` function with your `skel` to create a `svgIntermediate`

5. Utilize the function `printSVGpoly.m` with your `svgIntermediate` to create an SVG file of the skeletonization.

6. If applicable, create a OpenStreetMap account and download the JOSM editor

7. In the JOSM editor, download the https://wiki.openstreetmap.org/wiki/JOSM/Plugins/ImportVec plugin

8. Import the SVG file you created and use the `scale` result from step 2

You're done!

---

## Related_Projects
https://github.com/karsonkevin2/line-drawing-to-svg

---
